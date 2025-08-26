@echo off
chcp 65001 >nul
echo === Deploy Test ===
echo.

setlocal enabledelayedexpansion

set "PROD_SERVER=192.168.1.20"
set "DEV_PATH=C:\jc-2\frontend-quasar"

echo Loading configuration...
echo Prod server: %PROD_SERVER%
echo Dev server path: %DEV_PATH%
echo.

echo Establishing network connection...
net use \\%PROD_SERVER%\C$ /delete 2>nul
net use \\%PROD_SERVER%\C$
if errorlevel 1 (
    echo ERROR: Cannot connect to prod server
    pause
    exit /b 1
)

echo Network connection established successfully!
echo.

if "%1"=="" (
    echo No parameters provided
    pause
    exit /b 1
)

set "service=%1"
set "service_path="
set "target_name="

if /i "%service%"=="admin" (
    set "service_path=tofi-admin"
    set "target_name=admin"
)
if /i "%service%"=="meta" (
    set "service_path=tofi-meta"
    set "target_name=meta"
)
if /i "%service%"=="account" (
    set "service_path=tofi-userdata"
    set "target_name=account"
)
if /i "%service%"=="tofidata" (
    set "service_path=tofi-data"
    set "target_name=tofidata"
)
if /i "%service%"=="cube" (
    set "service_path=tofi-cube"
    set "target_name=cube"
)
if /i "%service%"=="dtj" (
    set "service_path=dtj\dtj-app"
    set "target_name=dtj"
)
if /i "%service%"=="nsi" (
    set "service_path=dtj\tofi-nsi"
    set "target_name=nsi"
)

if "%service_path%"=="" (
    echo ERROR: Unknown service '%service%'
    pause
    exit /b 1
)

echo Deploying %service% (!service_path!)...
echo -------------------------------------------------------------------------------------

set "source_path=%DEV_PATH%\!service_path!\dist\spa"
set "target_path=\\%PROD_SERVER%\C$\dtj\web\!target_name!"

if not exist "!source_path!" (
    echo ERROR: Source directory not found: !source_path!
    echo Please build the service first using build-web.bat
    pause
    exit /b 1
)

echo Creating target directory...
echo Removing existing target directory...
rmdir "!target_path!" /s /q 2>nul
mkdir "!target_path!"

echo Copying files...
echo Source files:
dir "!source_path!"
echo.
echo Target before copy:
dir "!target_path!" 2>nul
echo.
robocopy "!source_path!" "!target_path!" /MIR /R:3 /W:1
if errorlevel 8 (
    echo ERROR: Copy failed for %service%
    pause
    exit /b 1
)
echo.
echo Target after copy:
dir "!target_path!"
echo.

echo Deployed successfully!
echo.

echo Waiting for files to be written...
timeout /t 3 /nobreak >nul

echo Cleaning up network connection...
net use \\%PROD_SERVER%\C$ /delete 2>nul

echo === Deploy completed successfully! ===
pause
