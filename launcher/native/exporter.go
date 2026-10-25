package main

import (
	"archive/zip"
	"compress/flate"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"time"
)

const (
	launcherVersion = "3.2.0"
	exportSchema    = 2
)

var errSnapshotCancelled = errors.New("source handoff cancelled")

type snapshotEntry struct {
	Version   string `json:"version"`
	Sequence  int    `json:"sequence"`
	FileName  string `json:"file_name"`
	CreatedAt string `json:"created_at"`
	SizeBytes int64  `json:"size_bytes"`
	SHA256    string `json:"sha256"`
	FileCount int    `json:"file_count"`
}

type snapshotIndex struct {
	Schema          int             `json:"schema"`
	Project         string          `json:"project"`
	LauncherVersion string          `json:"launcher_version"`
	Latest          string          `json:"latest"`
	UpdatedAt       string          `json:"updated_at"`
	Snapshots       []snapshotEntry `json:"snapshots"`
}

type snapshotManifest struct {
	Schema                int      `json:"schema"`
	Project               string   `json:"project"`
	LauncherVersion       string   `json:"launcher_version"`
	BuildVersion          string   `json:"build_version"`
	Sequence              int      `json:"sequence"`
	SnapshotID            string   `json:"snapshot_id"`
	CreatedAt             string   `json:"created_at"`
	HandoffProfile        string   `json:"handoff_profile"`
	FileCount             int      `json:"file_count"`
	SourceBytes           int64    `json:"source_bytes"`
	RuntimeAssetsIncluded bool     `json:"runtime_assets_included"`
	AssetIndexEntries     int      `json:"asset_index_entries"`
	AssetBytesOmitted     int64    `json:"asset_bytes_omitted"`
	Compression           string   `json:"compression"`
	Included              []string `json:"included"`
	Excluded              []string `json:"excluded"`
	Notes                 string   `json:"notes"`
}

type snapshotResult struct {
	Entry      snapshotEntry
	Archive    string
	LatestPath string
	Err        error
}

type snapshotProgress struct {
	Phase       string
	Detail      string
	CurrentFile string
	Percent     int
	FilesDone   int
	FilesTotal  int
	BytesDone   int64
	BytesTotal  int64
}

type snapshotExportControl struct {
	Progress  func(snapshotProgress)
	Cancelled func() bool
}

type snapshotSourceFile struct {
	Rel  string
	Size int64
}

var versionCleanRe = regexp.MustCompile(`[^A-Za-z0-9._-]+`)

func normalizeBuildVersion(raw string) string {
	s := strings.TrimSpace(raw)
	if s == "" {
		return "BV1"
	}
	s = strings.ToUpper(versionCleanRe.ReplaceAllString(s, "-"))
	s = strings.Trim(s, "-._")
	if s == "" {
		return "BV1"
	}
	allDigits := true
	for _, r := range s {
		if r < '0' || r > '9' {
			allDigits = false
			break
		}
	}
	if allDigits {
		s = "BV" + s
	}
	return s
}

func exportDirFor(root string) string    { return filepath.Join(root, "exports") }
func exportIndexPath(root string) string { return filepath.Join(exportDirFor(root), "index.json") }

func loadSnapshotIndex(root string) snapshotIndex {
	idx := snapshotIndex{
		Schema:          exportSchema,
		Project:         "Crawl Brawl",
		LauncherVersion: launcherVersion,
		Snapshots:       []snapshotEntry{},
	}
	data, err := os.ReadFile(exportIndexPath(root))
	if err == nil {
		_ = json.Unmarshal(data, &idx)
	}
	idx.Schema = exportSchema
	if idx.Project == "" {
		idx.Project = "Crawl Brawl"
	}
	idx.LauncherVersion = launcherVersion
	filtered := make([]snapshotEntry, 0, len(idx.Snapshots))
	for _, entry := range idx.Snapshots {
		if entry.FileName == "" {
			continue
		}
		if st, err := os.Stat(filepath.Join(exportDirFor(root), entry.FileName)); err == nil && !st.IsDir() {
			filtered = append(filtered, entry)
		}
	}
	idx.Snapshots = filtered
	if len(idx.Snapshots) > 0 {
		idx.Latest = idx.Snapshots[0].FileName
	} else {
		idx.Latest = ""
	}
	return idx
}

