//go:build windows

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
	"unsafe"
)

const (
	appTitle = "Crawl Brawl Launcher"

	WM_DESTROY             = 0x0002
	WM_CLOSE               = 0x0010
	WM_COMMAND             = 0x0111
	WM_CTLCOLORSTATIC      = 0x0138
	WM_SETFONT             = 0x0030
	WM_APP                 = 0x8000
	WM_APP_VALIDATE_DONE   = WM_APP + 1
	WM_APP_GAME_DONE       = WM_APP + 2
	WM_APP_EXPORT_DONE     = WM_APP + 3
	WM_APP_EXPORT_PROGRESS = WM_APP + 4

	BN_CLICKED = 0

	WS_OVERLAPPEDWINDOW = 0x00CF0000
	WS_VISIBLE          = 0x10000000
	WS_CHILD            = 0x40000000
	WS_TABSTOP          = 0x00010000
	WS_VSCROLL          = 0x00200000
	WS_CLIPCHILDREN     = 0x02000000

	WS_EX_CLIENTEDGE = 0x00000200

	SS_LEFT   = 0x00000000
	SS_CENTER = 0x00000001

	BS_PUSHBUTTON    = 0x00000000
	BS_DEFPUSHBUTTON = 0x00000001
	BS_AUTOCHECKBOX  = 0x00000003

	ES_MULTILINE   = 0x0004
	ES_AUTOVSCROLL = 0x0040
	ES_READONLY    = 0x0800

	PBS_SMOOTH         = 0x00000001
	PBM_SETPOS         = 0x0402
	PBM_SETRANGE32     = 0x0406
	ICC_PROGRESS_CLASS = 0x00000020

	BST_UNCHECKED = 0
	BST_CHECKED   = 1
	BM_GETCHECK   = 0x00F0
	BM_SETCHECK   = 0x00F1

	SW_SHOW       = 5
	SW_SHOWNORMAL = 1

	COLOR_WINDOW = 5

	IDC_ARROW = 32512

	OFN_PATHMUSTEXIST = 0x00000800
	OFN_FILEMUSTEXIST = 0x00001000
	OFN_EXPLORER      = 0x00080000

	MB_OK              = 0x00000000
	MB_ICONERROR       = 0x00000010
	MB_ICONINFORMATION = 0x00000040

	ID_PLAY                 = 1001
	ID_VALIDATE             = 1002
	ID_EDITOR               = 1003
	ID_ENGINE               = 1004
	ID_FOLDER               = 1005
	ID_LOGS                 = 1006
	ID_COPY                 = 1007
	ID_EXPORT               = 1008
	ID_EXPORTS              = 1009
	ID_TELEMETRY            = 1010
	ID_VALIDATE_BEFORE_PLAY = 1011
	ID_AUTO_SNAPSHOT        = 1012
	ID_VERSION              = 1013
	ID_CANCEL_EXPORT        = 1014
)

type point struct{ X, Y int32 }
type msg struct {
	Hwnd     uintptr
	Message  uint32
	WParam   uintptr
	LParam   uintptr
	Time     uint32
	Pt       point
	LPrivate uint32
}

type wndClassEx struct {
	CbSize        uint32
	Style         uint32
	LpfnWndProc   uintptr
	CbClsExtra    int32
	CbWndExtra    int32
	HInstance     uintptr
	HIcon         uintptr
	HCursor       uintptr
	HbrBackground uintptr
	LpszMenuName  *uint16
	LpszClassName *uint16
	HIconSm       uintptr
}

type openFileName struct {
	LStructSize       uint32
	HwndOwner         uintptr
	HInstance         uintptr
	LpstrFilter       *uint16
	LpstrCustomFilter *uint16
	NMaxCustFilter    uint32
	NFilterIndex      uint32
	LpstrFile         *uint16
	NMaxFile          uint32
	LpstrFileTitle    *uint16
	NMaxFileTitle     uint32
	LpstrInitialDir   *uint16
	LpstrTitle        *uint16
	Flags             uint32
	NFileOffset       uint16
	NFileExtension    uint16
	LpstrDefExt       *uint16
	LcustData         uintptr
	LpfnHook          uintptr
	LpTemplateName    *uint16
	PvReserved        uintptr
	DwReserved        uint32
	FlagsEx           uint32
}

type initCommonControlsEx struct {
	DwSize uint32
	DwICC  uint32
}

type launcherConfig struct {
	GodotExe           string `json:"godot_exe"`
	Telemetry          bool   `json:"telemetry"`
	ValidateBeforePlay bool   `json:"validate_before_play"`
	BuildVersion       string `json:"build_version"`
	AutoSnapshot       bool   `json:"auto_snapshot_after_clean_run"`
}

type validationResult struct {
	Errors   []string
	ExitCode int
	Err      error
}

type gameResult struct {
	ExitCode      int
	RuntimeErrors []string
	Err           error
}

var (
	user32   = syscall.NewLazyDLL("user32.dll")
	kernel32 = syscall.NewLazyDLL("kernel32.dll")
	gdi32    = syscall.NewLazyDLL("gdi32.dll")
	comdlg32 = syscall.NewLazyDLL("comdlg32.dll")
	comctl32 = syscall.NewLazyDLL("comctl32.dll")

	procRegisterClassExW    = user32.NewProc("RegisterClassExW")
	procCreateWindowExW     = user32.NewProc("CreateWindowExW")
	procDefWindowProcW      = user32.NewProc("DefWindowProcW")
	procShowWindow          = user32.NewProc("ShowWindow")
	procUpdateWindow        = user32.NewProc("UpdateWindow")
	procGetMessageW         = user32.NewProc("GetMessageW")
	procTranslateMessage    = user32.NewProc("TranslateMessage")
	procDispatchMessageW    = user32.NewProc("DispatchMessageW")
	procPostQuitMessage     = user32.NewProc("PostQuitMessage")
	procSendMessageW        = user32.NewProc("SendMessageW")
	procSetWindowTextW      = user32.NewProc("SetWindowTextW")
	procEnableWindow        = user32.NewProc("EnableWindow")
	procPostMessageW        = user32.NewProc("PostMessageW")
	procMessageBoxW         = user32.NewProc("MessageBoxW")
	procLoadCursorW         = user32.NewProc("LoadCursorW")
	procSetForegroundWindow = user32.NewProc("SetForegroundWindow")
	procSetProcessDPIAware  = user32.NewProc("SetProcessDPIAware")

	procGetModuleHandleW     = kernel32.NewProc("GetModuleHandleW")
	procCreateFontW          = gdi32.NewProc("CreateFontW")
	procSetTextColor         = gdi32.NewProc("SetTextColor")
	procSetBkColor           = gdi32.NewProc("SetBkColor")
	procSetBkMode            = gdi32.NewProc("SetBkMode")
	procCreateSolidBrush     = gdi32.NewProc("CreateSolidBrush")
	procGetOpenFileNameW     = comdlg32.NewProc("GetOpenFileNameW")
	procInitCommonControlsEx = comctl32.NewProc("InitCommonControlsEx")
)

