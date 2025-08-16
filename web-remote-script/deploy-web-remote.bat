@echo off
chcp 65001 >nul
title Удаленное развертывание Web-сервисов DTJ

echo.
echo ========================================
echo   Удаленное развертывание Web-сервисов
echo ========================================
echo.
echo Dev Server: scl-007.efk.local (192.168.1.215)
echo Prod Server: swl-001.efk.local (192.168.1.20)
echo.

:menu
echo Выберите действие:
echo.
echo 1. Полное развертывание (сборка + деплой)
echo 2. Только сборка
echo 3. Только развертывание
echo 4. Очистка prod сервера
echo 5. Выборочное развертывание
echo 6. Выход
echo.
set /p choice="Введите номер (1-6): "

if "%choice%"=="1" goto full
if "%choice%"=="2" goto build
if "%choice%"=="3" goto deploy
if "%choice%"=="4" goto clear
if "%choice%"=="5" goto selective
if "%choice%"=="6" goto exit
echo Неправильный выбор. Попробуйте снова.
goto menu

:full
echo.
echo Запуск полного развертывания...
"C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web-remote.ps1" -Action full
goto end

:build
echo.
echo Запуск сборки...
"C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web-remote.ps1" -Action build
goto end

:deploy
echo.
echo Запуск развертывания...
"C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web-remote.ps1" -Action deploy
goto end

:clear
echo.
echo Запуск очистки...
"C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web-remote.ps1" -Action clear
goto end

:selective
echo.
echo Доступные сервисы:
echo - admin
echo - nsi
echo - orgstructure
echo - personnel
echo - reports
echo - settings
echo - tasks
echo - workflow
echo - documents
echo - calendar
echo - dashboard
echo.
set /p services="Введите имена сервисов через запятую: "
echo.
echo Запуск выборочного развертывания...
"C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0deploy-web-remote.ps1" -Action full -ServiceNames $services
goto end

:end
echo.
echo Нажмите любую клавишу для возврата в меню...
pause >nul
cls
goto menu

:exit
echo.
echo Выход из программы.
pause
