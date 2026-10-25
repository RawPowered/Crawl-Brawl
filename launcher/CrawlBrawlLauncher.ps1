# Crawl Brawl Developer Launcher
# Windows PowerShell 5.1 / Windows Forms. No third-party dependencies.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$LauncherDir = $PSScriptRoot
$ProjectDir = Split-Path -Parent $LauncherDir
$ProjectFile = Join-Path $ProjectDir 'project.godot'
$ConfigFile = Join-Path $LauncherDir 'launcher_config.json'
$LauncherLog = Join-Path $ProjectDir 'launcher.log'
$ImportLog = Join-Path $ProjectDir 'import.log'
$RuntimeLog = Join-Path $ProjectDir 'runtime.log'
$TelemetryDir = Join-Path $ProjectDir 'logs'
$TelemetryLog = Join-Path $TelemetryDir 'gameplay_telemetry.ndjson'

if (-not (Test-Path $TelemetryDir)) {
    New-Item -ItemType Directory -Path $TelemetryDir -Force | Out-Null
}

$Colors = @{
    Bg       = [System.Drawing.Color]::FromArgb(10, 16, 23)
    Panel    = [System.Drawing.Color]::FromArgb(18, 27, 38)
    Panel2   = [System.Drawing.Color]::FromArgb(25, 36, 49)
    Border   = [System.Drawing.Color]::FromArgb(48, 65, 83)
    Text     = [System.Drawing.Color]::FromArgb(232, 239, 246)
    Muted    = [System.Drawing.Color]::FromArgb(142, 158, 176)
    Orange   = [System.Drawing.Color]::FromArgb(242, 140, 0)
    Cyan     = [System.Drawing.Color]::FromArgb(83, 213, 242)
    Green    = [System.Drawing.Color]::FromArgb(74, 216, 124)
    Red      = [System.Drawing.Color]::FromArgb(255, 91, 105)
    Yellow   = [System.Drawing.Color]::FromArgb(247, 200, 74)
}

function Write-LauncherEvent {
    param([string]$Message)
    try {
        $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        Add-Content -Path $LauncherLog -Value "[$stamp] $Message" -Encoding UTF8
    } catch {}
}

function Load-LauncherConfig {
    $default = [ordered]@{
        GodotExe = ''
        Telemetry = $true
        ValidateBeforePlay = $true
    }
    if (-not (Test-Path $ConfigFile)) { return $default }
    try {
        $saved = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        if ($saved.GodotExe) { $default.GodotExe = [string]$saved.GodotExe }
        if ($null -ne $saved.Telemetry) { $default.Telemetry = [bool]$saved.Telemetry }
        if ($null -ne $saved.ValidateBeforePlay) { $default.ValidateBeforePlay = [bool]$saved.ValidateBeforePlay }
    } catch {
        Write-LauncherEvent "Could not read launcher config: $($_.Exception.Message)"
    }
    return $default
}

function Save-LauncherConfig {
    try {
        $obj = [ordered]@{
            GodotExe = $script:GodotExe
            Telemetry = [bool]$script:TelemetryCheck.Checked
            ValidateBeforePlay = [bool]$script:ValidateCheck.Checked
        }
        $obj | ConvertTo-Json | Set-Content -Path $ConfigFile -Encoding UTF8
    } catch {
        Write-LauncherEvent "Could not save launcher config: $($_.Exception.Message)"
    }
}

function Resolve-GodotExecutable {
    param([string]$SavedPath)

    $candidates = New-Object System.Collections.Generic.List[string]
    if ($SavedPath) { [void]$candidates.Add($SavedPath) }
    if ($env:CRAWL_BRAWL_GODOT) { [void]$candidates.Add($env:CRAWL_BRAWL_GODOT) }
    [void]$candidates.Add((Join-Path $ProjectDir 'Godot_v4.7.1-stable_win64.exe'))
    [void]$candidates.Add((Join-Path $ProjectDir 'tools\godot\Godot_v4.7.1-stable_win64.exe'))

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate -PathType Leaf)) {
            return (Resolve-Path $candidate).Path
        }
    }

    foreach ($name in @('godot.exe', 'godot')) {
        try {
            $command = Get-Command $name -ErrorAction Stop | Select-Object -First 1
            if ($command.Source) { return $command.Source }
        } catch {}
    }
    return ''
}

