@echo off
setlocal
set "ROOT=%~dp0"
if exist "%ROOT%launcher\launch_hidden.vbs" (
  start "" wscript.exe "%ROOT%launcher\launch_hidden.vbs"
  exit /b 0
)

echo Crawl Brawl launcher files are incomplete.
echo Expected: %ROOT%launcher\launch_hidden.vbs
pause
exit /b 1
