# Инструкции по развертыванию Service

## 1. Сборка проекта
npm run build

## 2. Копирование в веб-папку
Скопировать содержимое папки dist/ в C:/dtj/web/service/

## 3. Перезапуск nginx
nginx -s reload

## 4. Проверка работы
Открыть http://127.0.0.1/dtj/service

## Структура API endpoints:
- Plan API: http://127.0.0.1/dtj/api/plan -> 127.0.0.1:9179
- Inspections API: http://127.0.0.1/dtj/api/inspections -> 127.0.0.1:9182  
- Objects API: http://127.0.0.1/dtj/api/objects -> 127.0.0.1:9178
- OrgStructure API: http://127.0.0.1/dtj/api/orgstructure -> 127.0.0.1:9181
- NSI API: http://127.0.0.1/dtj/api/nsi -> 127.0.0.1:9177

## Переменные окружения настроены в .env.local
