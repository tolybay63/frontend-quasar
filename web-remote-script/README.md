# Web Remote Scripts

Скрипты для удаленного управления веб-сервисами на prod сервере (192.168.1.20).

## Файлы

- `web-remote-config.json` - конфигурация сервисов
- `build-all.bat` - сборка всех веб-сервисов
- `build-select.bat` - сборка выбранных веб-сервисов
- `deploy.bat` - деплой веб-сервисов на prod сервер

## Использование

### Сборка всех сервисов
```cmd
build-all.bat
```

### Сборка выбранных сервисов
```cmd
build-select.bat dtj-app
build-select.bat admin meta
```

### Деплой всех сервисов
```cmd
deploy.bat all
```

### Деплой выбранных сервисов
```cmd
deploy.bat dtj-app
deploy.bat admin meta
```

## Доступные сервисы

- `dtj-app` (dtj\dtj-app)
- `admin` (tofi-admin)
- `meta` (tofi-meta)
- `cube` (tofi-cube)
- `account` (tofi-userdata)
- `tofidata` (tofi-data)
- `nsi` (dtj\tofi-nsi)

## Требования

- Quasar CLI установлен
- Сетевой доступ к prod серверу (192.168.1.20)
- Права администратора для деплоя
