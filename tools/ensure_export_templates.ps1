param(
    [string]$GodotVersion = "4.7.1.stable"
)

$ErrorActionPreference = "Stop"

$TemplateRoot = Join-Path $env:APPDATA "Godot\export_templates\$GodotVersion"
$ReleaseTemplate = Join-Path $TemplateRoot "windows_release_x86_64.exe"
$DebugTemplate = Join-Path $TemplateRoot "windows_debug_x86_64.exe"

function Test-WindowsTemplatesInstalled {
    return (Test-Path -LiteralPath $ReleaseTemplate -PathType Leaf) -and
        (Test-Path -LiteralPath $DebugTemplate -PathType Leaf)
}

if (Test-WindowsTemplatesInstalled) {
    Write-Host "Export templates ready: $TemplateRoot"
    return
}

$CacheDir = Join-Path $PSScriptRoot "cache"
$TpzPath = Join-Path $CacheDir "Godot_v4.7.1-stable_export_templates.tpz"
$TpzUrl = "https://github.com/godotengine/godot-builds/releases/download/4.7.1-stable/Godot_v4.7.1-stable_export_templates.tpz"
$ExtractDir = Join-Path $CacheDir "tpz_extract"
$ExpectedTpzBytes = 1270000000

New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
New-Item -ItemType Directory -Force -Path $TemplateRoot | Out-Null

$NeedDownload = $true
if (Test-Path -LiteralPath $TpzPath -PathType Leaf) {
    $ExistingSize = (Get-Item -LiteralPath $TpzPath).Length
    if ($ExistingSize -ge $ExpectedTpzBytes) {
        $NeedDownload = $false
    }
    else {
        Write-Host "Removing incomplete template cache ($ExistingSize bytes)..."
        Remove-Item -LiteralPath $TpzPath -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

if ($NeedDownload) {
    Write-Host ""
    Write-Host "Godot export templates are missing for $GodotVersion."
    Write-Host "Downloading the official template package (~1.2 GB, one-time cache):"
    Write-Host "  $TpzUrl"
    Write-Host ""
    $TempDownload = "$TpzPath.download"
    Remove-Item -LiteralPath $TempDownload -Force -ErrorAction SilentlyContinue
    try {
        Invoke-WebRequest -Uri $TpzUrl -OutFile $TempDownload -UseBasicParsing
        Move-Item -LiteralPath $TempDownload -Destination $TpzPath -Force
    }
    catch {
        Remove-Item -LiteralPath $TempDownload -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $TpzPath -Force -ErrorAction SilentlyContinue
        throw @"
Failed to download Godot export templates.

Install them manually:
  1. Download Godot_v4.7.1-stable_export_templates.tpz from https://godotengine.org/download/archive/4.7.1-stable/
  2. In Godot: Editor -> Manage Export Templates -> Install From File
  3. Re-run Build Windows Beta.bat

Original error: $($_.Exception.Message)
"@
    }
}

Remove-Item -LiteralPath $ExtractDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $ExtractDir | Out-Null

$ExtractSource = Join-Path $CacheDir ("Godot_v4.7.1-stable_export_templates.extract." + [guid]::NewGuid().ToString("N") + ".tpz")
Copy-Item -LiteralPath $TpzPath -Destination $ExtractSource -Force

Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ExtractSource, $ExtractDir)
}
finally {
    Remove-Item -LiteralPath $ExtractSource -Force -ErrorAction SilentlyContinue
}

$ReleaseSource = Get-ChildItem -Path $ExtractDir -Recurse -Filter "windows_release_x86_64.exe" |
    Where-Object { -not $_.PSIsContainer } |
    Select-Object -First 1
$DebugSource = Get-ChildItem -Path $ExtractDir -Recurse -Filter "windows_debug_x86_64.exe" |
    Where-Object { -not $_.PSIsContainer } |
    Select-Object -First 1

if ($null -eq $ReleaseSource -or $null -eq $DebugSource) {
    throw "Downloaded export template package did not contain Windows x86_64 templates."
}

Copy-Item -LiteralPath $ReleaseSource.FullName -Destination $ReleaseTemplate -Force
Copy-Item -LiteralPath $DebugSource.FullName -Destination $DebugTemplate -Force
Remove-Item -LiteralPath $ExtractDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Installed Windows export templates to:"
Write-Host "  $TemplateRoot"
