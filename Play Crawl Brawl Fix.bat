@echo off
setlocal EnableExtensions
title Crawl Brawl Launcher

rem ============================================================================
rem Crawl Brawl launcher
rem - Resolves the project relative to this file.
rem - Validates the Godot project before launch.
rem - Keeps telemetry enabled by default.
rem - Captures import + runtime Godot logs.
rem - Detects script/parse failures even when Godot returns exit code 0.
rem ============================================================================

pushd "%~dp0" >nul 2>nul
if errorlevel 1 (
    echo ERROR: Could not open the Crawl Brawl project directory.
    pause
    exit /b 1
)

set "PROJECT_DIR=%CD%"
set "LAUNCH_LOG=%PROJECT_DIR%\launcher.log"
set "IMPORT_LOG=%PROJECT_DIR%\import.log"
set "RUNTIME_LOG=%PROJECT_DIR%\runtime.log"
set "TELEMETRY_DIR=%PROJECT_DIR%\logs"

if not exist "%TELEMETRY_DIR%" mkdir "%TELEMETRY_DIR%" >nul 2>nul

rem ---------------------------------------------------------------------------
rem Project validation
rem ---------------------------------------------------------------------------

if not exist "%PROJECT_DIR%\project.godot" (
    >"%LAUNCH_LOG%" echo [%DATE% %TIME%] ERROR: project.godot was not found.
    >>"%LAUNCH_LOG%" echo Project directory: %PROJECT_DIR%

    echo.
    echo ERROR: project.godot was not found.
    echo Launcher directory:
    echo   %PROJECT_DIR%
    echo.
    echo Put this launcher in the Crawl Brawl project root beside project.godot.
    pause
    popd
    exit /b 1
)

rem ---------------------------------------------------------------------------
rem Godot resolution
rem Priority:
rem   1. Existing CRAWL_BRAWL_GODOT environment variable
rem   2. Known Crawl Brawl development location
rem   3. Local/bundled engine locations
rem   4. godot.exe / godot on PATH
rem ---------------------------------------------------------------------------

set "GODOT_EXE="

if defined CRAWL_BRAWL_GODOT (
    if exist "%CRAWL_BRAWL_GODOT%" set "GODOT_EXE=%CRAWL_BRAWL_GODOT%"
)

if not defined GODOT_EXE (
    if exist "%PROJECT_DIR%\Godot_v4.7.1-stable_win64.exe" (
        set "GODOT_EXE=%PROJECT_DIR%\Godot_v4.7.1-stable_win64.exe"
    )
)

if not defined GODOT_EXE (
    if exist "%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64.exe" (
        set "GODOT_EXE=%PROJECT_DIR%\tools\godot\Godot_v4.7.1-stable_win64.exe"
    )
)

if not defined GODOT_EXE (
    for /f "delims=" %%G in ('where godot.exe 2^>nul') do (
        if not defined GODOT_EXE set "GODOT_EXE=%%G"
    )
)

if not defined GODOT_EXE (
    for /f "delims=" %%G in ('where godot 2^>nul') do (
        if not defined GODOT_EXE set "GODOT_EXE=%%G"
    )
)

if not defined GODOT_EXE (
    >"%LAUNCH_LOG%" echo [%DATE% %TIME%] ERROR: Godot executable was not found.
    >>"%LAUNCH_LOG%" echo Project: %PROJECT_DIR%
    echo.
    echo ERROR: Godot was not found.
    echo.
    echo Checked:
    echo   CRAWL_BRAWL_GODOT
    echo   Project-local Godot 4.7.1 locations
    echo   Windows PATH
    echo.
    echo You can permanently point the launcher at Godot with:
    echo   setx CRAWL_BRAWL_GODOT "C:\path\to\Godot_v4.7.1-stable_win64.exe"
    echo.
    pause
    popd
    exit /b 1
)

rem ---------------------------------------------------------------------------
rem Telemetry contract
rem ---------------------------------------------------------------------------

if not defined CRAWL_BRAWL_TELEMETRY set "CRAWL_BRAWL_TELEMETRY=1"
if not defined CRAWL_BRAWL_TELEMETRY_LOG (
    set "CRAWL_BRAWL_TELEMETRY_LOG=%TELEMETRY_DIR%\gameplay_telemetry.ndjson"
)

rem ---------------------------------------------------------------------------
rem Fresh launcher diagnostics
rem ---------------------------------------------------------------------------

