# Удаленное развертывание Web-сервисов DTJ

## Обзор

Скрипты для автоматического развертывания Quasar web-сервисов между серверами в домене EFK.

## Архитектура

### Серверы
- **Dev Server:** `scl-007.efk.local` (192.168.1.215)
  - Windows 10 Корпоративная LTSC

- **Prod Server:** `swl-001.efk.local` (192.168.1.20)
  - Windows Server 2019 Standard

### Web-сервисы
- admin
- meta
- account
- tofidata
- cube
- nsi
- unified

## Методы развертывания

### 1. SMB/WMI (рекомендуется)
- Использует сетевые пути Windows
- Простая настройка
- Требует доменные права доступа

### 2. PowerShell Remoting
- Использует WinRM
- Более безопасно
- Требует настройки WinRM на prod сервере

## Настройка

### 1. Конфигурация
```json
{
  "DevServer": {
    "Hostname": "scl-007.efk.local",
    "IP": "192.168.1.215",
    "RootPath": "C:\\jc-2\\frontend-quasar",
    "Credentials": {
      "Username": "efk\\username",
      "Password": "password"
    }
  },
  "ProdServer": {
    "Hostname": "swl-001.efk.local",
    "IP": "192.168.1.20",
    "RootPath": "C:\\dtj\\web",
    "Credentials": {
      "Username": "efk\\username", 
      "Password": "password"
    }
  },
  "DeploymentMethod": "SMB"
}
```

### 2. Требования
- PowerShell 5.1 или выше
- Доменная учетная запись с правами на оба сервера
- Сетевое подключение между серверами
- Quasar CLI на dev сервере

### 3. WinRM (для PowerShell Remoting)

## Использование

### Через меню
```bash
deploy-web-remote.bat
```

### Прямой запуск PowerShell
```powershell
# Полное развертывание
.\deploy-web-remote.ps1 -Action full

# Только сборка
.\deploy-web-remote.ps1 -Action build

# Только развертывание
.\deploy-web-remote.ps1 -Action deploy

# Очистка
.\deploy-web-remote.ps1 -Action clear

# Выборочное развертывание
.\deploy-web-remote.ps1 -Action full -ServiceNames admin,nsi
```

## Процесс развертывания

### Полное развертывание (full)
1. **Сборка** - `quasar build` на dev сервере
2. **Очистка** - удаление старых файлов на prod сервере
3. **Копирование** - передача файлов из `dist\spa` на prod сервер

### Только сборка (build)
- Выполняет `quasar build` для всех сервисов на dev сервере

### Только развертывание (deploy)
- Копирует уже собранные файлы на prod сервер

### Очистка (clear)
- Удаляет все файлы web-сервисов на prod сервере

## Логирование

Все операции логируются с временными метками:
```
[2024-01-15 14:30:25] [INFO] Сборка web-сервиса admin завершена успешно
[2024-01-15 14:30:30] [ERROR] Ошибка при копировании nsi
```
