param(
    [Parameter(Mandatory = $true)]
    [string]$GodotExe,
    [switch]$SkipImport,
    [switch]$SkipTemplateInstall
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$BuildDir = Join-Path $ProjectRoot "builds\windows"
$DistParent = Join-Path $ProjectRoot "dist"
$DistDir = Join-Path $DistParent "CrawlBrawl_Beta_0.1_Windows"
$ExePath = Join-Path $BuildDir "CrawlBrawl_Beta_0.1.exe"
$ZipPath = Join-Path $DistParent "CrawlBrawl_Beta_0.1_Windows.zip"
$ImportLog = Join-Path $ProjectRoot "import.log"

if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) {
    throw "Godot executable not found: $GodotExe"
}

$GodotVersion = ((& $GodotExe --version | Select-Object -First 1) -as [string]).Trim()
if (-not $GodotVersion.StartsWith("4.7.1")) {
    throw "This release is frozen to Godot 4.7.1. Found: $GodotVersion"
}
Write-Host "Godot: $GodotVersion"

if (-not $SkipTemplateInstall) {
    & (Join-Path $PSScriptRoot "ensure_export_templates.ps1") -GodotVersion "4.7.1.stable"
}

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
New-Item -ItemType Directory -Force -Path $DistParent | Out-Null
Remove-Item -LiteralPath $ExePath -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $DistDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $ZipPath -Force -ErrorAction SilentlyContinue

if (-not $SkipImport) {
    Write-Host "Importing project resources..."
    & $GodotExe --headless --path $ProjectRoot --import --log-file $ImportLog
    $ImportExit = $LASTEXITCODE
    if ($null -ne $ImportExit -and $ImportExit -ne 0 -and $ImportExit -ne -1) {
        throw "Godot import failed with exit code $ImportExit. See import.log."
    }
    if ($ImportExit -eq -1) {
        Write-Host "Import finished with Godot exit code -1; continuing to export."
    }
    elseif ($null -eq $ImportExit) {
        Write-Host "Godot did not return an import exit code; continuing to the export step."
    }
}

Write-Host "Exporting Crawl Brawl Beta 0.1..."
& $GodotExe --headless --path $ProjectRoot --export-release "Windows Desktop" $ExePath
$ExportExit = $LASTEXITCODE

$ExportDeadline = (Get-Date).AddMinutes(2)
while (-not (Test-Path -LiteralPath $ExePath -PathType Leaf) -and (Get-Date) -lt $ExportDeadline) {
    Start-Sleep -Milliseconds 500
}

if (-not (Test-Path -LiteralPath $ExePath -PathType Leaf)) {
    throw @"
Godot export failed with exit code $ExportExit and did not create:
  $ExePath

Common fixes:
  - Confirm export templates for Godot 4.7.1 are installed.
  - Confirm export_presets.cfg references assets/branding/crawl_brawl.ico.
  - Open the project once in the Godot editor if a new asset was added.
"@
}
if ($ExportExit -ne 0 -and $ExportExit -ne -1) {
    Write-Host "Export finished with Godot exit code $ExportExit; executable was created."
}
elseif ($ExportExit -eq -1) {
    Write-Host "Export finished with Godot exit code -1; executable was created."
}

New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
$DistExe = Join-Path $DistDir "CrawlBrawl_Beta_0.1.exe"
if (Test-Path -LiteralPath $DistExe) {
    try {
        Remove-Item -LiteralPath $DistExe -Force
    }
    catch {
        throw @"
Could not overwrite locked release executable:
  $DistExe

Close any running Crawl Brawl instance or Explorer preview on the dist folder, then run the build again.
"@
    }
}
Copy-Item -LiteralPath $ExePath -Destination $DistExe -Force
Copy-Item -LiteralPath (Join-Path $ProjectRoot "README_PLAYER.txt") -Destination $DistDir
Copy-Item -LiteralPath (Join-Path $ProjectRoot "LICENSES.md") -Destination $DistDir

$HashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
$ExeStream = [System.IO.File]::OpenRead((Join-Path $DistDir "CrawlBrawl_Beta_0.1.exe"))
try {
    $HashBytes = $HashAlgorithm.ComputeHash($ExeStream)
}
finally {
    $ExeStream.Dispose()
    $HashAlgorithm.Dispose()
}
$Hash = [System.BitConverter]::ToString($HashBytes).Replace("-", "").ToLowerInvariant()
"$Hash  CrawlBrawl_Beta_0.1.exe" | Set-Content -LiteralPath (Join-Path $DistDir "SHA256SUMS.txt") -Encoding ascii

$ForbiddenNames = @("saves", "save_archive", "tests", "artifacts", ".godot", "~.OLD.VERSIONS")
foreach ($Name in $ForbiddenNames) {
    if (Test-Path -LiteralPath (Join-Path $DistDir $Name)) {
        throw "Release validation failed: development content '$Name' was copied into the distribution folder."
    }
}

Compress-Archive -Path (Join-Path $DistDir "*") -DestinationPath $ZipPath -CompressionLevel Optimal
Write-Host ""
Write-Host "Release package created:"
Write-Host "  $ZipPath"
Write-Host ""
Write-Host "Test this ZIP on a machine that does not have Godot installed."
