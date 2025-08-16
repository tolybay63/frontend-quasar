@echo off
chcp 65001 >nul
echo.
echo === DTJ Web Services Deployment ===
echo.
echo Select action:
echo 1. Full deployment (build + deploy)
echo 2. Build only
echo 3. Deploy only
echo 4. Clear web folders
echo 5. Deploy specific service
echo.
set /p choice="Enter number (1-5): "

if "%choice%"=="1" (
    echo.
    echo Starting full deployment...
    "C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web.ps1" -Action "full"
) else if "%choice%"=="2" (
    echo.
    echo Starting build only...
    "C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web.ps1" -Action "build"
) else if "%choice%"=="3" (
    echo.
    echo Starting deploy only...
    "C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web.ps1" -Action "deploy"
) else if "%choice%"=="4" (
    echo.
    echo Starting clear folders...
    "C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web.ps1" -Action "clear"
) else if "%choice%"=="5" (
    echo.
    echo Available services:
    echo - dtj-app
    echo - tofi-nsi
    echo - tofi-plan
    echo - tofi-personnal
    echo - tofi-orgstructure
    echo - tofi-object
    echo - tofi-admin
    echo - tofi-meta
    echo - tofi-cube
    echo - tofi-userdata
    echo - tofi-data
    echo.
    set /p service="Enter service name: "
    if not "%service%"=="" (
        echo.
        echo Deploying %service%...
        "C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web.ps1" -Action "full" -ServiceNames "%service%"
    ) else (
        echo No service specified.
    )
) else (
    echo Invalid choice.
)

echo.
pause
