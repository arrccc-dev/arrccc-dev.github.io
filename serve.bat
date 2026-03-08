@echo off
setlocal EnableExtensions

cd /d "%~dp0"

echo [serve] Running setup...
call "%~dp0setup.bat"
if errorlevel 1 (
  echo [serve] ERROR: setup failed. Not starting Hugo server.
  exit /b 1
)

echo [serve] Starting Hugo server...
hugo serve
if errorlevel 1 (
  echo [serve] ERROR: hugo serve failed.
  exit /b 1
)

exit /b 0