>"%LAUNCH_LOG%" echo [%DATE% %TIME%] Preparing Crawl Brawl
>>"%LAUNCH_LOG%" echo Project: %PROJECT_DIR%
>>"%LAUNCH_LOG%" echo Engine:  %GODOT_EXE%
>>"%LAUNCH_LOG%" echo Telemetry: %CRAWL_BRAWL_TELEMETRY%
>>"%LAUNCH_LOG%" echo Telemetry log: %CRAWL_BRAWL_TELEMETRY_LOG%
>>"%LAUNCH_LOG%" echo Import log: %IMPORT_LOG%
>>"%LAUNCH_LOG%" echo Runtime log: %RUNTIME_LOG%

if exist "%IMPORT_LOG%" del /q "%IMPORT_LOG%" >nul 2>nul
if exist "%RUNTIME_LOG%" del /q "%RUNTIME_LOG%" >nul 2>nul

echo.
echo ============================================================
echo   CRAWL BRAWL
echo ============================================================
echo Project:
echo   %PROJECT_DIR%
echo Engine:
echo   %GODOT_EXE%
echo.
echo [1/2] Importing and validating project resources...

"%GODOT_EXE%" --headless --path "%PROJECT_DIR%" --import --log-file "%IMPORT_LOG%"
set "IMPORT_EXIT=%ERRORLEVEL%"

>>"%LAUNCH_LOG%" echo Import exit code: %IMPORT_EXIT%

if not "%IMPORT_EXIT%"=="0" goto :IMPORT_FAILED

rem Godot can occasionally return 0 while a GDScript failed to parse/load.
findstr /I /C:"SCRIPT ERROR:" /C:"Parse Error:" /C:"Failed to load script" "%IMPORT_LOG%" >nul 2>nul
if not errorlevel 1 (
    >>"%LAUNCH_LOG%" echo Import validation: SCRIPT/PARSE ERROR DETECTED
    set "IMPORT_EXIT=2"
    goto :IMPORT_FAILED
)

>>"%LAUNCH_LOG%" echo Import validation: PASS

echo [2/2] Starting Crawl Brawl...
echo Telemetry:
echo   %CRAWL_BRAWL_TELEMETRY_LOG%
echo Runtime log:
echo   %RUNTIME_LOG%
echo.

"%GODOT_EXE%" --path "%PROJECT_DIR%" --log-file "%RUNTIME_LOG%" -- --crawl-telemetry %*
set "LAUNCH_EXIT=%ERRORLEVEL%"

>>"%LAUNCH_LOG%" echo Launch exit code: %LAUNCH_EXIT%
>>"%LAUNCH_LOG%" echo Runtime log: %RUNTIME_LOG%
>>"%LAUNCH_LOG%" echo Telemetry log: %CRAWL_BRAWL_TELEMETRY_LOG%

rem Surface internal GDScript failures even if the OS process returned 0.
if exist "%RUNTIME_LOG%" (
    findstr /I /C:"SCRIPT ERROR:" /C:"Parse Error:" /C:"Failed to load script" "%RUNTIME_LOG%" >nul 2>nul
    if not errorlevel 1 (
        >>"%LAUNCH_LOG%" echo Runtime validation: SCRIPT/PARSE ERROR DETECTED
        if "%LAUNCH_EXIT%"=="0" set "LAUNCH_EXIT=3"
    ) else (
        >>"%LAUNCH_LOG%" echo Runtime validation: no script/parse failure detected
    )
)

if not "%LAUNCH_EXIT%"=="0" goto :LAUNCH_FAILED

>>"%LAUNCH_LOG%" echo [%DATE% %TIME%] Crawl Brawl closed normally.
popd
exit /b 0


:IMPORT_FAILED
echo.
echo ============================================================
echo   CRAWL BRAWL IMPORT FAILED
echo ============================================================
echo Godot exit/validation code: %IMPORT_EXIT%
echo.
echo Review:
echo   %IMPORT_LOG%
echo   %LAUNCH_LOG%
echo.
>>"%LAUNCH_LOG%" echo [%DATE% %TIME%] Import failed.
pause
popd
exit /b %IMPORT_EXIT%


:LAUNCH_FAILED
echo.
echo ============================================================
echo   CRAWL BRAWL RUNTIME ISSUE DETECTED
echo ============================================================
echo Exit/validation code: %LAUNCH_EXIT%
echo.
echo Review:
echo   %RUNTIME_LOG%
echo   %LAUNCH_LOG%
echo   %CRAWL_BRAWL_TELEMETRY_LOG%
echo.
>>"%LAUNCH_LOG%" echo [%DATE% %TIME%] Runtime issue detected.
pause
popd
exit /b %LAUNCH_EXIT%
