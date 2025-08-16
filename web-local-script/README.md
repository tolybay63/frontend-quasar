# DTJ Web Services Deployment

Скрипты для автоматизации развертывания Quasar web-приложений.

## Структура

```
frontend-quasar/
├── deploy-web.ps1          # Основной PowerShell скрипт
├── deploy-web.bat          # Меню выбора действий
├── web-deploy-config.json  # Конфигурация сервисов
├── README.md              # Документация
└── web-script             # Описание требований
```

## Конфигурация

Файл `web-deploy-config.json` содержит:
- **DevServer**: настройки dev-сервера
- **ProdServer**: настройки prod-сервера  
- **WebServices**: список всех web-сервисов с путями

## Использование

### Через меню (рекомендуется)
```bash
deploy-web.bat
```

### Через PowerShell
```powershell
# Полное развертывание всех сервисов
.\deploy-web.ps1 -Action "full"

# Только сборка
.\deploy-web.ps1 -Action "build"

# Только развертывание
.\deploy-web.ps1 -Action "deploy"

# Очистка папок
.\deploy-web.ps1 -Action "clear"

# Развертывание конкретного сервиса
.\deploy-web.ps1 -Action "full" -ServiceNames "tofi-admin"
```

## Действия

1. **Full deployment** - полное развертывание (сборка + копирование)
2. **Build only** - только сборка в папки dist
3. **Deploy only** - только копирование из dist в prod
4. **Clear web folders** - очистка папок на prod-сервере
5. **Deploy specific service** - развертывание выбранного сервиса

## Web-сервисы

- **dtj-app** - основное приложение DTJ
- **tofi-nsi** - справочники
- **tofi-plan** - планирование
- **tofi-personnal** - персонал
- **tofi-orgstructure** - организационная структура
- **tofi-object** - объекты
- **tofi-admin** - администрация
- **tofi-meta** - метаданные
- **tofi-cube** - аналитика
- **tofi-userdata** - пользовательские данные
- **tofi-data** - данные

## Требования

- Quasar CLI установлен глобально
- PowerShell 5.1+
- Доступ к папкам dev и prod серверов

## Логирование

Все операции логируются с временными метками:
```
[2024-01-15 10:30:45] [INFO] Сборка web-сервиса tofi-admin завершена успешно
[2024-01-15 10:30:46] [ERROR] Ошибка при сборке web-сервиса tofi-nsi
```