var (
	mainHwnd               uintptr
	statusTitleHwnd        uintptr
	statusDetailHwnd       uintptr
	enginePathHwnd         uintptr
	diagnosticsHwnd        uintptr
	activityHwnd           uintptr
	btnPlay                uintptr
	btnValidate            uintptr
	btnEditor              uintptr
	btnEngine              uintptr
	btnFolder              uintptr
	btnLogs                uintptr
	btnCopy                uintptr
	btnExport              uintptr
	btnExports             uintptr
	telemetryHwnd          uintptr
	validateBeforePlayHwnd uintptr
	autoSnapshotHwnd       uintptr
	buildVersionHwnd       uintptr
	exportSummaryHwnd      uintptr
	exportProgressHwnd     uintptr
	exportProgressTextHwnd uintptr
	btnCancelExport        uintptr

	fontTitle  uintptr
	fontHeader uintptr
	fontNormal uintptr
	fontSmall  uintptr

	brushBg    uintptr
	brushPanel uintptr

	projectRoot      string
	exeDir           string
	launcherDir      string
	configPath       string
	importLogPath    string
	runtimeLogPath   string
	launcherLogPath  string
	telemetryLogPath string
	godotExe         string

	appBusy       bool
	gameRunning   bool
	pendingPlay   bool
	exportRunning bool
	exportCancel  atomic.Bool

	resultMu              sync.Mutex
	pendingValidation     validationResult
	pendingGame           gameResult
	pendingExport         snapshotResult
	pendingExportProgress snapshotProgress
)

func rgb(r, g, b byte) uintptr { return uintptr(r) | uintptr(g)<<8 | uintptr(b)<<16 }

var (
	colorBg     = rgb(10, 16, 23)
	colorPanel  = rgb(18, 27, 38)
	colorText   = rgb(232, 239, 246)
	colorMuted  = rgb(142, 158, 176)
	colorOrange = rgb(242, 140, 0)
	colorGreen  = rgb(74, 216, 124)
	colorRed    = rgb(255, 91, 105)
	colorYellow = rgb(247, 200, 74)
	colorCyan   = rgb(83, 213, 242)
)

func u16(s string) *uint16 {
	p, _ := syscall.UTF16PtrFromString(s)
	return p
}

func loword(v uintptr) uint16 { return uint16(v & 0xffff) }
func hiword(v uintptr) uint16 { return uint16((v >> 16) & 0xffff) }

func setText(hwnd uintptr, text string) {
	procSetWindowTextW.Call(hwnd, uintptr(unsafe.Pointer(u16(text))))
}

func send(hwnd uintptr, m uint32, w, l uintptr) uintptr {
	r, _, _ := procSendMessageW.Call(hwnd, uintptr(m), w, l)
	return r
}

func isChecked(hwnd uintptr) bool { return send(hwnd, BM_GETCHECK, 0, 0) == BST_CHECKED }
func setChecked(hwnd uintptr, checked bool) {
	v := uintptr(BST_UNCHECKED)
	if checked {
		v = BST_CHECKED
	}
	send(hwnd, BM_SETCHECK, v, 0)
}

func enable(hwnd uintptr, on bool) {
	v := uintptr(0)
	if on {
		v = 1
	}
	procEnableWindow.Call(hwnd, v)
}

func messageBox(text, title string, flags uintptr) {
	procMessageBoxW.Call(mainHwnd, uintptr(unsafe.Pointer(u16(text))), uintptr(unsafe.Pointer(u16(title))), flags)
}

