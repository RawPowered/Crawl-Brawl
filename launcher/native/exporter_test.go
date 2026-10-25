package main

import (
	"archive/zip"
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestNormalizeBuildVersion(t *testing.T) {
	cases := map[string]string{
		"5":           "BV5",
		" bv5 ":       "BV5",
		"BV 6 hotfix": "BV-6-HOTFIX",
		"":            "BV1",
	}
	for in, want := range cases {
		if got := normalizeBuildVersion(in); got != want {
			t.Fatalf("normalizeBuildVersion(%q)=%q want %q", in, got, want)
		}
	}
}

func TestSnapshotIsCompactSourceHandoff(t *testing.T) {
	root := t.TempDir()
	mustWrite := func(rel string, body []byte) {
		path := filepath.Join(root, filepath.FromSlash(rel))
		if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, body, 0644); err != nil {
			t.Fatal(err)
		}
	}
	mustWrite("project.godot", []byte("[application]\n"))
	mustWrite("scripts/main.gd", []byte("extends Node\n"))
	mustWrite("systems/world_grid.gd", []byte("extends RefCounted\n"))
	mustWrite("scenes/game.tscn", []byte("[gd_scene]\n"))
	mustWrite("SysMap.xml", []byte("<system/>\n"))
	mustWrite("launcher/native/main.go", []byte("package main\n"))
	mustWrite("launcher/launcher_config.json", []byte(`{"godot_exe":"C:\\local"}`))
	mustWrite("assets/art/mob.png", []byte(strings.Repeat("PNGDATA", 4096)))
	mustWrite("assets/fonts/game.ttf", []byte(strings.Repeat("FONTDATA", 4096)))
	mustWrite("logs/gameplay_telemetry.ndjson", []byte("noise"))
	mustWrite("Play Crawl Brawl.exe", []byte(strings.Repeat("EXE", 4096)))
	mustWrite("scripts/backup.zip", []byte("backup"))
	mustWrite(".godot/cache", []byte("cache"))

	result := createDevelopmentSnapshot(root, "BV5", time.Date(2026, 8, 22, 10, 6, 0, 0, time.Local))
	if result.Err != nil {
		t.Fatal(result.Err)
	}
	if result.Entry.Sequence != 1 {
		t.Fatalf("sequence=%d", result.Entry.Sequence)
	}
	if !strings.Contains(result.Entry.FileName, "BV5_DEV001_SOURCE") {
		t.Fatalf("name=%s", result.Entry.FileName)
	}
	if _, err := os.Stat(result.LatestPath); err != nil {
		t.Fatalf("latest alias: %v", err)
	}

	zr, err := zip.OpenReader(result.Archive)
	if err != nil {
		t.Fatal(err)
	}
	defer zr.Close()
	names := map[string]bool{}
	var manifest snapshotManifest
	var assetIndex string
	for _, f := range zr.File {
		names[f.Name] = true
		if f.Name == "DEVSTATE.json" {
			r, err := f.Open()
			if err != nil {
				t.Fatal(err)
			}
			if err := json.NewDecoder(r).Decode(&manifest); err != nil {
				_ = r.Close()
				t.Fatal(err)
			}
			_ = r.Close()
		}
		if f.Name == "ASSET_INDEX.txt" {
			r, err := f.Open()
			if err != nil {
				t.Fatal(err)
			}
			b, err := io.ReadAll(r)
			_ = r.Close()
			if err != nil {
				t.Fatal(err)
			}
			assetIndex = string(b)
		}
	}
	for _, want := range []string{
		"project.godot", "scripts/main.gd", "systems/world_grid.gd", "scenes/game.tscn", "SysMap.xml",
		"launcher/native/main.go", "SOURCE_HANDOFF.txt", "ASSET_INDEX.txt", "DEVSTATE.json",
	} {
		if !names[want] {
			t.Fatalf("missing %s", want)
		}
	}
	for _, bad := range []string{
		"launcher/launcher_config.json", "assets/art/mob.png", "assets/fonts/game.ttf",
		"logs/gameplay_telemetry.ndjson", "Play Crawl Brawl.exe", "scripts/backup.zip", ".godot/cache",
	} {
		if names[bad] {
			t.Fatalf("heavy/runtime file present: %s", bad)
		}
	}
	if manifest.HandoffProfile != "SOURCE_ONLY" || manifest.RuntimeAssetsIncluded {
		t.Fatalf("unexpected manifest profile: %+v", manifest)
	}
	if manifest.AssetIndexEntries != 2 {
		t.Fatalf("asset index entries=%d want 2", manifest.AssetIndexEntries)
	}
	if !strings.Contains(assetIndex, "assets/art/mob.png") || !strings.Contains(assetIndex, "assets/fonts/game.ttf") {
		t.Fatalf("asset index missing omitted asset paths: %q", assetIndex)
	}

	result2 := createDevelopmentSnapshot(root, "BV5", time.Date(2026, 8, 22, 10, 7, 0, 0, time.Local))
	if result2.Err != nil {
		t.Fatal(result2.Err)
	}
	if result2.Entry.Sequence != 2 {
		t.Fatalf("second sequence=%d", result2.Entry.Sequence)
	}
}

