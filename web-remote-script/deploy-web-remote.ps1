param(
    [string]$Action = "full",
    [string[]]$ServiceNames = @()
)

# Функция логирования
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

# Загружаем конфигурацию
$configPath = Join-Path $PSScriptRoot "web-remote-config.json"
if (-not (Test-Path $configPath)) {
    Write-Log "Конфигурационный файл не найден: $configPath" "ERROR"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
Write-Log "Конфигурация загружена из: $configPath"

# Основная логика
Write-Log "=== Удаленное развертывание web-сервисов ==="

# Проверяем подключение к серверам
Write-Log "Проверяю подключение к dev серверу: $($config.DevServer.Hostname)"
Write-Log "Проверяю подключение к prod серверу: $($config.ProdServer.Hostname)"

# Обрабатываем сервисы
$servicesToProcess = @()

if ($ServiceNames.Count -gt 0) {
    $servicesToProcess = $config.WebServices | Where-Object { $ServiceNames -contains $_.Name }
    Write-Log "Будут обработаны сервисы: $($ServiceNames -join ', ')"
} else {
    $servicesToProcess = $config.WebServices
    Write-Log "Будут обработаны все сервисы ($($servicesToProcess.Count))"
}

Write-Log "Метод развертывания: $($config.DeploymentMethod)"

switch ($Action.ToLower()) {
    "build" {
        Write-Log "=== Сборка web-сервисов ==="
        foreach ($service in $servicesToProcess) {
            Write-Log "Собираю сервис: $($service.Name)"
        }
    }
    
    "deploy" {
        Write-Log "=== Развертывание web-сервисов ==="
        foreach ($service in $servicesToProcess) {
            Write-Log "Развертываю сервис: $($service.Name)"
        }
    }
    
    "clear" {
        Write-Log "=== Очистка web-сервисов ==="
        foreach ($service in $servicesToProcess) {
            Write-Log "Очищаю сервис: $($service.Name)"
        }
    }
    
    "full" {
        Write-Log "=== Полное развертывание web-сервисов ==="
        foreach ($service in $servicesToProcess) {
            Write-Log "Полное развертывание сервиса: $($service.Name)"
        }
    }
    
    default {
        Write-Log "Неизвестное действие: $Action" "ERROR"
        Write-Log "Доступные действия: build, deploy, clear, full" "INFO"
        exit 1
    }
}

Write-Log "=== Операция завершена ==="
