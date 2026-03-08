@echo off
setlocal EnableExtensions

REM Run from repository root (script location)
cd /d "%~dp0"

echo [setup] Starting Windows dependency setup for Hugo site...

where winget >nul 2>&1
if errorlevel 1 (
  echo [setup] ERROR: winget is required but was not found in PATH.
  exit /b 1
)

REM --- Ensure Hugo Extended is installed ---
set "HUGO_OK="
where hugo >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%A in ('hugo version 2^>nul ^| findstr /I "extended"') do set "HUGO_OK=1"
)

if defined HUGO_OK (
  echo [setup] Hugo Extended already installed. Skipping.
) else (
  echo [setup] Installing Hugo Extended via winget...
  winget install --id Hugo.Hugo.Extended --exact --accept-source-agreements --accept-package-agreements
  if errorlevel 1 (
    echo [setup] ERROR: Failed to install Hugo Extended.
    exit /b 1
  )
)

REM --- Ensure nvm for Windows is installed ---
set "NVMEXE="
where nvm >nul 2>&1
if not errorlevel 1 set "NVMEXE=nvm"
if not defined NVMEXE if exist "%ProgramFiles%\nvm\nvm.exe" set "NVMEXE=%ProgramFiles%\nvm\nvm.exe"
if not defined NVMEXE if exist "%AppData%\nvm\nvm.exe" set "NVMEXE=%AppData%\nvm\nvm.exe"

if defined NVMEXE (
  echo [setup] NVM for Windows already installed. Skipping.
) else (
  echo [setup] Installing NVM for Windows via winget...
  winget install --id CoreyButler.NVMforWindows --exact --accept-source-agreements --accept-package-agreements
  if errorlevel 1 (
    echo [setup] ERROR: Failed to install NVM for Windows.
    exit /b 1
  )

  REM Refresh nvm location after install
  set "NVMEXE="
  if exist "%ProgramFiles%\nvm\nvm.exe" set "NVMEXE=%ProgramFiles%\nvm\nvm.exe"
  if not defined NVMEXE if exist "%AppData%\nvm\nvm.exe" set "NVMEXE=%AppData%\nvm\nvm.exe"
  if not defined NVMEXE (
    where nvm >nul 2>&1
    if not errorlevel 1 set "NVMEXE=nvm"
  )
)

if not defined NVMEXE (
  echo [setup] ERROR: nvm executable could not be found after installation.
  exit /b 1
)

REM --- Ensure latest Node is installed and active via nvm ---
echo [setup] Ensuring latest Node.js via nvm...
"%NVMEXE%" install latest
if errorlevel 1 (
  echo [setup] ERROR: Failed to install latest Node.js via nvm.
  exit /b 1
)

"%NVMEXE%" use latest
if errorlevel 1 (
  echo [setup] ERROR: Failed to activate latest Node.js via nvm.
  exit /b 1
)

where npm >nul 2>&1
if errorlevel 1 (
  echo [setup] ERROR: npm was not found after Node setup. Open a new terminal and rerun setup.bat.
  exit /b 1
)

REM --- Install JS dependencies ---
echo [setup] Running npm i...
npm i
if errorlevel 1 (
  echo [setup] ERROR: npm i failed.
  exit /b 1
)

echo [setup] Setup complete.
exit /b 0
