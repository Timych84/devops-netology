# Playbook for installing Clickhouse and Vector on CentOS7 hosts
Плейбук позволяет установить Clickhouse и Vector на хосты а также сконфигурировать эти сервисы:
- на Clickhouse создается БД logs с таблицей journald для приема событий journald из Vector
- Vector конфигурируется для настройки отправки журналов ОС в Clickhouse

Плейбук состоит из 3 play:
- Install Clickhouse (Скачивание и первичная настройка Clickhouse)
- Configure Сlickhouse (Настройка Clickhouse для приема логов из Vector)
- Install Vector (Скачивание и настройка Vector)

## Описание плейбука
### Install Clickhouse
#### Handlers
|Name  |Descriprion  |
|---------|---------|
|Start clickhouse service     |Запуск сервера Clickhouse         |
#### Tasks
|Name  |Descriprion  |
|---------|---------|
Install Clickhouse \| Download clickhouse distrib|Скачивание дистрибутивов|
Install Clickhouse \| Install clickhouse packages|Установка дистрибутивов|
Install Clickhouse \| Flush handlers|Вызов handler для запуска сервиса|
Install Clickhouse \| Check if Clickhouse started|Проверка запуска сервиса|
Install Clickhouse \| Create database|Создание БД logs|

### Configure Сlickhouse
#### Handlers
|Name  |Descriprion  |
|---------|---------|
|Restart clickhouse service     |Перезапуск сервера Clickhouse         |
|Reload firewalld service|Перезагрузка правил файрвола|

#### Tasks
|Name  |Descriprion  |
|---------|---------|
Install Clickhouse \| Download clickhouse distrib|Скачивание дистрибутивов
Install Clickhouse \| Install clickhouse packages|Установка дистрибутивов
Install Clickhouse \| Flush handlers|Вызов handler для запуска сервиса
Install Clickhouse \| Check if Clickhouse started|Проверка запуска сервиса
Install Clickhouse \| Create database|Создание БД logs





#### Tasks
|Name  |Descriprion  |
|---------|---------|
Install vector \| Download vector distrib|Скачивание дистрибутивов
Install vector \| Install vector package|Установка дистрибутивов
Install vector \| Delete default vector config|Удаление конфигурации по умолчанию(/etc/)
Install vector \| Set default vector config file for service
Install vector \| Vector config from template
Install vector \| Flush handlers
Install vector \| Check if vector started
