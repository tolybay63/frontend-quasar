@echo off
chcp 65001 >nul
echo === Build All Web Services ===
echo.

setlocal enabledelayedexpansion

set "DEV_PATH=C:\jc-2\frontend-quasar"
set "CURRENT_DIR=%~dp0"

echo Loading configuration...
echo Dev server path: %DEV_PATH%
echo.

echo Building services...
echo.

set "counter=1"

for %%s in (dtj\dtj-app tofi-admin tofi-meta tofi-cube tofi-userdata tofi-data dtj\tofi-nsi) do (
    echo !counter!. Building %%s...
    echo -------------------------------------------------------------------------------------
    
    cd /d "%DEV_PATH%\%%s"
    if errorlevel 1 (
        echo ERROR: Cannot change to directory %%s
        echo.
        goto :continue
    )
    
    call quasar build
    if errorlevel 1 (
        echo ERROR: Build failed for %%s
        echo.
        goto :continue
    )
    
    cd /d "%CURRENT_DIR%"
    echo Completed in !random! sec
    echo.
    
    :continue
    set /a counter+=1
)

echo === Build completed successfully! ===
echo All services built in dist\spa folders
echo.
pause