func nextSnapshotSequence(root, version string) int {
	version = normalizeBuildVersion(version)
	maxSeq := 0
	idx := loadSnapshotIndex(root)
	for _, e := range idx.Snapshots {
		if strings.EqualFold(e.Version, version) && e.Sequence > maxSeq {
			maxSeq = e.Sequence
		}
	}

	pattern := regexp.MustCompile(`(?i)^CrawlBrawl_` + regexp.QuoteMeta(version) + `_DEV([0-9]{3,})_(?:SOURCE_)?[^/]*\.zip$`)
	entries, _ := os.ReadDir(exportDirFor(root))
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		m := pattern.FindStringSubmatch(e.Name())
		if len(m) != 2 {
			continue
		}
		var seq int
		_, _ = fmt.Sscanf(m[1], "%d", &seq)
		if seq > maxSeq {
			maxSeq = seq
		}
	}
	return maxSeq + 1
}

func snapshotName(version string, sequence int, now time.Time) string {
	version = normalizeBuildVersion(version)
	return fmt.Sprintf("CrawlBrawl_%s_DEV%03d_SOURCE_%s.zip", version, sequence, now.Format("20060102_1504"))
}

const sourceHandoffMaxFileBytes int64 = 16 * 1024 * 1024

var sourceHandoffExtensions = map[string]bool{
	".gd": true, ".uid": true, ".tscn": true, ".tres": true, ".godot": true,
	".cfg": true, ".ini": true, ".xml": true, ".json": true, ".md": true,
	".txt": true, ".csv": true, ".shader": true, ".gdshader": true,
	".py": true, ".go": true, ".mod": true, ".sum": true, ".toml": true,
	".yaml": true, ".yml": true, ".bat": true, ".ps1": true, ".vbs": true,
	".sh": true, ".cs": true, ".csproj": true, ".sln": true,
	".gdextension": true, ".gdignore": true, ".po": true, ".pot": true,
}

func shouldSkipSourceHandoffDir(rel string) bool {
	rel = strings.TrimSuffix(strings.ToLower(filepath.ToSlash(rel)), "/")
	if rel == "" || rel == "." {
		return false
	}
	dirs := []string{
		"assets", "exports", ".godot", ".git", ".idea", ".vscode", ".vs",
		"logs", "build", "builds", "dist", "bin", "output", "recordings",
		"scripts/_recover_tmp", "scripts/_recovered_funcs_from_transcript",
	}
	for _, d := range dirs {
		if rel == d || strings.HasPrefix(rel, d+"/") {
			return true
		}
	}
	return false
}

func shouldIncludeSourceHandoffFile(rel string, info fs.FileInfo) bool {
	rel = filepath.ToSlash(rel)
	relLower := strings.ToLower(rel)
	baseLower := strings.ToLower(filepath.Base(rel))

	if shouldSkipSourceHandoffDir(filepath.Dir(rel)) {
		return false
	}
	if info != nil && info.Size() > sourceHandoffMaxFileBytes {
		return false
	}
	if strings.HasSuffix(relLower, "/backup.zip") || baseLower == "backup.zip" {
		return false
	}
	if strings.HasSuffix(baseLower, ".tmp") || strings.HasSuffix(baseLower, ".temp") || strings.HasSuffix(baseLower, ".bak") || strings.HasSuffix(baseLower, ".old") {
		return false
	}
	if strings.HasSuffix(baseLower, ".dmp") || strings.HasSuffix(baseLower, ".crash") {
		return false
	}

	exactExclude := map[string]bool{
		"launcher/launcher_config.json":   true,
		"launcher/crawlbrawllauncher.ps1": true,
		"launcher/launch_hidden.vbs":      true,
	}
	if exactExclude[relLower] {
		return false
	}

	// The launcher itself is a runtime binary, not editable source. Its Go source
	// under launcher/native is included by extension instead.
	if baseLower == "play crawl brawl.exe" {
		return false
	}

	// Keep root-level project/config files and all source-like text files. This
	// intentionally excludes PNG/JPG/audio/font/PCK/imported runtime content.
	ext := strings.ToLower(filepath.Ext(baseLower))
	if sourceHandoffExtensions[ext] {
		return true
	}
	if baseLower == ".gitignore" || baseLower == ".gitattributes" || baseLower == "license" || strings.HasPrefix(baseLower, "readme") {
		return true
	}
	return false
}