function Get-GodotVersion {
    if (-not $script:GodotExe -or -not (Test-Path $script:GodotExe)) { return 'Godot not configured' }
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $script:GodotExe
        $psi.Arguments = '--version'
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $p = [System.Diagnostics.Process]::Start($psi)
        $text = $p.StandardOutput.ReadToEnd().Trim()
        if (-not $text) { $text = $p.StandardError.ReadToEnd().Trim() }
        $p.WaitForExit()
        if ($text) { return ($text -split "`r?`n")[0] }
    } catch {}
    return 'Godot engine ready'
}

function Get-ScriptErrors {
    param([string]$Path)
    $results = New-Object System.Collections.Generic.List[object]
    if (-not (Test-Path $Path)) { return @() }

    $lines = Get-Content $Path -ErrorAction SilentlyContinue
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = [string]$lines[$i]
        if ($line -match '^SCRIPT ERROR:\s*(.+)$') {
            $message = $Matches[1].Trim()
            $location = ''
            for ($j = $i + 1; $j -le [Math]::Min($i + 3, $lines.Count - 1); $j++) {
                if ([string]$lines[$j] -match '\((res://[^\)]+)\)') {
                    $location = $Matches[1]
                    break
                }
            }
            $results.Add([pscustomobject]@{ Message = $message; Location = $location; Raw = $line })
        }
    }
    return @($results)
}

function Set-Status {
    param(
        [string]$Title,
        [string]$Detail,
        [System.Drawing.Color]$Color,
        [bool]$Busy = $false
    )
    $script:StatusTitle.Text = $Title
    $script:StatusTitle.ForeColor = $Color
    $script:StatusDetail.Text = $Detail
    $script:Progress.Visible = $Busy
    if ($Busy) { $script:Progress.Style = 'Marquee' }
    [System.Windows.Forms.Application]::DoEvents()
}