func logEvent(format string, args ...interface{}) {
	if launcherLogPath == "" {
		return
	}
	_ = os.MkdirAll(filepath.Dir(launcherLogPath), 0755)
	f, err := os.OpenFile(launcherLogPath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
	if err != nil {
		return
	}
	defer f.Close()
	line := fmt.Sprintf(format, args...)
	fmt.Fprintf(f, "[%s] %s\r\n", time.Now().Format("2006-01-02 15:04:05"), line)
}

func appendActivity(text string) {
	stamp := time.Now().Format("15:04:05")
	// EM_SETSEL(-1,-1) + EM_REPLACESEL
	const EM_SETSEL = 0x00B1
	const EM_REPLACESEL = 0x00C2
	send(activityHwnd, EM_SETSEL, ^uintptr(0), ^uintptr(0))
	line := fmt.Sprintf("[%s] %s\r\n", stamp, text)
	send(activityHwnd, EM_REPLACESEL, 0, uintptr(unsafe.Pointer(u16(line))))
}

func setStatus(title, detail string, color uintptr) {
	setText(statusTitleHwnd, title)
	setText(statusDetailHwnd, detail)
	// Color is selected during WM_CTLCOLORSTATIC; keep a simple status prefix cache via window text.
	_ = color
}

func setBusy(b bool) {
	appBusy = b
	enable(btnPlay, !b && !gameRunning)
	enable(btnValidate, !b)
	enable(btnEditor, !b)
	enable(btnEngine, !b)
	enable(btnExport, !b && !gameRunning)
	enable(btnExports, !b)
	enable(buildVersionHwnd, !b)
	enable(btnCancelExport, exportRunning)
}

func setExportProgress(percent int, detail string) {
	if percent < 0 {
		percent = 0
	}
	if percent > 100 {
		percent = 100
	}
	if exportProgressHwnd != 0 {
		send(exportProgressHwnd, PBM_SETPOS, uintptr(percent), 0)
	}
	if exportProgressTextHwnd != 0 {
		setText(exportProgressTextHwnd, detail)
	}
}

func createFont(height int32, weight int32, face string) uintptr {
	r, _, _ := procCreateFontW.Call(
		uintptr(height), 0, 0, 0, uintptr(weight), 0, 0, 0,
		1, 0, 0, 5, 0, uintptr(unsafe.Pointer(u16(face))),
	)
	return r
}

func createControl(exStyle uintptr, class, text string, style uintptr, x, y, w, h int32, parent uintptr, id int) uintptr {
	hwnd, _, _ := procCreateWindowExW.Call(
		exStyle,
		uintptr(unsafe.Pointer(u16(class))),
		uintptr(unsafe.Pointer(u16(text))),
		style,
		uintptr(x), uintptr(y), uintptr(w), uintptr(h),
		parent, uintptr(id), 0, 0,
	)
	return hwnd
}

func applyFont(hwnd, font uintptr) { send(hwnd, WM_SETFONT, font, 1) }

func resolveProjectRoot() string {
	p, err := os.Executable()
	if err != nil {
		return ""
	}
	p, _ = filepath.Abs(p)
	exeDir = filepath.Dir(p)
	candidates := []string{exeDir, filepath.Dir(exeDir)}
	for _, c := range candidates {
		if _, err := os.Stat(filepath.Join(c, "project.godot")); err == nil {
			return c
		}
	}
	return exeDir
}

func configDefaults() launcherConfig {
	return launcherConfig{Telemetry: true, ValidateBeforePlay: true, BuildVersion: "BV5", AutoSnapshot: false}
}

func loadConfig() launcherConfig {
	c := configDefaults()
	data, err := os.ReadFile(configPath)
	if err != nil {
		return c
	}
	_ = json.Unmarshal(data, &c)
	return c
}

func saveConfig() {
	version := normalizeBuildVersion(getWindowText(buildVersionHwnd))
	setText(buildVersionHwnd, version)
	c := launcherConfig{
		GodotExe:           godotExe,
		Telemetry:          isChecked(telemetryHwnd),
		ValidateBeforePlay: isChecked(validateBeforePlayHwnd),
		BuildVersion:       version,
		AutoSnapshot:       isChecked(autoSnapshotHwnd),
	}
	data, _ := json.MarshalIndent(c, "", "  ")
	_ = os.MkdirAll(filepath.Dir(configPath), 0755)
	_ = os.WriteFile(configPath, data, 0644)
}

func resolveGodot(saved string) string {
	candidates := []string{
		saved,
		os.Getenv("CRAWL_BRAWL_GODOT"),
		filepath.Join(projectRoot, "Godot_v4.7.1-stable_win64.exe"),
		filepath.Join(projectRoot, "tools", "godot", "Godot_v4.7.1-stable_win64.exe"),
	}
	for _, p := range candidates {
		if p == "" {
			continue
		}
		if st, err := os.Stat(p); err == nil && !st.IsDir() {
			abs, _ := filepath.Abs(p)
			return abs
		}
	}
	for _, name := range []string{"godot.exe", "Godot_v4.7.1-stable_win64.exe"} {
		if p, err := exec.LookPath(name); err == nil {
			return p
		}
	}
	return ""
}

func buildLogPaths() {
	launcherDir = filepath.Join(projectRoot, "launcher")
	logsDir := filepath.Join(projectRoot, "logs", "launcher")
	_ = os.MkdirAll(launcherDir, 0755)
	_ = os.MkdirAll(logsDir, 0755)
	configPath = filepath.Join(launcherDir, "launcher_config.json")
	importLogPath = filepath.Join(logsDir, "import.log")
	runtimeLogPath = filepath.Join(logsDir, "runtime.log")
	launcherLogPath = filepath.Join(logsDir, "launcher.log")
	telemetryLogPath = filepath.Join(projectRoot, "logs", "gameplay_telemetry.ndjson")
}

var locationRe = regexp.MustCompile(`\((res://[^\)]+)\)`)

func parseScriptErrors(path string) []string {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil
	}
	text := strings.ReplaceAll(string(data), "\r\n", "\n")
	lines := strings.Split(text, "\n")
	out := make([]string, 0)
	for i, line := range lines {
		if !strings.Contains(line, "SCRIPT ERROR:") {
			continue
		}
		msg := strings.TrimSpace(strings.TrimPrefix(strings.TrimSpace(line), "SCRIPT ERROR:"))
		loc := ""
		for j := i + 1; j < len(lines) && j <= i+3; j++ {
			if m := locationRe.FindStringSubmatch(lines[j]); len(m) == 2 {
				loc = m[1]
				break
			}
		}
		if loc != "" {
			out = append(out, fmt.Sprintf("%s\r\n  %s", msg, loc))
		} else {
			out = append(out, msg)
		}
	}
	return out
}

func diagnosticsText(errors []string) string {
	if len(errors) == 0 {
		return "No script errors detected.\r\n\r\nBuild validation has not found a GDScript parse/compile failure."
	}
	var b strings.Builder
	fmt.Fprintf(&b, "%d script error(s) detected:\r\n\r\n", len(errors))
	for i, e := range errors {
		fmt.Fprintf(&b, "%d. %s\r\n\r\n", i+1, e)
	}
	return b.String()
}

func commandHidden(name string, args ...string) *exec.Cmd {
	cmd := exec.Command(name, args...)
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
	return cmd
}

