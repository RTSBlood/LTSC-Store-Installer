@echo off
chcp 65001 >nul
setlocal DisableDelayedExpansion
title Microsoft Store Visible Installation (Latest Official)

:: ====================================================================
:: 0. CHECK AND AUTOMATIC ADMINISTRATOR ELEVATION
:: ====================================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Administrator privileges required. Requesting elevation...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Ensure the current directory is the script's directory
cd /d "%~dp0"

set "WORK_DIR=%TEMP%\MSStore_Latest_Official"
if exist "%WORK_DIR%" rd /s /q "%WORK_DIR%" >nul 2>&1
mkdir "%WORK_DIR%"

cls
echo ====================================================================
echo    MICROSOFT STORE AND DEPENDENCIES INSTALLATION (LATEST OFFICIAL)
echo ====================================================================
echo.

:: ====================================================================
:: 1. ENABLING SERVICES
:: ====================================================================
echo [STEP 1/5] Enabling Windows Update and AppX services...
for %%S in (wuauserv bits AppXSvc ClipSVC) do (
    sc config "%%S" start= demand >nul 2>&1
    net start "%%S" >nul 2>&1
)
echo  -^> Services configured and started successfully.
echo.

:: ====================================================================
:: 2. DOWNLOADING DEPENDENCIES
:: ====================================================================
echo [STEP 2/5] Downloading the latest official Microsoft dependencies...
echo.
echo 1. Downloading Microsoft.VCLibs (x64 Latest)...
curl.exe -L --progress-bar -o "%WORK_DIR%\VCLibs_x64.appx" "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"

echo.
echo 2. Downloading the official dependencies pack...
curl.exe -L --progress-bar -o "%WORK_DIR%\Dependencies.zip" "https://github.com/microsoft/winget-cli/releases/latest/download/DesktopAppInstaller_Dependencies.zip"

echo.
echo 3. Downloading Microsoft DesktopAppInstaller (WinGet)...
curl.exe -L --progress-bar -o "%WORK_DIR%\DesktopAppInstaller.msixbundle" "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

:: ====================================================================
:: 3. EXTRACTING AND INSTALLING DEPENDENCIES
:: ====================================================================
echo.
echo [STEP 3/5] Extracting and installing dependencies...
mkdir "%WORK_DIR%\Extracted" >nul 2>&1
tar.exe -xf "%WORK_DIR%\Dependencies.zip" -C "%WORK_DIR%\Extracted"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$workDir = '%WORK_DIR%';" ^
    "Write-Host ' -> Installing VCLibs Desktop x64...' -ForegroundColor Cyan;" ^
    "try { Add-AppxPackage -Path \"$workDir\VCLibs_x64.appx\" -ErrorAction Stop; Write-Host '    [OK] VCLibs installed.' -ForegroundColor Green } catch { Write-Host '    [INFO] Already installed or newer version present.' -ForegroundColor Yellow };" ^
    "$arch = if ([Environment]::Is64BitOperatingSystem) { 'x64' } else { 'x86' };" ^
    "$depFiles = Get-ChildItem -Path \"$workDir\Extracted\$arch\" -Filter *.appx -Recurse -ErrorAction SilentlyContinue;" ^
    "foreach ($file in $depFiles) {" ^
    "    Write-Host \" -> Installing $($file.Name)...\" -ForegroundColor Cyan;" ^
    "    try { Add-AppxPackage -Path $file.FullName -ErrorAction Stop; Write-Host '    [OK] Installed successfully.' -ForegroundColor Green } catch { Write-Host '    [INFO] Already present on the system.' -ForegroundColor Yellow }" ^
    "};" ^
    "Write-Host ' -> Installing Microsoft.DesktopAppInstaller (WinGet)...' -ForegroundColor Cyan;" ^
    "try { Add-AppxPackage -Path \"$workDir\DesktopAppInstaller.msixbundle\" -ErrorAction Stop; Write-Host '    [OK] DesktopAppInstaller installed.' -ForegroundColor Green } catch { Write-Host '    [INFO] Already up to date or present.' -ForegroundColor Yellow }"

:: ====================================================================
:: 4. RESETTING AND REQUESTING THE STORE
:: ====================================================================
echo.
echo [STEP 4/5] Requesting the latest Microsoft Store from Microsoft Update servers...
wsreset -i

:: ====================================================================
:: 5. INSTALLATION MONITORING
:: ====================================================================
echo.
echo [STEP 5/5] Live monitoring of the Store installation...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$elapsed = 0; $installed = $false;" ^
    "while ($elapsed -lt 300) {" ^
    "    $store = Get-AppxPackage -Name 'Microsoft.WindowsStore' -ErrorAction SilentlyContinue;" ^
    "    if ($store) {" ^
    "        Write-Host '';" ^
    "        Write-Host '====================================================================' -ForegroundColor Green;" ^
    "        Write-Host ' [SUCCESS] MICROSOFT STORE IS SUCCESSFULLY INSTALLED!' -ForegroundColor Green;" ^
    "        Write-Host (' Detected version: ' + $store.Version) -ForegroundColor White;" ^
    "        Write-Host '====================================================================' -ForegroundColor Green;" ^
    "        Start-Process 'ms-windows-store:';" ^
    "        $installed = $true; break;" ^
    "    }" ^
    "    Write-Host (' Waiting: ' + $elapsed + 's / 300s...') -ForegroundColor Yellow;" ^
    "    Start-Sleep -Seconds 5;" ^
    "    $elapsed += 5;" ^
    "};" ^
    "if (-not $installed) {" ^
    "    Write-Host '';" ^
    "    Write-Host '[WARNING] Timeout exceeded (300s). Installation continues in the background.' -ForegroundColor Red;" ^
    "}"

:: ====================================================================
:: CLEANUP
:: ====================================================================
echo.
echo Cleaning up temporary files...
rd /s /q "%WORK_DIR%" >nul 2>&1
echo Done!
echo.
pause