function Add-Activity {
    param([string]$Text)
    $stamp = Get-Date -Format 'HH:mm:ss'
    $script:Activity.AppendText("[$stamp] $Text`r`n")
    $script:Activity.SelectionStart = $script:Activity.Text.Length
    $script:Activity.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Refresh-ErrorList {
    param([object[]]$Errors)
    $script:ErrorList.Items.Clear()
    if (-not $Errors -or $Errors.Count -eq 0) {
        [void]$script:ErrorList.Items.Add('No script errors detected.')
        $script:ErrorList.ForeColor = $Colors.Green
        return
    }

    $script:ErrorList.ForeColor = $Colors.Text
    foreach ($err in $Errors) {
        $label = $err.Message
        if ($err.Location) { $label = "$label  [$($err.Location)]" }
        [void]$script:ErrorList.Items.Add($label)
    }
}

function Show-LastImportState {
    $errors = @(Get-ScriptErrors $ImportLog)
    if ($errors.Count -gt 0) {
        Refresh-ErrorList $errors
        Set-Status "BUILD BLOCKED - $($errors.Count) SCRIPT ERROR$(if($errors.Count -ne 1){'S'})" 'Fix the listed compiler error before Play.' $Colors.Red $false
    } elseif (Test-Path $ImportLog) {
        Refresh-ErrorList @()
        Set-Status 'READY' 'Previous import log contains no script errors.' $Colors.Green $false
    } else {
        Refresh-ErrorList @()
        Set-Status 'READY TO VALIDATE' 'Run Validate Build or press Play.' $Colors.Cyan $false
    }
}

function Ensure-EngineReady {
    if ($script:GodotExe -and (Test-Path $script:GodotExe)) { return $true }
    Set-Status 'GODOT NOT CONFIGURED' 'Choose the Godot executable in Engine Settings.' $Colors.Red $false
    Add-Activity 'Godot executable was not found.'
    return $false
}

function Invoke-BuildValidation {
    if (-not (Ensure-EngineReady)) { return $false }
    if (-not (Test-Path $ProjectFile)) {
        Set-Status 'PROJECT NOT FOUND' 'project.godot must be beside this launcher package.' $Colors.Red $false
        Add-Activity "Missing project.godot: $ProjectFile"
        return $false
    }

    Set-Status 'VALIDATING BUILD' 'Godot is importing resources and compiling scripts...' $Colors.Yellow $true
    Add-Activity 'Build validation started.'
    Write-LauncherEvent "Validation started. Engine=$script:GodotExe Project=$ProjectDir"

    try {
        if (Test-Path $ImportLog) { Remove-Item $ImportLog -Force -ErrorAction SilentlyContinue }
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $script:GodotExe
        $psi.Arguments = "--headless --path `"$ProjectDir`" --import --log-file `"$ImportLog`""
        $psi.WorkingDirectory = $ProjectDir
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $psi
        [void]$p.Start()
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()
        $p.WaitForExit()
        $exitCode = $p.ExitCode

        if (-not (Test-Path $ImportLog)) {
            @($stdout, $stderr) | Where-Object { $_ } | Set-Content -Path $ImportLog -Encoding UTF8
        }

        $errors = @(Get-ScriptErrors $ImportLog)
        Refresh-ErrorList $errors

        if ($errors.Count -gt 0) {
            Set-Status "BUILD BLOCKED - $($errors.Count) SCRIPT ERROR$(if($errors.Count -ne 1){'S'})" 'The game was not launched. See Build Diagnostics.' $Colors.Red $false
            Add-Activity "Validation found $($errors.Count) script error(s)."
            Write-LauncherEvent "Validation blocked by $($errors.Count) script error(s). GodotExit=$exitCode"
            return $false
        }

        if ($exitCode -ne 0) {
            Set-Status "VALIDATION FAILED - EXIT $exitCode" 'Godot returned a non-zero import exit code.' $Colors.Red $false
            Add-Activity "Godot validation exited with code $exitCode."
            Write-LauncherEvent "Validation failed. GodotExit=$exitCode"
            return $false
        }

        Set-Status 'BUILD VALID' 'No GDScript compiler errors detected.' $Colors.Green $false
        Add-Activity 'Build validation passed.'
        Write-LauncherEvent 'Validation passed.'
        return $true
    } catch {
        Set-Status 'VALIDATION ERROR' $_.Exception.Message $Colors.Red $false
        Add-Activity "Validation exception: $($_.Exception.Message)"
        Write-LauncherEvent "Validation exception: $($_.Exception.Message)"
        return $false
    }
}

function Start-CrawlBrawl {
    if (-not (Ensure-EngineReady)) { return }

    if ($script:ValidateCheck.Checked) {
        $ok = Invoke-BuildValidation
        if (-not $ok) { return }
    }

    Save-LauncherConfig
    try {
        if (Test-Path $RuntimeLog) { Remove-Item $RuntimeLog -Force -ErrorAction SilentlyContinue }

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $script:GodotExe
        $args = "--path `"$ProjectDir`" --log-file `"$RuntimeLog`""
        if ($script:TelemetryCheck.Checked) { $args += ' -- --crawl-telemetry' }
        $psi.Arguments = $args
        $psi.WorkingDirectory = $ProjectDir
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        if ($script:TelemetryCheck.Checked) {
            $psi.EnvironmentVariables['CRAWL_BRAWL_TELEMETRY'] = '1'
            $psi.EnvironmentVariables['CRAWL_BRAWL_TELEMETRY_LOG'] = $TelemetryLog
        } else {
            $psi.EnvironmentVariables['CRAWL_BRAWL_TELEMETRY'] = '0'
        }

        $script:GameProcess = New-Object System.Diagnostics.Process
        $script:GameProcess.StartInfo = $psi
        [void]$script:GameProcess.Start()
        $script:GameTimer.Start()

        Set-Status 'CRAWL BRAWL RUNNING' 'Game process started. Launcher remains available.' $Colors.Green $false
        Add-Activity "Game started. PID=$($script:GameProcess.Id)"
        Write-LauncherEvent "Game started. PID=$($script:GameProcess.Id) Telemetry=$($script:TelemetryCheck.Checked)"
    } catch {
        Set-Status 'LAUNCH FAILED' $_.Exception.Message $Colors.Red $false
        Add-Activity "Launch exception: $($_.Exception.Message)"
        Write-LauncherEvent "Launch exception: $($_.Exception.Message)"
    }
}

function Start-GodotEditor {
    if (-not (Ensure-EngineReady)) { return }
    try {
        Start-Process -FilePath $script:GodotExe -ArgumentList "--editor --path `"$ProjectDir`"" -WorkingDirectory $ProjectDir | Out-Null
        Add-Activity 'Godot editor opened.'
        Write-LauncherEvent 'Godot editor opened.'
    } catch {
        Add-Activity "Could not open Godot editor: $($_.Exception.Message)"
    }
}

function Open-PathSafe {
    param([string]$Path)
    try {
        if (Test-Path $Path) {
            Start-Process -FilePath $Path | Out-Null
        } else {
            [System.Windows.Forms.MessageBox]::Show("Not found yet:`r`n$Path", 'Crawl Brawl Launcher', 'OK', 'Information') | Out-Null
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Crawl Brawl Launcher', 'OK', 'Error') | Out-Null
    }
}

function Choose-GodotExecutable {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Choose Godot executable'
    $dialog.Filter = 'Godot executable (*.exe)|*.exe|All files (*.*)|*.*'
    if ($script:GodotExe -and (Test-Path $script:GodotExe)) {
        $dialog.InitialDirectory = Split-Path -Parent $script:GodotExe
        $dialog.FileName = Split-Path -Leaf $script:GodotExe
    }
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:GodotExe = $dialog.FileName
        $script:EngineValue.Text = Get-GodotVersion
        $script:EnginePath.Text = $script:GodotExe
        Save-LauncherConfig
        Set-Status 'ENGINE UPDATED' 'Godot executable saved.' $Colors.Cyan $false
        Add-Activity "Godot engine set to $script:GodotExe"
    }
}

function New-FlatButton {
    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$W,
        [int]$H,
        [System.Drawing.Color]$Back,
        [System.Drawing.Color]$Fore = $Colors.Text,
        [float]$FontSize = 10,
        [bool]$Bold = $true
    )
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $Text
    $b.Location = New-Object System.Drawing.Point($X, $Y)
    $b.Size = New-Object System.Drawing.Size($W, $H)
    $b.FlatStyle = 'Flat'
    $b.FlatAppearance.BorderSize = 0
    $b.BackColor = $Back
    $b.ForeColor = $Fore
    $style = if ($Bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $b.Font = New-Object System.Drawing.Font('Segoe UI', $FontSize, $style)
    $b.Cursor = [System.Windows.Forms.Cursors]::Hand
    return $b
}

$Config = Load-LauncherConfig
$script:GodotExe = Resolve-GodotExecutable $Config.GodotExe
$script:GameProcess = $null

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Crawl Brawl Launcher'
$form.StartPosition = 'CenterScreen'
$form.ClientSize = New-Object System.Drawing.Size(1100, 690)
$form.MinimumSize = New-Object System.Drawing.Size(1116, 729)
$form.BackColor = $Colors.Bg
$form.ForeColor = $Colors.Text
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

# Header
$title = New-Object System.Windows.Forms.Label
$title.Text = 'CRAWL BRAWL'
$title.Location = New-Object System.Drawing.Point(28, 18)
$title.Size = New-Object System.Drawing.Size(380, 42)
$title.Font = New-Object System.Drawing.Font('Segoe UI', 25, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = $Colors.Text
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'DEVELOPER LAUNCHER  /  GATOGODMODE GAMES'
$subtitle.Location = New-Object System.Drawing.Point(31, 59)
$subtitle.Size = New-Object System.Drawing.Size(440, 20)
$subtitle.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$subtitle.ForeColor = $Colors.Orange
$form.Controls.Add($subtitle)

$engineTag = New-Object System.Windows.Forms.Panel
$engineTag.Location = New-Object System.Drawing.Point(690, 20)
$engineTag.Size = New-Object System.Drawing.Size(380, 61)
$engineTag.BackColor = $Colors.Panel
$form.Controls.Add($engineTag)

$engineCaption = New-Object System.Windows.Forms.Label
$engineCaption.Text = 'ENGINE'
$engineCaption.Location = New-Object System.Drawing.Point(14, 8)
$engineCaption.Size = New-Object System.Drawing.Size(70, 16)
$engineCaption.ForeColor = $Colors.Muted
$engineCaption.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
$engineTag.Controls.Add($engineCaption)

$script:EngineValue = New-Object System.Windows.Forms.Label
$script:EngineValue.Text = Get-GodotVersion
$script:EngineValue.Location = New-Object System.Drawing.Point(14, 26)
$script:EngineValue.Size = New-Object System.Drawing.Size(350, 24)
$script:EngineValue.ForeColor = if ($script:GodotExe) { $Colors.Green } else { $Colors.Red }
$script:EngineValue.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$engineTag.Controls.Add($script:EngineValue)

# Left command panel
$left = New-Object System.Windows.Forms.Panel
$left.Location = New-Object System.Drawing.Point(28, 98)
$left.Size = New-Object System.Drawing.Size(315, 558)
$left.BackColor = $Colors.Panel
$form.Controls.Add($left)

$leftHeader = New-Object System.Windows.Forms.Label
$leftHeader.Text = 'COMMAND CENTER'
$leftHeader.Location = New-Object System.Drawing.Point(18, 16)
$leftHeader.Size = New-Object System.Drawing.Size(250, 24)
$leftHeader.ForeColor = $Colors.Muted
$leftHeader.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$left.Controls.Add($leftHeader)

$play = New-FlatButton 'PLAY CRAWL BRAWL' 18 52 279 62 $Colors.Orange ([System.Drawing.Color]::Black) 13 $true
$left.Controls.Add($play)

$validate = New-FlatButton 'VALIDATE BUILD' 18 126 279 46 $Colors.Panel2 $Colors.Cyan 10 $true
$left.Controls.Add($validate)

$editor = New-FlatButton 'OPEN IN GODOT' 18 182 279 44 $Colors.Panel2 $Colors.Text 10 $true
$left.Controls.Add($editor)

$folder = New-FlatButton 'PROJECT FOLDER' 18 236 136 40 $Colors.Panel2 $Colors.Text 9 $true
$left.Controls.Add($folder)
$settings = New-FlatButton 'ENGINE SETTINGS' 161 236 136 40 $Colors.Panel2 $Colors.Text 9 $true
$left.Controls.Add($settings)

$script:TelemetryCheck = New-Object System.Windows.Forms.CheckBox
$script:TelemetryCheck.Text = 'Gameplay telemetry'
$script:TelemetryCheck.Location = New-Object System.Drawing.Point(20, 306)
$script:TelemetryCheck.Size = New-Object System.Drawing.Size(260, 25)
$script:TelemetryCheck.Checked = [bool]$Config.Telemetry
$script:TelemetryCheck.ForeColor = $Colors.Text
$script:TelemetryCheck.BackColor = $Colors.Panel
$left.Controls.Add($script:TelemetryCheck)

$script:ValidateCheck = New-Object System.Windows.Forms.CheckBox
$script:ValidateCheck.Text = 'Validate before Play'
$script:ValidateCheck.Location = New-Object System.Drawing.Point(20, 336)
$script:ValidateCheck.Size = New-Object System.Drawing.Size(260, 25)
$script:ValidateCheck.Checked = [bool]$Config.ValidateBeforePlay
$script:ValidateCheck.ForeColor = $Colors.Text
$script:ValidateCheck.BackColor = $Colors.Panel
$left.Controls.Add($script:ValidateCheck)

$pathCaption = New-Object System.Windows.Forms.Label
$pathCaption.Text = 'GODOT EXECUTABLE'
$pathCaption.Location = New-Object System.Drawing.Point(20, 382)
$pathCaption.Size = New-Object System.Drawing.Size(250, 18)
$pathCaption.ForeColor = $Colors.Muted
$pathCaption.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
$left.Controls.Add($pathCaption)

$script:EnginePath = New-Object System.Windows.Forms.Label
$script:EnginePath.Text = if ($script:GodotExe) { $script:GodotExe } else { 'Not configured' }
$script:EnginePath.Location = New-Object System.Drawing.Point(20, 404)
$script:EnginePath.Size = New-Object System.Drawing.Size(274, 54)
$script:EnginePath.ForeColor = $Colors.Muted
$left.Controls.Add($script:EnginePath)

$projectCaption = New-Object System.Windows.Forms.Label
$projectCaption.Text = 'PROJECT'
$projectCaption.Location = New-Object System.Drawing.Point(20, 470)
$projectCaption.Size = New-Object System.Drawing.Size(250, 18)
$projectCaption.ForeColor = $Colors.Muted
$projectCaption.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
$left.Controls.Add($projectCaption)

$projectValue = New-Object System.Windows.Forms.Label
$projectValue.Text = $ProjectDir
$projectValue.Location = New-Object System.Drawing.Point(20, 492)
$projectValue.Size = New-Object System.Drawing.Size(274, 48)
$projectValue.ForeColor = $Colors.Text
$left.Controls.Add($projectValue)

# Main status card
$main = New-Object System.Windows.Forms.Panel
$main.Location = New-Object System.Drawing.Point(360, 98)
$main.Size = New-Object System.Drawing.Size(710, 558)
$main.BackColor = $Colors.Panel
$form.Controls.Add($main)

$statusCaption = New-Object System.Windows.Forms.Label
$statusCaption.Text = 'BUILD STATUS'
$statusCaption.Location = New-Object System.Drawing.Point(20, 16)
$statusCaption.Size = New-Object System.Drawing.Size(300, 20)
$statusCaption.ForeColor = $Colors.Muted
$statusCaption.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$main.Controls.Add($statusCaption)

$script:StatusTitle = New-Object System.Windows.Forms.Label
$script:StatusTitle.Text = 'READY TO VALIDATE'
$script:StatusTitle.Location = New-Object System.Drawing.Point(20, 42)
$script:StatusTitle.Size = New-Object System.Drawing.Size(660, 37)
$script:StatusTitle.Font = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
$script:StatusTitle.ForeColor = $Colors.Cyan
$main.Controls.Add($script:StatusTitle)

$script:StatusDetail = New-Object System.Windows.Forms.Label
$script:StatusDetail.Text = 'Run Validate Build or press Play.'
$script:StatusDetail.Location = New-Object System.Drawing.Point(23, 82)
$script:StatusDetail.Size = New-Object System.Drawing.Size(650, 26)
$script:StatusDetail.ForeColor = $Colors.Text
$main.Controls.Add($script:StatusDetail)

$script:Progress = New-Object System.Windows.Forms.ProgressBar
$script:Progress.Location = New-Object System.Drawing.Point(23, 114)
$script:Progress.Size = New-Object System.Drawing.Size(662, 8)
$script:Progress.Visible = $false
$main.Controls.Add($script:Progress)

$diagCaption = New-Object System.Windows.Forms.Label
$diagCaption.Text = 'BUILD DIAGNOSTICS'
$diagCaption.Location = New-Object System.Drawing.Point(20, 144)
$diagCaption.Size = New-Object System.Drawing.Size(300, 20)
$diagCaption.ForeColor = $Colors.Muted
$diagCaption.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$main.Controls.Add($diagCaption)

$script:ErrorList = New-Object System.Windows.Forms.ListBox
$script:ErrorList.Location = New-Object System.Drawing.Point(23, 170)
$script:ErrorList.Size = New-Object System.Drawing.Size(662, 135)
$script:ErrorList.BackColor = $Colors.Panel2
$script:ErrorList.ForeColor = $Colors.Text
$script:ErrorList.BorderStyle = 'FixedSingle'
$script:ErrorList.Font = New-Object System.Drawing.Font('Consolas', 9)
$script:ErrorList.HorizontalScrollbar = $true
$main.Controls.Add($script:ErrorList)

$copyError = New-FlatButton 'COPY SELECTED ERROR' 23 314 170 32 $Colors.Panel2 $Colors.Text 8 $true
$main.Controls.Add($copyError)
$openImport = New-FlatButton 'IMPORT LOG' 202 314 105 32 $Colors.Panel2 $Colors.Text 8 $true
$main.Controls.Add($openImport)
$openRuntime = New-FlatButton 'RUNTIME LOG' 316 314 112 32 $Colors.Panel2 $Colors.Text 8 $true
$main.Controls.Add($openRuntime)
$openLauncher = New-FlatButton 'LAUNCHER LOG' 437 314 120 32 $Colors.Panel2 $Colors.Text 8 $true
$main.Controls.Add($openLauncher)
$clearLogs = New-FlatButton 'CLEAR' 566 314 119 32 $Colors.Panel2 $Colors.Muted 8 $true
$main.Controls.Add($clearLogs)

$activityCaption = New-Object System.Windows.Forms.Label
$activityCaption.Text = 'LAUNCHER ACTIVITY'
$activityCaption.Location = New-Object System.Drawing.Point(20, 368)
$activityCaption.Size = New-Object System.Drawing.Size(300, 20)
$activityCaption.ForeColor = $Colors.Muted
$activityCaption.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$main.Controls.Add($activityCaption)

$script:Activity = New-Object System.Windows.Forms.TextBox
$script:Activity.Location = New-Object System.Drawing.Point(23, 394)
$script:Activity.Size = New-Object System.Drawing.Size(662, 137)
$script:Activity.Multiline = $true
$script:Activity.ReadOnly = $true
$script:Activity.ScrollBars = 'Vertical'
$script:Activity.BackColor = [System.Drawing.Color]::FromArgb(8, 13, 19)
$script:Activity.ForeColor = $Colors.Muted
$script:Activity.BorderStyle = 'FixedSingle'
$script:Activity.Font = New-Object System.Drawing.Font('Consolas', 9)
$main.Controls.Add($script:Activity)

$script:GameTimer = New-Object System.Windows.Forms.Timer
$script:GameTimer.Interval = 1000
$script:GameTimer.Add_Tick({
    if ($null -eq $script:GameProcess) {
        $script:GameTimer.Stop()
        return
    }
    try {
        if ($script:GameProcess.HasExited) {
            $exit = $script:GameProcess.ExitCode
            $script:GameTimer.Stop()
            $runtimeErrors = @(Get-ScriptErrors $RuntimeLog)
            if ($runtimeErrors.Count -gt 0) {
                Refresh-ErrorList $runtimeErrors
                Set-Status "RUNTIME ISSUE - $($runtimeErrors.Count) SCRIPT ERROR$(if($runtimeErrors.Count -ne 1){'S'})" 'The game closed with a GDScript error. See Runtime Log.' $Colors.Red $false
                Add-Activity "Game closed; runtime log contains $($runtimeErrors.Count) script error(s)."
            } elseif ($exit -ne 0) {
                Set-Status "GAME CLOSED - EXIT $exit" 'Review Runtime Log for details.' $Colors.Yellow $false
                Add-Activity "Game closed with exit code $exit."
            } else {
                Set-Status 'GAME CLOSED NORMALLY' 'Ready for another run.' $Colors.Green $false
                Add-Activity 'Game closed normally.'
            }
            Write-LauncherEvent "Game exited. Exit=$exit RuntimeScriptErrors=$($runtimeErrors.Count)"
            $script:GameProcess.Dispose()
            $script:GameProcess = $null
        }
    } catch {
        $script:GameTimer.Stop()
    }
})

$play.Add_Click({ Start-CrawlBrawl })
$validate.Add_Click({ [void](Invoke-BuildValidation) })
$editor.Add_Click({ Start-GodotEditor })
$folder.Add_Click({ Open-PathSafe $ProjectDir })
$settings.Add_Click({ Choose-GodotExecutable })
$openImport.Add_Click({ Open-PathSafe $ImportLog })
$openRuntime.Add_Click({ Open-PathSafe $RuntimeLog })
$openLauncher.Add_Click({ Open-PathSafe $LauncherLog })
$copyError.Add_Click({
    if ($script:ErrorList.SelectedItem) {
        [System.Windows.Forms.Clipboard]::SetText([string]$script:ErrorList.SelectedItem)
        Add-Activity 'Selected diagnostic copied to clipboard.'
    }
})
$clearLogs.Add_Click({
    foreach ($path in @($ImportLog, $RuntimeLog, $LauncherLog)) {
        if (Test-Path $path) { Remove-Item $path -Force -ErrorAction SilentlyContinue }
    }
    $script:Activity.Clear()
    Refresh-ErrorList @()
    Set-Status 'LOGS CLEARED' 'Ready to validate.' $Colors.Cyan $false
})
$script:TelemetryCheck.Add_CheckedChanged({ Save-LauncherConfig })
$script:ValidateCheck.Add_CheckedChanged({ Save-LauncherConfig })
$form.Add_FormClosing({ Save-LauncherConfig })

if (-not (Test-Path $ProjectFile)) {
    Set-Status 'PROJECT NOT FOUND' 'Put the launcher package in the project root beside project.godot.' $Colors.Red $false
} elseif (-not $script:GodotExe) {
    Set-Status 'GODOT NOT CONFIGURED' 'Use Engine Settings to choose Godot.' $Colors.Red $false
} else {
    Show-LastImportState
}
Add-Activity 'Launcher ready.'
Write-LauncherEvent "GUI launcher opened. Engine=$script:GodotExe"

[void]$form.ShowDialog()