func TestSnapshotProgressAndSourceCompression(t *testing.T) {
	root := t.TempDir()
	mustWrite := func(rel string, body []byte) {
		path := filepath.Join(root, filepath.FromSlash(rel))
		if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, body, 0644); err != nil {
			t.Fatal(err)
		}
	}
	mustWrite("project.godot", []byte("[application]\n"))
	mustWrite("scripts/main.gd", []byte(strings.Repeat("extends Node\n", 200)))
	mustWrite("assets/test.png", []byte(strings.Repeat("PNGDATA", 4096)))

	var percents []int
	phases := map[string]bool{}
	result := createDevelopmentSnapshotWithControl(root, "BV5", time.Now(), snapshotExportControl{
		Progress: func(p snapshotProgress) {
			percents = append(percents, p.Percent)
			phases[p.Phase] = true
		},
	})
	if result.Err != nil {
		t.Fatal(result.Err)
	}
	if len(percents) == 0 || percents[len(percents)-1] != 100 {
		t.Fatalf("progress did not reach 100: %v", percents)
	}
	for i := 1; i < len(percents); i++ {
		if percents[i] < percents[i-1] {
			t.Fatalf("progress regressed: %v", percents)
		}
	}
	for _, phase := range []string{"PREPARE", "SCAN", "PACK", "FINALIZE", "VERIFY", "PUBLISH", "DONE"} {
		if !phases[phase] {
			t.Fatalf("missing progress phase %s", phase)
		}
	}

	zr, err := zip.OpenReader(result.Archive)
	if err != nil {
		t.Fatal(err)
	}
	defer zr.Close()
	methods := map[string]uint16{}
	for _, f := range zr.File {
		methods[f.Name] = f.Method
	}
	if _, ok := methods["assets/test.png"]; ok {
		t.Fatalf("runtime asset unexpectedly packaged")
	}
	if methods["scripts/main.gd"] != zip.Deflate {
		t.Fatalf("gd method=%d want Deflate", methods["scripts/main.gd"])
	}
}

func TestSnapshotCancellationRemovesPartialAndPreservesSequence(t *testing.T) {
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, "project.godot"), []byte("[application]\n"), 0644); err != nil {
		t.Fatal(err)
	}
	if err := os.MkdirAll(filepath.Join(root, "scripts"), 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(root, "scripts", "large.gd"), []byte(strings.Repeat("var x = 1\n", 200000)), 0644); err != nil {
		t.Fatal(err)
	}

	cancel := false
	result := createDevelopmentSnapshotWithControl(root, "BV7", time.Now(), snapshotExportControl{
		Cancelled: func() bool { return cancel },
		Progress: func(p snapshotProgress) {
			if p.Phase == "PACK" {
				cancel = true
			}
		},
	})
	if !isSnapshotCancelled(result.Err) {
		t.Fatalf("expected cancellation, got %v", result.Err)
	}
	partials, err := filepath.Glob(filepath.Join(exportDirFor(root), "*.partial"))
	if err != nil {
		t.Fatal(err)
	}
	if len(partials) != 0 {
		t.Fatalf("partial files remain: %v", partials)
	}
	if next := nextSnapshotSequence(root, "BV7"); next != 1 {
		t.Fatalf("cancelled export consumed sequence; next=%d", next)
	}
}
