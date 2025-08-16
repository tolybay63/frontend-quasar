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
$configPath = Join-Path $PSScriptRoot "web-deploy-config.json"
if (-not (Test-Path $configPath)) {
    Write-Log "Конфигурационный файл не найден: $configPath" "ERROR"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
Write-Log "Конфигурация загружена из: $configPath"

# Функция сборки web-сервиса
function Build-WebService {
    param([object]$Service)
    
    $devPath = Join-Path $config.DevServer.RootPath $Service.DevPath
    if (-not (Test-Path $devPath)) {
        Write-Log "Папка разработки не найдена: $devPath" "ERROR"
        return $false
    }
    
    Write-Log "Собираю web-сервис $($Service.Name) в папке $devPath"
    
    try {
        Push-Location $devPath
        
        # Проверяем наличие quasar
        $quasarVersion = & quasar --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Quasar CLI не найден в папке $devPath" "ERROR"
            return $false
        }
        
        Write-Log "Quasar версия: $quasarVersion"
        
        # Выполняем сборку
        $buildResult = & quasar build 2>&1
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0) {
            Write-Log "Сборка web-сервиса $($Service.Name) завершена успешно"
            return $true
        } else {
            Write-Log "Ошибка при сборке web-сервиса $($Service.Name): $buildResult" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Исключение при сборке $($Service.Name): $($_.Exception.Message)" "ERROR"
        return $false
    }
    finally {
        Pop-Location
    }
}

# Функция копирования web-сервиса
function Copy-WebService {
    param([object]$Service)
    
    $devPath = Join-Path $config.DevServer.RootPath $Service.DevPath
    $distPath = Join-Path $devPath "dist"
    $spaPath = Join-Path $distPath "spa"
    $prodPath = Join-Path $config.ProdServer.RootPath $Service.ProdPath
    
    if (-not (Test-Path $distPath)) {
        Write-Log "Папка dist не найдена: $distPath" "ERROR"
        return $false
    }
    
    if (-not (Test-Path $spaPath)) {
        Write-Log "Папка dist\spa не найдена: $spaPath" "ERROR"
        return $false
    }
    
    Write-Log "Копирую web-сервис $($Service.Name) из $spaPath в $prodPath"
    
    try {
        # Создаем папку назначения если не существует
        if (-not (Test-Path $prodPath)) {
            New-Item -ItemType Directory -Path $prodPath -Force | Out-Null
            Write-Log "Создана папка: $prodPath"
        }
        
        # Копируем содержимое dist\spa
        Copy-Item -Path "$spaPath\*" -Destination $prodPath -Recurse -Force
        Write-Log "Web-сервис $($Service.Name) скопирован успешно"
        return $true
    }
    catch {
        Write-Log "Ошибка при копировании $($Service.Name): $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Функция очистки папки назначения
function Clear-WebServiceFolder {
    param([object]$Service)
    
    $prodPath = Join-Path $config.ProdServer.RootPath $Service.ProdPath
    
    if (-not (Test-Path $prodPath)) {
        Write-Log "Папка назначения не существует: $prodPath"
        return $true
    }
    
    Write-Log "Очищаю папку: $prodPath"
    
    try {
        $filesToDelete = Get-ChildItem -Path $prodPath -Recurse -ErrorAction SilentlyContinue
        if ($filesToDelete) {
            $filesToDelete | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Log "Папка $($Service.Name) очищена"
        } else {
            Write-Log "Папка $($Service.Name) уже пуста"
        }
        return $true
    }
    catch {
        Write-Log "Ошибка при очистке $($Service.Name): $($_.Exception.Message)" "WARNING"
        return $false
    }
}

# Основная логика
$servicesToProcess = @()

if ($ServiceNames.Count -gt 0) {
    # Фильтруем сервисы по именам
    $servicesToProcess = $config.WebServices | Where-Object { $ServiceNames -contains $_.Name }
    if ($servicesToProcess.Count -eq 0) {
        Write-Log "Указанные сервисы не найдены в конфигурации" "ERROR"
        exit 1
    }
    Write-Log "Будут обработаны сервисы: $($ServiceNames -join ', ')"
} else {
    # Все сервисы
    $servicesToProcess = $config.WebServices
    Write-Log "Будут обработаны все сервисы ($($servicesToProcess.Count))"
}

$successCount = 0
$totalCount = $servicesToProcess.Count

switch ($Action.ToLower()) {
    "build" {
        Write-Log "=== Сборка web-сервисов ==="
        foreach ($service in $servicesToProcess) {
            if (Build-WebService -Service $service) {
                $successCount++
            }
        }
        Write-Log "Сборка завершена: $successCount из $totalCount сервисов"
    }
    
    "deploy" {
        Write-Log "=== Развертывание web-сервисов ==="
        foreach ($service in $servicesToProcess) {
            if (Copy-WebService -Service $service) {
                $successCount++
            }
        }
        Write-Log "Развертывание завершено: $successCount из $totalCount сервисов"
    }
    
    "clear" {
        Write-Log "=== Очистка web-сервисов ==="
        foreach ($service in $servicesToProcess) {
            if (Clear-WebServiceFolder -Service $service) {
                $successCount++
            }
        }
        Write-Log "Очистка завершена: $successCount из $totalCount сервисов"
    }
    
    "full" {
        Write-Log "=== Полное развертывание web-сервисов ==="
        
        # Этап 1: Сборка
        Write-Log "Этап 1: Сборка сервисов"
        $buildSuccess = 0
        foreach ($service in $servicesToProcess) {
            if (Build-WebService -Service $service) {
                $buildSuccess++
            }
        }
        Write-Log "Сборка завершена: $buildSuccess из $totalCount сервисов"
        
        if ($buildSuccess -eq 0) {
            Write-Log "Сборка не удалась, развертывание прервано" "ERROR"
            exit 1
        }
        
        # Этап 2: Очистка и копирование
        Write-Log "Этап 2: Развертывание сервисов"
        foreach ($service in $servicesToProcess) {
            $devPath = Join-Path $config.DevServer.RootPath $Service.DevPath
            $distPath = Join-Path $devPath "dist"
            $spaPath = Join-Path $distPath "spa"
            
            if (Test-Path $distPath) {
                if (Test-Path $spaPath) {
                    Clear-WebServiceFolder -Service $service | Out-Null
                    if (Copy-WebService -Service $service) {
                        $successCount++
                    }
                } else {
                    Write-Log "Пропускаю $($service.Name) - папка dist\spa не найдена" "WARNING"
                }
            } else {
                Write-Log "Пропускаю $($service.Name) - папка dist не найдена" "WARNING"
            }
        }
        Write-Log "Развертывание завершено: $successCount из $totalCount сервисов"
    }
    
    default {
        Write-Log "Неизвестное действие: $Action" "ERROR"
        Write-Log "Доступные действия: build, deploy, clear, full" "INFO"
        exit 1
    }
}

Write-Log "=== Операция завершена ==="
if ($successCount -eq $totalCount) {
    Write-Log "Все сервисы обработаны успешно!" "INFO"
} else {
    Write-Log "Обработано $successCount из $totalCount сервисов" "WARNING"
}
