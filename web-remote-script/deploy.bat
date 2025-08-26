@echo off
setlocal enabledelayedexpansion

echo === Deploy Web Services Script ===
echo.

REM Проверяем параметры
if "%1"=="" (
    echo Usage: deploy.bat [all^|service_name]
    echo.
    echo Examples:
    echo   deploy.bat all
    echo   deploy.bat dtj-app
    echo   deploy.bat tofi-admin
    echo.
    echo Available services: dtj-app tofi-admin tofi-meta tofi-cube tofi-userdata tofi-data tofi-nsi
    pause
    exit /b 1
)

set SERVICE=%1

REM Устанавливаем значения напрямую
set PROD_SERVER=192.168.1.20
set DEV_PATH=C:\jc-2\frontend-quasar

echo Service: %SERVICE%
echo Dev Path: %DEV_PATH%
echo Prod Server: %PROD_SERVER%
echo.

REM Устанавливаем сетевое подключение
echo Setting up network connection...
net use \\%PROD_SERVER%\C$ /user:%USERNAME% 2>nul
if errorlevel 1 (
    echo Network connection failed
    pause
    exit /b 1
)

if /i "%SERVICE%"=="all" (
    echo Deploying all web services...
    call :deploy_all_services
) else (
    echo Deploying service: %SERVICE%
    call :deploy_single_service %SERVICE%
)

echo.
echo === Deploy completed ===
pause
exit /b 0

:deploy_all_services
echo Deploying dtj-app...
call :deploy_single_service dtj-app

echo Deploying tofi-admin...
call :deploy_single_service tofi-admin

echo Deploying tofi-meta...
call :deploy_single_service tofi-meta

echo Deploying tofi-cube...
call :deploy_single_service tofi-cube

echo Deploying tofi-userdata...
call :deploy_single_service tofi-userdata

echo Deploying tofi-data...
call :deploy_single_service tofi-data

echo Deploying tofi-nsi...
call :deploy_single_service tofi-nsi

goto :eof

:deploy_single_service
set SERVICE_NAME=%1
set SOURCE_PATH=
set TARGET_PATH=

REM Определяем пути для сервиса
if /i "%SERVICE_NAME%"=="dtj-app" (
    set SOURCE_PATH=%DEV_PATH%\dtj\dtj-app\dist\spa
    set TARGET_PATH=C$\dtj\web\dtj
)
if /i "%SERVICE_NAME%"=="tofi-admin" (
    set SOURCE_PATH=%DEV_PATH%\tofi-admin\dist\spa
    set TARGET_PATH=C$\dtj\web\admin
)
if /i "%SERVICE_NAME%"=="tofi-meta" (
    set SOURCE_PATH=%DEV_PATH%\tofi-meta\dist\spa
    set TARGET_PATH=C$\dtj\web\meta
)
if /i "%SERVICE_NAME%"=="tofi-cube" (
    set SOURCE_PATH=%DEV_PATH%\tofi-cube\dist\spa
    set TARGET_PATH=C$\dtj\web\cube
)
if /i "%SERVICE_NAME%"=="tofi-userdata" (
    set SOURCE_PATH=%DEV_PATH%\tofi-userdata\dist\spa
    set TARGET_PATH=C$\dtj\web\account
)
if /i "%SERVICE_NAME%"=="tofi-data" (
    set SOURCE_PATH=%DEV_PATH%\tofi-data\dist\spa
    set TARGET_PATH=C$\dtj\web\tofidata
)
if /i "%SERVICE_NAME%"=="tofi-nsi" (
    set SOURCE_PATH=%DEV_PATH%\dtj\tofi-nsi\dist\spa
    set TARGET_PATH=C$\dtj\web\nsi
)

if "%SOURCE_PATH%"=="" (
    echo Error: Unknown service %SERVICE_NAME%
    goto :eof
)

echo Checking source path: %SOURCE_PATH%
if not exist "%SOURCE_PATH%" (
    echo Error: Source path does not exist: %SOURCE_PATH%
    echo Please build the service first using: build-all.bat %SERVICE_NAME%
    goto :eof
)

echo Copying %SERVICE_NAME% from %SOURCE_PATH% to \\%PROD_SERVER%\%TARGET_PATH%...

REM Создаем папку назначения если не существует
if not exist "\\%PROD_SERVER%\%TARGET_PATH%" (
    echo Creating target directory...
    mkdir "\\%PROD_SERVER%\%TARGET_PATH%"
)

REM Копируем файлы
echo Copying files...
xcopy "%SOURCE_PATH%\*" "\\%PROD_SERVER%\%TARGET_PATH%\" /E /Y /Q

if errorlevel 1 (
    echo Error: Failed to copy %SERVICE_NAME%
) else (
    echo Successfully deployed %SERVICE_NAME%
)

goto :eof
