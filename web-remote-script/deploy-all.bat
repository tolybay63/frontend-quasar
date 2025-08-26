@echo off
chcp 65001 >nul
echo === Deploy All Web Services ===
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

echo Deploying all services...
echo -------------------------------------------------------------------------------------

echo 1. Deploying admin (tofi-admin)...
set "source_path=%DEV_PATH%\tofi-admin\dist\spa"
set "target_path=\\%PROD_SERVER%\C$\dtj\web\admin"
if exist "!source_path!" (
    echo   Removing existing target directory...
    rmdir "!target_path!" /s /q 2>nul
    mkdir "!target_path!"
    echo   Copying files...
    robocopy "!source_path!" "!target_path!" /MIR /R:3 /W:1
    if errorlevel 8 (echo   ERROR: Copy failed for admin) else (echo   Deployed successfully!)
) else (
    echo   WARNING: Source directory not found: !source_path!
    echo   Skipping admin...
)
echo.

echo 2. Deploying meta (tofi-meta)...
set "source_path=%DEV_PATH%\tofi-meta\dist\spa"
set "target_path=\\%PROD_SERVER%\C$\dtj\web\meta"
if exist "!source_path!" (
    echo   Removing existing target directory...
    rmdir "!target_path!" /s /q 2>nul
    mkdir "!target_path!"
    echo   Copying files...
    robocopy "!source_path!" "!target_path!" /MIR /R:3 /W:1
    if errorlevel 8 (echo   ERROR: Copy failed for meta) else (echo   Deployed successfully!)
) else (
    echo   WARNING: Source directory not found: !source_path!
    echo   Skipping meta...
)
echo.

echo 3. Deploying account (tofi-userdata)...
set "source_path=%DEV_PATH%\tofi-userdata\dist\spa"
set "target_path=\\%PROD_SERVER%\C$\dtj\web\account"
if exist "!source_path!" (
    echo   Removing existing target directory...
    rmdir "!target_path!" /s /q 2>nul
    mkdir "!target_path!"
    echo   Copying files...
    robocopy "!source_path!" "!target_path!" /MIR /R:3 /W:1
    if errorlevel 8 (echo   ERROR: Copy failed for account) else (echo   Deployed successfully!)
) else (
    echo   WARNING: Source directory not found: !source_path!
    echo   Skipping account...
)
echo.

echo 4. Deploying tofidata (tofi-data)...
set "source_path=%DEV_PATH%\tofi-data\dist\spa"
set "target_path=\\%PROD_SERVER%\C$\dtj\web\tofidata"
if exist "!source_path!" (
    echo   Removing existing target directory...
    rmdir "!target_path!" /s /q 2>nul
    mkdir "!target_path!"
    echo   Copying files...
    robocopy "!source_path!" "!target_path!" /MIR /R:3 /W:1
    if errorlevel 8 (echo   ERROR: Copy failed for tofidata) else (echo   Deployed successfully!)
) else (
    echo   WARNING: Source directory not found: !source_path!
    echo   Skipping tofidata...
)
echo.

echo 5. Deploying cube (tofi-cube)...
set "source_path=%DEV_PATH%\tofi-cube\dist\spa"
set "target_path=\\%PROD_SERVER%\C$\dtj\web\cube"
if exist "!source_path!" (
    echo   Removing existing target directory...
    rmdir "!target_path!" /s /q 2>nul
    mkdir "!target_path!"
    echo   Copying files...
    robocopy "!source_path!" "!target_path!" /MIR /R:3 /W:1
    if errorlevel 8 (echo   ERROR: Copy failed for cube) else (echo   Deployed successfully!)
) else (
    echo   WARNING: Source directory not found: !source_path!
    echo   Skipping cube...
)
echo.

echo 6. Deploying dtj (dtj\dtj-app)...
set "source_path=%DEV_PATH%\dtj\dtj-app\dist\spa"
set "target_path=\\%PROD_SERVER%\C$\dtj\web\dtj"
if exist "!source_path!" (
    echo   Removing existing target directory...
    rmdir "!target_path!" /s /q 2>nul
    mkdir "!target_path!"
    echo   Copying files...
    robocopy "!source_path!" "!target_path!" /MIR /R:3 /W:1
    if errorlevel 8 (echo   ERROR: Copy failed for dtj) else (echo   Deployed successfully!)
) else (
    echo   WARNING: Source directory not found: !source_path!
    echo   Skipping dtj...
)
echo.

echo 7. Deploying nsi (dtj\tofi-nsi)...
set "source_path=%DEV_PATH%\dtj\tofi-nsi\dist\spa"
set "target_path=\\%PROD_SERVER%\C$\dtj\web\nsi"
if exist "!source_path!" (
    echo   Removing existing target directory...
    rmdir "!target_path!" /s /q 2>nul
    mkdir "!target_path!"
    echo   Copying files...
    robocopy "!source_path!" "!target_path!" /MIR /R:3 /W:1
    if errorlevel 8 (echo   ERROR: Copy failed for nsi) else (echo   Deployed successfully!)
) else (
    echo   WARNING: Source directory not found: !source_path!
    echo   Skipping nsi...
)
echo.

echo Waiting for files to be written...
timeout /t 3 /nobreak >nul

echo Cleaning up network connection...
net use \\%PROD_SERVER%\C$ /delete 2>nul

echo === Deploy completed successfully! ===
pause