func collectSnapshotFiles(root string) ([]snapshotSourceFile, int64, error) {
	files := make([]snapshotSourceFile, 0, 256)
	var total int64
	err := filepath.WalkDir(root, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(root, path)
		if err != nil {
			return err
		}
		if rel == "." {
			return nil
		}
		if d.IsDir() {
			if shouldSkipSourceHandoffDir(rel) {
				return filepath.SkipDir
			}
			return nil
		}
		info, err := d.Info()
		if err != nil {
			return err
		}
		if !shouldIncludeSourceHandoffFile(rel, info) {
			return nil
		}
		files = append(files, snapshotSourceFile{Rel: rel, Size: info.Size()})
		total += info.Size()
		return nil
	})
	sort.Slice(files, func(i, j int) bool { return files[i].Rel < files[j].Rel })
	return files, total, err
}

func collectAssetIndex(root string, control snapshotExportControl) (string, int, int64, error) {
	assetRoot := filepath.Join(root, "assets")
	if st, err := os.Stat(assetRoot); err != nil || !st.IsDir() {
		return "# Crawl Brawl asset index\n# No assets/ directory was present in this source tree.\n", 0, 0, nil
	}
	lines := []string{
		"# Crawl Brawl asset index (paths only; binary assets intentionally omitted)",
		"# Format: size_bytes<TAB>relative_path",
	}
	count := 0
	var bytes int64
	err := filepath.WalkDir(assetRoot, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if cancelled(control) {
			return errSnapshotCancelled
		}
		relToAssets, _ := filepath.Rel(assetRoot, path)
		if d.IsDir() {
			if strings.EqualFold(filepath.ToSlash(relToAssets), "debug_video_frames") {
				return filepath.SkipDir
			}
			return nil
		}
		info, err := d.Info()
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(root, path)
		if err != nil {
			return err
		}
		count++
		bytes += info.Size()
		lines = append(lines, fmt.Sprintf("%d\t%s", info.Size(), filepath.ToSlash(rel)))
		if count == 1 || count%250 == 0 {
			emitSnapshotProgress(control, snapshotProgress{Phase: "SCAN", Detail: fmt.Sprintf("Indexing asset references... %d paths", count), Percent: 4})
		}
		return nil
	})
	if err != nil {
		return "", 0, 0, err
	}
	lines = append(lines, fmt.Sprintf("# %d asset files omitted; %.1f MB remains on the development machine.", count, float64(bytes)/(1024.0*1024.0)))
	return strings.Join(lines, "\n") + "\n", count, bytes, nil
}

func sourceHandoffReadme(version string, sequence int) string {
	return fmt.Sprintf(`CRAWL BRAWL SOURCE HANDOFF

Snapshot: %s-DEV%03d
Profile: SOURCE_ONLY

This ZIP is intentionally NOT a runnable copy of Crawl Brawl. It is a compact
browser/Codex development handoff containing editable source and structural
metadata only. Runtime art, audio, fonts, imported assets, caches, logs, game
binaries, and previous exports stay on the development machine.

Included:
- GDScript and other source code
- Godot scenes/resources/project configuration
- XML/JSON/config maps and small documentation
- tests/tools source when present
- launcher/native source
- ASSET_INDEX.txt (paths and sizes only; no binary asset payloads)

To run the game, apply edited source back onto the full local Crawl Brawl project.
`, version, sequence)
}