func runValidationAsync() {
	if appBusy {
		return
	}
	if godotExe == "" {
		setStatus("GODOT NOT CONFIGURED", "Choose Godot with ENGINE...", colorRed)
		messageBox("Godot could not be found. Click ENGINE... and select your Godot executable.", appTitle, MB_OK|MB_ICONERROR)
		return
	}
	if _, err := os.Stat(filepath.Join(projectRoot, "project.godot")); err != nil {
		setStatus("PROJECT NOT FOUND", "Place the launcher beside project.godot.", colorRed)
		return
	}
	setBusy(true)
	setStatus("VALIDATING BUILD", "Godot is importing resources and compiling scripts...", colorYellow)
	appendActivity("Build validation started.")
	logEvent("Validation started. Engine=%s Project=%s", godotExe, projectRoot)

	go func() {
		_ = os.Remove(importLogPath)
		var stdout, stderr bytes.Buffer
		cmd := commandHidden(godotExe, "--headless", "--path", projectRoot, "--import", "--log-file", importLogPath)
		cmd.Dir = projectRoot
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		err := cmd.Run()
		exitCode := 0
		if err != nil {
			if ee, ok := err.(*exec.ExitError); ok {
				exitCode = ee.ExitCode()
			} else {
				exitCode = -1
			}
		}
		if _, statErr := os.Stat(importLogPath); statErr != nil {
			_ = os.WriteFile(importLogPath, append(stdout.Bytes(), stderr.Bytes()...), 0644)
		}
		r := validationResult{Errors: parseScriptErrors(importLogPath), ExitCode: exitCode, Err: err}
		resultMu.Lock()
		pendingValidation = r
		resultMu.Unlock()
		procPostMessageW.Call(mainHwnd, WM_APP_VALIDATE_DONE, 0, 0)
	}()
}

func handleValidationDone() {
	resultMu.Lock()
	r := pendingValidation
	resultMu.Unlock()
	setBusy(false)
	setText(diagnosticsHwnd, diagnosticsText(r.Errors))
	if len(r.Errors) > 0 {
		setStatus(fmt.Sprintf("BUILD BLOCKED - %d SCRIPT ERROR(S)", len(r.Errors)), "Open Build Diagnostics for exact file/line information.", colorRed)
		appendActivity(fmt.Sprintf("Validation found %d script error(s).", len(r.Errors)))
		logEvent("Validation blocked: %d script error(s), GodotExit=%d", len(r.Errors), r.ExitCode)
		pendingPlay = false
		return
	}
	if r.ExitCode != 0 {
		setStatus(fmt.Sprintf("VALIDATION FAILED - EXIT %d", r.ExitCode), "Godot returned a non-zero import exit code.", colorRed)
		appendActivity(fmt.Sprintf("Validation failed with exit code %d.", r.ExitCode))
		pendingPlay = false
		return
	}
	setStatus("BUILD VALID", "No GDScript compiler errors detected.", colorGreen)
	appendActivity("Build validation passed.")
	logEvent("Validation passed.")
	if pendingPlay {
		pendingPlay = false
		startGameAsync()
	}
}

func requestPlay() {
	if appBusy || gameRunning {
		return
	}
	saveConfig()
	if isChecked(validateBeforePlayHwnd) {
		pendingPlay = true
		runValidationAsync()
		return
	}
	startGameAsync()
}

func startGameAsync() {
	if godotExe == "" {
		return
	}
	_ = os.Remove(runtimeLogPath)
	args := []string{"--path", projectRoot, "--log-file", runtimeLogPath}
	if isChecked(telemetryHwnd) {
		args = append(args, "--", "--crawl-telemetry")
	}
	cmd := exec.Command(godotExe, args...)
	cmd.Dir = projectRoot
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: false}
	env := os.Environ()
	if isChecked(telemetryHwnd) {
		env = append(env, "CRAWL_BRAWL_TELEMETRY=1", "CRAWL_BRAWL_TELEMETRY_LOG="+telemetryLogPath)
	} else {
		env = append(env, "CRAWL_BRAWL_TELEMETRY=0")
	}
	cmd.Env = env
	err := cmd.Start()
	if err != nil {
		setStatus("LAUNCH FAILED", err.Error(), colorRed)
		appendActivity("Could not start Godot: " + err.Error())
		return
	}
	gameRunning = true
	enable(btnPlay, false)
	enable(btnExport, false)
	setStatus("CRAWL BRAWL RUNNING", "Game process started. The launcher can remain open.", colorGreen)
	appendActivity(fmt.Sprintf("Game started (PID %d).", cmd.Process.Pid))
	logEvent("Game started. PID=%d", cmd.Process.Pid)
	go func() {
		err := cmd.Wait()
		exitCode := 0
		if err != nil {
			if ee, ok := err.(*exec.ExitError); ok {
				exitCode = ee.ExitCode()
			} else {
				exitCode = -1
			}
		}
		r := gameResult{ExitCode: exitCode, RuntimeErrors: parseScriptErrors(runtimeLogPath), Err: err}
		resultMu.Lock()
		pendingGame = r
		resultMu.Unlock()
		procPostMessageW.Call(mainHwnd, WM_APP_GAME_DONE, 0, 0)
	}()
}

func handleGameDone() {
	resultMu.Lock()
	r := pendingGame
	resultMu.Unlock()
	gameRunning = false
	enable(btnPlay, true)
	enable(btnExport, true)
	if len(r.RuntimeErrors) > 0 {
		setText(diagnosticsHwnd, diagnosticsText(r.RuntimeErrors))
		setStatus(fmt.Sprintf("GAME CLOSED - %d RUNTIME SCRIPT ERROR(S)", len(r.RuntimeErrors)), "Review Runtime Diagnostics before the next run.", colorRed)
		appendActivity(fmt.Sprintf("Game closed with %d runtime script error(s).", len(r.RuntimeErrors)))
		logEvent("Game closed with runtime script errors. Exit=%d Errors=%d", r.ExitCode, len(r.RuntimeErrors))
	} else if r.ExitCode != 0 {
		setStatus(fmt.Sprintf("GAME CLOSED - EXIT %d", r.ExitCode), "Godot returned a non-zero process exit code.", colorRed)
		appendActivity(fmt.Sprintf("Game exited with code %d.", r.ExitCode))
		logEvent("Game exited non-zero. Exit=%d", r.ExitCode)
	} else {
		setStatus("READY", "Crawl Brawl closed normally.", colorCyan)
		appendActivity("Game closed normally.")
		logEvent("Game closed normally.")
		if isChecked(autoSnapshotHwnd) {
			appendActivity("Auto source handoff requested after clean run.")
			runExportAsync(true)
		}
	}
}

func refreshExportSummary() {
	if exportSummaryHwnd == 0 {
		return
	}
	version := normalizeBuildVersion(getWindowText(buildVersionHwnd))
	next := nextSnapshotSequence(projectRoot, version)
	summary := fmt.Sprintf("Next: %s DEV%03d   |   %s", version, next, latestSnapshotSummary(projectRoot))
	setText(exportSummaryHwnd, summary)
}

