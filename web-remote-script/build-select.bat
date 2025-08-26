@echo off
chcp 65001 >nul
echo === Build Selected Web Services ===
echo.

setlocal enabledelayedexpansion

set "DEV_PATH=C:\jc-2\frontend-quasar"
set "CURRENT_DIR=%~dp0"

echo Loading configuration...
echo Dev server path: %DEV_PATH%
echo.

if "%1"=="" (
    echo No parameters provided. Building all services...
    echo.
    set "counter=1"
    
    for %%s in (dtj\dtj-app tofi-admin tofi-meta tofi-cube tofi-userdata tofi-data dtj\tofi-nsi) do (
        echo !counter!. Building %%s...
        echo -------------------------------------------------------------------------------------
        
        cd /d "%DEV_PATH%\%%s"
        if errorlevel 1 (
            echo ERROR: Cannot change to directory %%s
            echo.
            set /a counter+=1
            goto :continue
        )
        
        call quasar build
        if errorlevel 1 (
            echo ERROR: Build failed for %%s
            echo.
            set /a counter+=1
            goto :continue
        )
        
        cd /d "%CURRENT_DIR%"
        echo Completed in !random! sec
        echo.
        
        :continue
        set /a counter+=1
    )
    goto :end
)

echo Building selected services...
echo.

set "counter=1"
set "found_services=0"

:build_loop
if "%1"=="" goto :check_services

set "service=%1"
set "service_path="

if /i "%service%"=="dtj-app" set "service_path=dtj\dtj-app"
if /i "%service%"=="admin" set "service_path=tofi-admin"
if /i "%service%"=="meta" set "service_path=tofi-meta"
if /i "%service%"=="cube" set "service_path=tofi-cube"
if /i "%service%"=="account" set "service_path=tofi-userdata"
if /i "%service%"=="tofidata" set "service_path=tofi-data"
if /i "%service%"=="nsi" set "service_path=dtj\tofi-nsi"

if "%service_path%"=="" (
    echo ERROR: Unknown service '%service%'
    echo.
    shift
    goto :build_loop
)

set /a found_services+=1

echo !counter!. Building %service% (!service_path!)...
echo -------------------------------------------------------------------------------------

cd /d "%DEV_PATH%\!service_path!"
if errorlevel 1 (
    echo ERROR: Cannot change to directory !service_path!
    echo.
    shift
    set /a counter+=1
    goto :build_loop
)

call quasar build
if errorlevel 1 (
    echo ERROR: Build failed for %service%
    echo.
    shift
    set /a counter+=1
    goto :build_loop
)

cd /d "%CURRENT_DIR%"
echo Completed in !random! sec
echo.

shift
set /a counter+=1
goto :build_loop

:check_services
if %found_services%==0 (
    echo.
    echo No valid services found. Available services:
    echo   dtj-app (dtj\dtj-app)
    echo   admin (tofi-admin)
    echo   meta (tofi-meta)
    echo   cube (tofi-cube)
    echo   account (tofi-userdata)
    echo   tofidata (tofi-data)
    echo   nsi (dtj\tofi-nsi)
    echo.
    echo Examples:
    echo   build-web.bat dtj-app
    echo   build-web.bat admin meta
    echo.
)

:end
echo === Build completed successfully! ===
echo Selected services built in dist\spa folders
echo.
pause