func shouldDeflateSnapshotFile(rel string) bool {
	// Source-only handoffs contain text and small metadata, so BestSpeed DEFLATE
	// is appropriate for every included project file.
	return true
}

func cancelled(control snapshotExportControl) bool {
	return control.Cancelled != nil && control.Cancelled()
}

func emitSnapshotProgress(control snapshotExportControl, p snapshotProgress) {
	if control.Progress == nil {
		return
	}
	if p.Percent < 0 {
		p.Percent = 0
	}
	if p.Percent > 100 {
		p.Percent = 100
	}
	control.Progress(p)
}

func addFileToZip(zw *zip.Writer, root string, src snapshotSourceFile, onBytes func(int64) error) error {
	abs := filepath.Join(root, src.Rel)
	info, err := os.Stat(abs)
	if err != nil {
		return err
	}
	hdr, err := zip.FileInfoHeader(info)
	if err != nil {
		return err
	}
	hdr.Name = filepath.ToSlash(src.Rel)
	if shouldDeflateSnapshotFile(src.Rel) {
		hdr.Method = zip.Deflate
	} else {
		hdr.Method = zip.Store
	}
	hdr.Modified = info.ModTime()
	w, err := zw.CreateHeader(hdr)
	if err != nil {
		return err
	}
	r, err := os.Open(abs)
	if err != nil {
		return err
	}
	defer r.Close()

	buf := make([]byte, 512*1024)
	for {
		n, readErr := r.Read(buf)
		if n > 0 {
			if _, err := w.Write(buf[:n]); err != nil {
				return err
			}
			if onBytes != nil {
				if err := onBytes(int64(n)); err != nil {
					return err
				}
			}
		}
		if readErr == io.EOF {
			break
		}
		if readErr != nil {
			return readErr
		}
	}
	return nil
}

func fileSHA256WithProgress(path string, total int64, control snapshotExportControl) (string, error) {
	f, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer f.Close()
	h := sha256.New()
	buf := make([]byte, 1024*1024)
	var done int64
	for {
		if cancelled(control) {
			return "", errSnapshotCancelled
		}
		n, readErr := f.Read(buf)
		if n > 0 {
			if _, err := h.Write(buf[:n]); err != nil {
				return "", err
			}
			done += int64(n)
			pct := 88
			if total > 0 {
				pct += int(float64(done) / float64(total) * 7.0)
			}
			emitSnapshotProgress(control, snapshotProgress{Phase: "VERIFY", Detail: "Calculating SHA-256 checksum...", Percent: pct, BytesDone: done, BytesTotal: total})
		}
		if readErr == io.EOF {
			break
		}
		if readErr != nil {
			return "", readErr
		}
	}
	return hex.EncodeToString(h.Sum(nil)), nil
}

func atomicWriteJSON(path string, value any) error {
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		return err
	}
	data, err := json.MarshalIndent(value, "", "  ")
	if err != nil {
		return err
	}
	data = append(data, '\n')
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0644); err != nil {
		return err
	}
	_ = os.Remove(path)
	return os.Rename(tmp, path)
}

func replaceLatestAlias(archivePath, latestPath string) error {
	_ = os.Remove(latestPath)
	if err := os.Link(archivePath, latestPath); err == nil {
		return nil
	}
	src, err := os.Open(archivePath)
	if err != nil {
		return err
	}
	defer src.Close()
	dst, err := os.Create(latestPath)
	if err != nil {
		return err
	}
	if _, err = io.Copy(dst, src); err != nil {
		_ = dst.Close()
		return err
	}
	return dst.Close()
}