func runExportAsync(automatic bool) {
	if appBusy || gameRunning || exportRunning {
		return
	}
	version := normalizeBuildVersion(getWindowText(buildVersionHwnd))
	setText(buildVersionHwnd, version)
	saveConfig()
	exportRunning = true
	exportCancel.Store(false)
	setBusy(true)
	setExportProgress(0, "Preparing compact source handoff...")
	if automatic {
		setStatus("AUTO-SAVING SOURCE HANDOFF", "Packaging editable source only; runtime assets stay local...", colorYellow)
	} else {
		setStatus("EXPORTING SOURCE HANDOFF", "Packaging editable source only; runtime assets stay local...", colorYellow)
	}
	appendActivity(fmt.Sprintf("Source handoff started: %s DEV%03d", version, nextSnapshotSequence(projectRoot, version)))
	logEvent("Source handoff started. Version=%s Automatic=%t", version, automatic)

	go func() {
		lastPercent := -1
		lastPhase := ""
		lastPost := time.Time{}
		control := snapshotExportControl{
			Cancelled: func() bool { return exportCancel.Load() },
			Progress: func(p snapshotProgress) {
				now := time.Now()
				if p.Percent == lastPercent && p.Phase == lastPhase && now.Sub(lastPost) < 120*time.Millisecond {
					return
				}
				lastPercent = p.Percent
				lastPhase = p.Phase
				lastPost = now
				resultMu.Lock()
				pendingExportProgress = p
				resultMu.Unlock()
				procPostMessageW.Call(mainHwnd, WM_APP_EXPORT_PROGRESS, 0, 0)
			},
		}
		r := createDevelopmentSnapshotWithControl(projectRoot, version, time.Now(), control)
		resultMu.Lock()
		pendingExport = r
		resultMu.Unlock()
		procPostMessageW.Call(mainHwnd, WM_APP_EXPORT_DONE, 0, 0)
	}()
}

func cancelExport() {
	if !exportRunning {
		return
	}
	exportCancel.Store(true)
	enable(btnCancelExport, false)
	setStatus("CANCELLING SOURCE HANDOFF", "Finishing the current disk operation and removing the partial archive...", colorYellow)
	appendActivity("Source handoff cancellation requested.")
	logEvent("Source handoff cancellation requested.")
}

func handleExportProgress() {
	resultMu.Lock()
	p := pendingExportProgress
	resultMu.Unlock()
	mbDone := float64(p.BytesDone) / (1024.0 * 1024.0)
	mbTotal := float64(p.BytesTotal) / (1024.0 * 1024.0)
	detail := p.Detail
	if p.Phase == "PACK" && p.FilesTotal > 0 {
		detail = fmt.Sprintf("%s  |  %.1f / %.1f MB", p.Detail, mbDone, mbTotal)
		if p.CurrentFile != "" {
			file := p.CurrentFile
			if len(file) > 78 {
				file = "..." + file[len(file)-75:]
			}
			detail += "  |  " + file
		}
	} else if p.Phase == "VERIFY" && p.BytesTotal > 0 {
		detail = fmt.Sprintf("%s  |  %.1f / %.1f MB", p.Detail, mbDone, mbTotal)
	}
	setExportProgress(p.Percent, fmt.Sprintf("%d%%  //  %s  //  %s", p.Percent, p.Phase, detail))
}

func handleExportDone() {
	resultMu.Lock()
	r := pendingExport
	resultMu.Unlock()
	exportRunning = false
	setBusy(false)
	enable(btnCancelExport, false)
	if r.Err != nil {
		if isSnapshotCancelled(r.Err) {
			setStatus("SOURCE HANDOFF CANCELLED", "Partial export removed. The next DEV number was not consumed.", colorYellow)
			appendActivity("Source handoff cancelled cleanly.")
			logEvent("Source handoff cancelled.")
			setExportProgress(0, "Export cancelled. No partial handoff retained.")
			return
		}
		setStatus("SOURCE HANDOFF FAILED", r.Err.Error(), colorRed)
		appendActivity("Source handoff failed: " + r.Err.Error())
		logEvent("Source handoff failed: %v", r.Err)
		messageBox("The source handoff ZIP could not be created.\r\n\r\n"+r.Err.Error(), appTitle, MB_OK|MB_ICONERROR)
		return
	}
	mb := float64(r.Entry.SizeBytes) / (1024.0 * 1024.0)
	setExportProgress(100, fmt.Sprintf("100%%  //  DONE  //  %s  //  %.1f MB  //  %d files", r.Entry.FileName, mb, r.Entry.FileCount))
	setStatus(fmt.Sprintf("SOURCE HANDOFF SAVED - %s DEV%03d", r.Entry.Version, r.Entry.Sequence), fmt.Sprintf("%s  |  %.1f MB  |  stable alias: CrawlBrawl_LATEST.zip", r.Entry.FileName, mb), colorGreen)
	appendActivity(fmt.Sprintf("Source handoff ready: %s (%.1f MB, %d files)", r.Entry.FileName, mb, r.Entry.FileCount))
	logEvent("Source handoff complete. File=%s SHA256=%s Files=%d Size=%d", r.Entry.FileName, r.Entry.SHA256, r.Entry.FileCount, r.Entry.SizeBytes)
	refreshExportSummary()
}

func openEditor() {
	if godotExe == "" {
		messageBox("Choose the Godot executable first.", appTitle, MB_OK|MB_ICONERROR)
		return
	}
	cmd := exec.Command(godotExe, "--editor", "--path", projectRoot)
	cmd.Dir = projectRoot
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: false}
	if err := cmd.Start(); err != nil {
		messageBox(err.Error(), "Could not open Godot", MB_OK|MB_ICONERROR)
	}
}

func openFolder(path string) {
	if _, err := os.Stat(path); err != nil {
		_ = os.MkdirAll(path, 0755)
	}
	cmd := commandHidden("explorer.exe", path)
	_ = cmd.Start()
}

