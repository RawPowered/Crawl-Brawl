@echo off
setlocal EnableExtensions
pushd "%~dp0" >nul 2>nul
if errorlevel 1 (
  echo ERROR: Could not open the Crawl Brawl project directory.
  pause
  exit /b 1
)

if defined GODOT_EXE if exist "%GODOT_EXE%" goto godot_found
set "GODOT_EXE="
for /f "delims=" %%G in ('where godot 2^>nul') do if not defined GODOT_EXE set "GODOT_EXE=%%G"

:godot_found
if not defined GODOT_EXE (
  echo ERROR: Godot 4.7.1 was not found.
  echo Set the GODOT_EXE environment variable or install Godot on PATH.
  pause
  popd
  exit /b 1
)
if not exist "%GODOT_EXE%" (
  echo ERROR: Godot executable does not exist: %GODOT_EXE%
  pause
  popd
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\build_windows_release.ps1" -GodotExe "%GODOT_EXE%"
set "BUILD_EXIT=%ERRORLEVEL%"
if not "%BUILD_EXIT%"=="0" pause
popd
exit /b %BUILD_EXIT%