func saveSnapshotIndex(root string, entry snapshotEntry) error {
	idx := loadSnapshotIndex(root)
	idx.Latest = entry.FileName
	idx.UpdatedAt = time.Now().Format(time.RFC3339)
	idx.LauncherVersion = launcherVersion

	out := make([]snapshotEntry, 0, len(idx.Snapshots)+1)
	out = append(out, entry)
	for _, old := range idx.Snapshots {
		if old.FileName == entry.FileName {
			continue
		}
		out = append(out, old)
	}
	idx.Snapshots = out
	return atomicWriteJSON(exportIndexPath(root), idx)
}

func createDevelopmentSnapshot(root, version string, now time.Time) snapshotResult {
	return createDevelopmentSnapshotWithControl(root, version, now, snapshotExportControl{})
}

func createDevelopmentSnapshotWithControl(root, version string, now time.Time, control snapshotExportControl) snapshotResult {
	version = normalizeBuildVersion(version)
	exportsDir := exportDirFor(root)
	emitSnapshotProgress(control, snapshotProgress{Phase: "PREPARE", Detail: "Preparing export directory...", Percent: 1})
	if err := os.MkdirAll(exportsDir, 0755); err != nil {
		return snapshotResult{Err: err}
	}
	if partials, err := filepath.Glob(filepath.Join(exportsDir, "*.partial")); err == nil {
		for _, partial := range partials {
			_ = os.Remove(partial)
		}
	}
	if cancelled(control) {
		return snapshotResult{Err: errSnapshotCancelled}
	}

	seq := nextSnapshotSequence(root, version)
	name := snapshotName(version, seq, now)
	finalPath := filepath.Join(exportsDir, name)
	tmpPath := finalPath + ".partial"
	_ = os.Remove(tmpPath)

	emitSnapshotProgress(control, snapshotProgress{Phase: "SCAN", Detail: "Scanning project files and exclusions...", Percent: 3})
	files, sourceBytes, err := collectSnapshotFiles(root)
	if err != nil {
		return snapshotResult{Err: err}
	}
	if cancelled(control) {
		return snapshotResult{Err: errSnapshotCancelled}
	}
	emitSnapshotProgress(control, snapshotProgress{Phase: "SCAN", Detail: "Indexing asset paths without packaging asset payloads...", Percent: 4})
	assetIndex, assetCount, assetBytes, err := collectAssetIndex(root, control)
	if err != nil {
		if errors.Is(err, errSnapshotCancelled) {
			return snapshotResult{Err: errSnapshotCancelled}
		}
		return snapshotResult{Err: err}
	}
	if cancelled(control) {
		return snapshotResult{Err: errSnapshotCancelled}
	}
	emitSnapshotProgress(control, snapshotProgress{
		Phase: "PACK", Detail: fmt.Sprintf("Packing %d source files (runtime assets omitted)...", len(files)), Percent: 5,
		FilesTotal: len(files), BytesTotal: sourceBytes,
	})

	out, err := os.Create(tmpPath)
	if err != nil {
		return snapshotResult{Err: err}
	}
	zw := zip.NewWriter(out)
	zw.RegisterCompressor(zip.Deflate, func(w io.Writer) (io.WriteCloser, error) {
		return flate.NewWriter(w, flate.BestSpeed)
	})

	cleanupPartial := func() {
		_ = zw.Close()
		_ = out.Close()
		_ = os.Remove(tmpPath)
	}

	var bytesDone int64
	for i, src := range files {
		if cancelled(control) {
			cleanupPartial()
			return snapshotResult{Err: errSnapshotCancelled}
		}
		fileDoneBefore := bytesDone
		err := addFileToZip(zw, root, src, func(delta int64) error {
			bytesDone += delta
			if cancelled(control) {
				return errSnapshotCancelled
			}
			pct := 5
			if sourceBytes > 0 {
				pct += int(float64(bytesDone) / float64(sourceBytes) * 78.0)
			}
			emitSnapshotProgress(control, snapshotProgress{
				Phase: "PACK", Detail: fmt.Sprintf("Packing %d / %d files", i+1, len(files)), CurrentFile: filepath.ToSlash(src.Rel), Percent: pct,
				FilesDone: i, FilesTotal: len(files), BytesDone: bytesDone, BytesTotal: sourceBytes,
			})
			return nil
		})
		if err != nil {
			cleanupPartial()
			if errors.Is(err, errSnapshotCancelled) {
				return snapshotResult{Err: errSnapshotCancelled}
			}
			return snapshotResult{Err: fmt.Errorf("add %s: %w", src.Rel, err)}
		}
		if bytesDone < fileDoneBefore+src.Size {
			bytesDone = fileDoneBefore + src.Size
		}
		emitSnapshotProgress(control, snapshotProgress{
			Phase: "PACK", Detail: fmt.Sprintf("Packed %d / %d files", i+1, len(files)), CurrentFile: filepath.ToSlash(src.Rel), Percent: 5 + int(float64(bytesDone)/float64(max64(sourceBytes, 1))*78.0),
			FilesDone: i + 1, FilesTotal: len(files), BytesDone: bytesDone, BytesTotal: sourceBytes,
		})
	}

	emitSnapshotProgress(control, snapshotProgress{Phase: "FINALIZE", Detail: "Writing source handoff metadata...", Percent: 84, FilesDone: len(files), FilesTotal: len(files), BytesDone: sourceBytes, BytesTotal: sourceBytes})
	writeGenerated := func(name, body string) error {
		w, err := zw.Create(name)
		if err != nil {
			return err
		}
		_, err = w.Write([]byte(body))
		return err
	}
	if err := writeGenerated("SOURCE_HANDOFF.txt", sourceHandoffReadme(version, seq)); err != nil {
		cleanupPartial()
		return snapshotResult{Err: err}
	}
	if err := writeGenerated("ASSET_INDEX.txt", assetIndex); err != nil {
		cleanupPartial()
		return snapshotResult{Err: err}
	}
	packageFileCount := len(files) + 3 // source + SOURCE_HANDOFF + ASSET_INDEX + DEVSTATE
	manifest := snapshotManifest{
		Schema:                exportSchema,
		Project:               "Crawl Brawl",
		LauncherVersion:       launcherVersion,
		BuildVersion:          version,
		Sequence:              seq,
		SnapshotID:            fmt.Sprintf("%s-DEV%03d", version, seq),
		CreatedAt:             now.Format(time.RFC3339),
		HandoffProfile:        "SOURCE_ONLY",
		FileCount:             packageFileCount,
		SourceBytes:           sourceBytes,
		RuntimeAssetsIncluded: false,
		AssetIndexEntries:     assetCount,
		AssetBytesOmitted:     assetBytes,
		Compression:           "source/config text only; DEFLATE best-speed",
		Included: []string{
			"GDScript and source-like text files",
			"Godot scenes/resources/project configuration",
			"XML/JSON/config maps and small documentation",
			"tests/tools source when present",
			"launcher/native source",
			"ASSET_INDEX.txt path/size metadata",
		},
		Excluded: []string{
			"assets/ binary payloads (paths retained in ASSET_INDEX.txt)",
			"audio/video/fonts/images and imported runtime content",
			"Play Crawl Brawl.exe and other game/build binaries",
			"exports/ and previous snapshots",
			".godot/ import/cache data",
			".git/ and editor metadata",
			"logs, telemetry, recordings, crash dumps",
			"recovery snippets, backup.zip files, and machine-local launcher config",
			"individual source-like files larger than 16 MB",
		},
		Notes: "Compact browser/Codex source handoff. Apply edits back onto the full local project; this archive is not a runnable game build.",
	}
	manifestBytes, _ := json.MarshalIndent(manifest, "", "  ")
	mw, err := zw.Create("DEVSTATE.json")
	if err != nil {
		cleanupPartial()
		return snapshotResult{Err: err}
	}
	if _, err := mw.Write(append(manifestBytes, '\n')); err != nil {
		cleanupPartial()
		return snapshotResult{Err: err}
	}

	emitSnapshotProgress(control, snapshotProgress{Phase: "FINALIZE", Detail: "Closing ZIP central directory...", Percent: 86})
	if err := zw.Close(); err != nil {
		_ = out.Close()
		_ = os.Remove(tmpPath)
		return snapshotResult{Err: err}
	}
	if err := out.Close(); err != nil {
		_ = os.Remove(tmpPath)
		return snapshotResult{Err: err}
	}
	if cancelled(control) {
		_ = os.Remove(tmpPath)
		return snapshotResult{Err: errSnapshotCancelled}
	}
	if err := os.Rename(tmpPath, finalPath); err != nil {
		_ = os.Remove(tmpPath)
		return snapshotResult{Err: err}
	}

	info, err := os.Stat(finalPath)
	if err != nil {
		_ = os.Remove(finalPath)
		return snapshotResult{Err: err}
	}
	emitSnapshotProgress(control, snapshotProgress{Phase: "VERIFY", Detail: "Calculating SHA-256 checksum...", Percent: 88, BytesTotal: info.Size()})
	sha, err := fileSHA256WithProgress(finalPath, info.Size(), control)
	if err != nil {
		_ = os.Remove(finalPath)
		return snapshotResult{Err: err}
	}

	entry := snapshotEntry{
		Version:   version,
		Sequence:  seq,
		FileName:  name,
		CreatedAt: now.Format(time.RFC3339),
		SizeBytes: info.Size(),
		SHA256:    sha,
		FileCount: len(files) + 3,
	}
	if cancelled(control) {
		_ = os.Remove(finalPath)
		return snapshotResult{Err: errSnapshotCancelled}
	}
	emitSnapshotProgress(control, snapshotProgress{Phase: "PUBLISH", Detail: "Updating snapshot index...", Percent: 96})
	if err := saveSnapshotIndex(root, entry); err != nil {
		return snapshotResult{Err: err}
	}

	latestPath := filepath.Join(exportsDir, "CrawlBrawl_LATEST.zip")
	emitSnapshotProgress(control, snapshotProgress{Phase: "PUBLISH", Detail: "Publishing CrawlBrawl_LATEST.zip...", Percent: 98})
	if err := replaceLatestAlias(finalPath, latestPath); err != nil {
		return snapshotResult{Err: err}
	}
	latestText := fmt.Sprintf("%s\nSHA256 %s\nSnapshot %s-DEV%03d\nCreated %s\n", name, sha, version, seq, entry.CreatedAt)
	if err := os.WriteFile(filepath.Join(exportsDir, "CrawlBrawl_LATEST.txt"), []byte(latestText), 0644); err != nil {
		return snapshotResult{Err: err}
	}
	if err := os.WriteFile(finalPath+".sha256", []byte(sha+"  "+name+"\n"), 0644); err != nil {
		return snapshotResult{Err: err}
	}

	emitSnapshotProgress(control, snapshotProgress{
		Phase: "DONE", Detail: "Compact source handoff ZIP is ready.", Percent: 100,
		FilesDone: len(files), FilesTotal: len(files), BytesDone: sourceBytes, BytesTotal: sourceBytes,
	})
	return snapshotResult{Entry: entry, Archive: finalPath, LatestPath: latestPath}
}

func max64(a, b int64) int64 {
	if a > b {
		return a
	}
	return b
}

func isSnapshotCancelled(err error) bool { return errors.Is(err, errSnapshotCancelled) }

func latestSnapshotSummary(root string) string {
	idx := loadSnapshotIndex(root)
	if idx.Latest == "" || len(idx.Snapshots) == 0 {
		return "No development snapshot yet."
	}
	e := idx.Snapshots[0]
	mb := float64(e.SizeBytes) / (1024.0 * 1024.0)
	return fmt.Sprintf("Latest: %s  |  %.1f MB  |  %d files", e.FileName, mb, e.FileCount)
}