func copyDiagnostics() {
	// Use Windows' built-in clip.exe; no PowerShell/VBS dependency.
	text := getWindowText(diagnosticsHwnd)
	cmd := commandHidden("clip.exe")
	cmd.Stdin = strings.NewReader(text)
	if err := cmd.Run(); err != nil {
		messageBox("Could not copy diagnostics to the clipboard.", appTitle, MB_OK|MB_ICONERROR)
		return
	}
	appendActivity("Diagnostics copied to clipboard.")
}

func getWindowText(hwnd uintptr) string {
	procGetWindowTextLengthW := user32.NewProc("GetWindowTextLengthW")
	procGetWindowTextW := user32.NewProc("GetWindowTextW")
	n, _, _ := procGetWindowTextLengthW.Call(hwnd)
	if n == 0 {
		return ""
	}
	buf := make([]uint16, int(n)+1)
	procGetWindowTextW.Call(hwnd, uintptr(unsafe.Pointer(&buf[0])), n+1)
	return syscall.UTF16ToString(buf)
}

func chooseGodot() {
	fileBuf := make([]uint16, 32768)
	if godotExe != "" {
		s, _ := syscall.UTF16FromString(godotExe)
		copy(fileBuf, s)
	}
	filter := "Godot Executable (*.exe)\x00*.exe\x00All Files (*.*)\x00*.*\x00\x00"
	filter16 := utf16WithNuls(filter)
	title := u16("Select Godot Engine executable")
	initialDir := u16(projectRoot)
	ofn := openFileName{}
	ofn.LStructSize = uint32(unsafe.Sizeof(ofn))
	ofn.HwndOwner = mainHwnd
	ofn.LpstrFilter = &filter16[0]
	ofn.NFilterIndex = 1
	ofn.LpstrFile = &fileBuf[0]
	ofn.NMaxFile = uint32(len(fileBuf))
	ofn.LpstrInitialDir = initialDir
	ofn.LpstrTitle = title
	ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_EXPLORER
	r, _, _ := procGetOpenFileNameW.Call(uintptr(unsafe.Pointer(&ofn)))
	if r == 0 {
		return
	}
	p := syscall.UTF16ToString(fileBuf)
	if st, err := os.Stat(p); err == nil && !st.IsDir() {
		godotExe = p
		setText(enginePathHwnd, godotExe)
		saveConfig()
		setStatus("ENGINE READY", "Godot executable updated.", colorGreen)
		appendActivity("Godot engine selected: " + godotExe)
	}
}

func utf16WithNuls(s string) []uint16 {
	// Interpret literal \x00 sequences supplied above as embedded NULs.
	s = strings.ReplaceAll(s, "\\x00", "\x00")
	r := []rune(s)
	out := make([]uint16, 0, len(r)+1)
	for _, ch := range r {
		out = append(out, uint16(ch))
	}
	if len(out) == 0 || out[len(out)-1] != 0 {
		out = append(out, 0)
	}
	return out
}

func wndProc(hwnd uintptr, message uint32, wParam, lParam uintptr) uintptr {
	switch message {
	case WM_COMMAND:
		id := int(loword(wParam))
		code := hiword(wParam)
		if code == BN_CLICKED {
			switch id {
			case ID_PLAY:
				requestPlay()
			case ID_VALIDATE:
				runValidationAsync()
			case ID_EDITOR:
				openEditor()
			case ID_ENGINE:
				chooseGodot()
			case ID_FOLDER:
				openFolder(projectRoot)
			case ID_LOGS:
				openFolder(filepath.Join(projectRoot, "logs", "launcher"))
			case ID_COPY:
				copyDiagnostics()
			case ID_EXPORT:
				runExportAsync(false)
			case ID_CANCEL_EXPORT:
				cancelExport()
			case ID_EXPORTS:
				openFolder(exportDirFor(projectRoot))
			case ID_TELEMETRY, ID_VALIDATE_BEFORE_PLAY, ID_AUTO_SNAPSHOT:
				saveConfig()
			}
		}
		return 0
	case WM_APP_VALIDATE_DONE:
		handleValidationDone()
		return 0
	case WM_APP_GAME_DONE:
		handleGameDone()
		return 0
	case WM_APP_EXPORT_PROGRESS:
		handleExportProgress()
		return 0
	case WM_APP_EXPORT_DONE:
		handleExportDone()
		return 0
	case WM_CTLCOLORSTATIC:
		hdc := wParam
		child := lParam
		textColor := colorText
		if child == statusDetailHwnd || child == enginePathHwnd {
			textColor = colorMuted
		}
		if child == statusTitleHwnd {
			t := getWindowText(statusTitleHwnd)
			switch {
			case strings.Contains(t, "BLOCKED"), strings.Contains(t, "FAILED"), strings.Contains(t, "NOT FOUND"), strings.Contains(t, "NOT CONFIGURED"), strings.Contains(t, "ERROR"):
				textColor = colorRed
			case strings.Contains(t, "VALIDATING"), strings.Contains(t, "EXPORTING"), strings.Contains(t, "SAVING"), strings.Contains(t, "CANCELLING"):
				textColor = colorYellow
			case strings.Contains(t, "VALID"), strings.Contains(t, "RUNNING"), strings.Contains(t, "READY"):
				textColor = colorGreen
			default:
				textColor = colorCyan
			}
		}
		procSetTextColor.Call(hdc, textColor)
		procSetBkColor.Call(hdc, colorPanel)
		procSetBkMode.Call(hdc, 1) // TRANSPARENT
		return brushPanel
	case WM_CLOSE:
		if exportRunning {
			exportCancel.Store(true)
		}
		saveConfig()
		procDefWindowProcW.Call(hwnd, uintptr(message), wParam, lParam)
		return 0
	case WM_DESTROY:
		procPostQuitMessage.Call(0)
		return 0
	}
	r, _, _ := procDefWindowProcW.Call(hwnd, uintptr(message), wParam, lParam)
	return r
}

func initUI() error {
	procSetProcessDPIAware.Call()
	icc := initCommonControlsEx{DwSize: uint32(unsafe.Sizeof(initCommonControlsEx{})), DwICC: ICC_PROGRESS_CLASS}
	procInitCommonControlsEx.Call(uintptr(unsafe.Pointer(&icc)))
	hInstance, _, _ := procGetModuleHandleW.Call(0)
	cursor, _, _ := procLoadCursorW.Call(0, IDC_ARROW)
	brushBg, _, _ = procCreateSolidBrush.Call(colorBg)
	brushPanel, _, _ = procCreateSolidBrush.Call(colorPanel)

	className := u16("CrawlBrawlNativeLauncherClass")
	wc := wndClassEx{
		CbSize:        uint32(unsafe.Sizeof(wndClassEx{})),
		LpfnWndProc:   syscall.NewCallback(wndProc),
		HInstance:     hInstance,
		HCursor:       cursor,
		HbrBackground: brushBg,
		LpszClassName: className,
	}
	atom, _, e := procRegisterClassExW.Call(uintptr(unsafe.Pointer(&wc)))
	if atom == 0 {
		return fmt.Errorf("RegisterClassExW failed: %v", e)
	}

	mainHwnd, _, e = procCreateWindowExW.Call(
		0, uintptr(unsafe.Pointer(className)), uintptr(unsafe.Pointer(u16(appTitle))),
		WS_OVERLAPPEDWINDOW|WS_VISIBLE|WS_CLIPCHILDREN,
		100, 40, 1040, 950, 0, 0, hInstance, 0,
	)
	if mainHwnd == 0 {
		return fmt.Errorf("CreateWindowExW failed: %v", e)
	}

	fontTitle = createFont(-30, 700, "Segoe UI")
	fontHeader = createFont(-20, 700, "Segoe UI")
	fontNormal = createFont(-17, 400, "Segoe UI")
	fontSmall = createFont(-14, 400, "Segoe UI")

	title := createControl(0, "STATIC", "CRAWL BRAWL", WS_CHILD|WS_VISIBLE|SS_LEFT, 30, 22, 500, 42, mainHwnd, 0)
	applyFont(title, fontTitle)
	subtitle := createControl(0, "STATIC", "GATO GODMODE GAMES  |  NATIVE LAUNCHER v3.2  |  SOURCE HANDOFF MANAGER", WS_CHILD|WS_VISIBLE|SS_LEFT, 32, 66, 760, 26, mainHwnd, 0)
	applyFont(subtitle, fontSmall)

	statusPanel := createControl(0, "STATIC", "", WS_CHILD|WS_VISIBLE, 26, 108, 974, 96, mainHwnd, 0)
	_ = statusPanel
	statusTitleHwnd = createControl(0, "STATIC", "READY", WS_CHILD|WS_VISIBLE|SS_LEFT, 46, 124, 920, 32, mainHwnd, 0)
	applyFont(statusTitleHwnd, fontHeader)
	statusDetailHwnd = createControl(0, "STATIC", "Native Windows x64 launcher. No VBS or PowerShell front end required.", WS_CHILD|WS_VISIBLE|SS_LEFT, 46, 160, 920, 26, mainHwnd, 0)
	applyFont(statusDetailHwnd, fontNormal)

	btnPlay = createControl(0, "BUTTON", "PLAY CRAWL BRAWL", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_DEFPUSHBUTTON, 28, 222, 310, 56, mainHwnd, ID_PLAY)
	btnValidate = createControl(0, "BUTTON", "VALIDATE BUILD", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_PUSHBUTTON, 350, 222, 200, 56, mainHwnd, ID_VALIDATE)
	btnEditor = createControl(0, "BUTTON", "OPEN IN GODOT", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_PUSHBUTTON, 562, 222, 200, 56, mainHwnd, ID_EDITOR)
	btnEngine = createControl(0, "BUTTON", "ENGINE...", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_PUSHBUTTON, 774, 222, 200, 56, mainHwnd, ID_ENGINE)
	for _, h := range []uintptr{btnPlay, btnValidate, btnEditor, btnEngine} {
		applyFont(h, fontNormal)
	}

	validateBeforePlayHwnd = createControl(0, "BUTTON", "Validate before Play", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_AUTOCHECKBOX, 32, 292, 220, 30, mainHwnd, ID_VALIDATE_BEFORE_PLAY)
	telemetryHwnd = createControl(0, "BUTTON", "Gameplay telemetry", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_AUTOCHECKBOX, 268, 292, 220, 30, mainHwnd, ID_TELEMETRY)
	autoSnapshotHwnd = createControl(0, "BUTTON", "Auto source handoff after clean run", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_AUTOCHECKBOX, 500, 292, 300, 30, mainHwnd, ID_AUTO_SNAPSHOT)
	applyFont(validateBeforePlayHwnd, fontNormal)
	applyFont(telemetryHwnd, fontNormal)
	applyFont(autoSnapshotHwnd, fontNormal)

	engLabel := createControl(0, "STATIC", "GODOT ENGINE", WS_CHILD|WS_VISIBLE|SS_LEFT, 32, 336, 160, 24, mainHwnd, 0)
	applyFont(engLabel, fontSmall)
	enginePathHwnd = createControl(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE|ES_READONLY, 32, 362, 942, 34, mainHwnd, 0)
	applyFont(enginePathHwnd, fontSmall)

	exportLabel := createControl(0, "STATIC", "SOURCE DEVELOPMENT HANDOFFS", WS_CHILD|WS_VISIBLE|SS_LEFT, 32, 414, 360, 28, mainHwnd, 0)
	applyFont(exportLabel, fontHeader)
	versionLabel := createControl(0, "STATIC", "VERSION", WS_CHILD|WS_VISIBLE|SS_LEFT, 32, 458, 88, 24, mainHwnd, 0)
	applyFont(versionLabel, fontSmall)
	buildVersionHwnd = createControl(WS_EX_CLIENTEDGE, "EDIT", "BV5", WS_CHILD|WS_VISIBLE|WS_TABSTOP, 112, 448, 116, 34, mainHwnd, ID_VERSION)
	applyFont(buildVersionHwnd, fontNormal)
	btnExport = createControl(0, "BUTTON", "SAVE CODE HANDOFF ZIP", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_PUSHBUTTON, 246, 442, 230, 44, mainHwnd, ID_EXPORT)
	btnExports = createControl(0, "BUTTON", "OPEN EXPORTS", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_PUSHBUTTON, 488, 442, 176, 44, mainHwnd, ID_EXPORTS)
	btnCancelExport = createControl(0, "BUTTON", "CANCEL EXPORT", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_PUSHBUTTON, 676, 442, 176, 44, mainHwnd, ID_CANCEL_EXPORT)
	applyFont(btnExport, fontNormal)
	applyFont(btnExports, fontSmall)
	applyFont(btnCancelExport, fontSmall)
	enable(btnCancelExport, false)
	exportSummaryHwnd = createControl(0, "STATIC", "Next: BV5 DEV001   |   No source handoff yet.", WS_CHILD|WS_VISIBLE|SS_LEFT, 32, 494, 942, 26, mainHwnd, 0)
	applyFont(exportSummaryHwnd, fontSmall)
	exportProgressHwnd = createControl(0, "msctls_progress32", "", WS_CHILD|WS_VISIBLE|PBS_SMOOTH, 32, 524, 942, 22, mainHwnd, 0)
	send(exportProgressHwnd, PBM_SETRANGE32, 0, 100)
	send(exportProgressHwnd, PBM_SETPOS, 0, 0)
	exportProgressTextHwnd = createControl(0, "STATIC", "0%  //  IDLE  //  Ready to create a compact source handoff.", WS_CHILD|WS_VISIBLE|SS_LEFT, 32, 552, 942, 24, mainHwnd, 0)
	applyFont(exportProgressTextHwnd, fontSmall)

	diagLabel := createControl(0, "STATIC", "BUILD / RUNTIME DIAGNOSTICS", WS_CHILD|WS_VISIBLE|SS_LEFT, 32, 592, 330, 26, mainHwnd, 0)
	applyFont(diagLabel, fontHeader)
	diagnosticsHwnd = createControl(WS_EX_CLIENTEDGE, "EDIT", "No script errors detected.\r\n\r\nPress VALIDATE BUILD for a fresh compiler check.", WS_CHILD|WS_VISIBLE|WS_VSCROLL|ES_MULTILINE|ES_AUTOVSCROLL|ES_READONLY, 32, 626, 590, 180, mainHwnd, 0)
	applyFont(diagnosticsHwnd, fontNormal)

	activityLabel := createControl(0, "STATIC", "LAUNCHER ACTIVITY", WS_CHILD|WS_VISIBLE|SS_LEFT, 642, 592, 300, 26, mainHwnd, 0)
	applyFont(activityLabel, fontHeader)
	activityHwnd = createControl(WS_EX_CLIENTEDGE, "EDIT", "", WS_CHILD|WS_VISIBLE|WS_VSCROLL|ES_MULTILINE|ES_AUTOVSCROLL|ES_READONLY, 642, 626, 332, 180, mainHwnd, 0)
	applyFont(activityHwnd, fontSmall)

	btnFolder = createControl(0, "BUTTON", "PROJECT FOLDER", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_PUSHBUTTON, 32, 828, 180, 42, mainHwnd, ID_FOLDER)
	btnLogs = createControl(0, "BUTTON", "OPEN LOGS", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_PUSHBUTTON, 224, 828, 160, 42, mainHwnd, ID_LOGS)
	btnCopy = createControl(0, "BUTTON", "COPY DIAGNOSTICS", WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_PUSHBUTTON, 396, 828, 200, 42, mainHwnd, ID_COPY)
	for _, h := range []uintptr{btnFolder, btnLogs, btnCopy} {
		applyFont(h, fontSmall)
	}
	footer := createControl(0, "STATIC", "Exports: exports\\CrawlBrawl_LATEST.zip\r\nLogs: logs\\launcher", WS_CHILD|WS_VISIBLE|SS_LEFT, 620, 828, 354, 44, mainHwnd, 0)
	applyFont(footer, fontSmall)

	procShowWindow.Call(mainHwnd, SW_SHOW)
	procUpdateWindow.Call(mainHwnd)
	return nil
}

func initializeState() {
	projectRoot = resolveProjectRoot()
	buildLogPaths()
	c := loadConfig()
	godotExe = resolveGodot(c.GodotExe)
	setChecked(telemetryHwnd, c.Telemetry)
	setChecked(validateBeforePlayHwnd, c.ValidateBeforePlay)
	setChecked(autoSnapshotHwnd, c.AutoSnapshot)
	setText(buildVersionHwnd, normalizeBuildVersion(c.BuildVersion))
	setText(enginePathHwnd, godotExe)
	if _, err := os.Stat(filepath.Join(projectRoot, "project.godot")); err != nil {
		setStatus("PROJECT NOT FOUND", "Place Play Crawl Brawl.exe in the Crawl Brawl project root beside project.godot.", colorRed)
		appendActivity("project.godot not found beside launcher.")
	} else if godotExe == "" {
		setStatus("GODOT NOT CONFIGURED", "Click ENGINE... and select Godot_v4.7.1-stable_win64.exe.", colorRed)
		appendActivity("Godot engine not found automatically.")
	} else {
		setStatus("READY", "Crawl Brawl project and Godot engine detected.", colorGreen)
		appendActivity("Launcher ready.")
		appendActivity("Project: " + projectRoot)
		appendActivity("Engine: " + godotExe)
	}
	if errs := parseScriptErrors(importLogPath); len(errs) > 0 {
		setText(diagnosticsHwnd, diagnosticsText(errs))
	}
	refreshExportSummary()
	setExportProgress(0, "0%  //  IDLE  //  Ready to create a compact source handoff.")
	saveConfig()
	logEvent("Native launcher v%s started. Project=%s Engine=%s", launcherVersion, projectRoot, godotExe)
}

func main() {
	runtime.LockOSThread()
	if err := initUI(); err != nil {
		// No main window may exist yet; owner 0 is valid.
		procMessageBoxW.Call(0, uintptr(unsafe.Pointer(u16(err.Error()))), uintptr(unsafe.Pointer(u16(appTitle))), MB_OK|MB_ICONERROR)
		return
	}
	initializeState()
	procSetForegroundWindow.Call(mainHwnd)
	var m msg
	for {
		r, _, _ := procGetMessageW.Call(uintptr(unsafe.Pointer(&m)), 0, 0, 0)
		if int32(r) <= 0 {
			break
		}
		procTranslateMessage.Call(uintptr(unsafe.Pointer(&m)))
		procDispatchMessageW.Call(uintptr(unsafe.Pointer(&m)))
	}
}
