# Playbook for installing Clickhouse and Vector on CentOS7 hosts
Плейбук позволяет установить Clickhouse и Vector на хосты а также сконфигурировать эти сервисы:
- на Clickhouse создается БД logs с таблицей journald для приема событий journald из Vector
- Vector конфигурируется для настройки отправки журналов ОС в Clickhouse

Плейбук состоит из 3 play:
- Install Clickhouse (Скачивание и первичная настройка Clickhouse)
- Configure Сlickhouse (Настройка Clickhouse для приема логов из Vector)
- Install Vector (Скачивание и настройка Vector)
---
## Variables
/group_vars/clickhouse/vars.yml:
|Name  |Descriprion  |
|---------|---------|
|clickhouse_version| Версия Clickhouse для скачивания|
|clickhouse_packages| Список пакетов для скачивания|
|clickhouse_syslog_table_query|Запрос к Clickhouse на создание таблицы для Vector|
|clickhouse_server_config_file|Путь к файлу конфигурации сервера Clickhouse|
|clickhouse_client_config_file|Пусть к файлу клиентской конфигурации Clickhouse|
|clickhouse_server_listen_ip_address|IP-адрес с которого служба Clickhouse будет слушать запросы|

/group_vars/vector/vars.yml:
|Name  |Descriprion  |
|---------|---------|
|vector_version| Версия Vector для скачивания|
|vector_default_config_file|Файл конфигруации по умолчанию для Vector|
|vector_config_file|Файл конфигурации Vector для запуска сервиса|
|clickhouse_ipaddress|IP-адрес сервера Clickhouse|
|vector_config:|Конфигурация Vector|
---
## Inventory
Присутствуют две группы хостов:
- Группа clickhouse
  - хост clickhouse-01
- Группа vector
  - хост vector-01
---
## Templates
|Name  |Descriprion  |
|---------|---------|
|vector.j2|Шаблон конфигурации по умолчанию Vector|
|vector.yml.j2|Шаблон конфигурации Vector|

---
## Playbook Plays
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
Configure clickhouse \| Install epel|Настройка репозиотрия EPEL|
Configure clickhouse \| Install python-pip|Установка Python Pip|
Configure clickhouse \| Install pip lxml|Установка модуля lxml|
Configure clickhouse \| Create table for syslog|Создание таблицы journald для данных из Vector|
Configure clickhouse \| Modify clickhouse server config|Настрйка серверной конфигурации Clickhouse для прослушивания ip-адреса {{ clickhouse_server_listen_ip_address }}|
Configure clickhouse \| Modify clickhouse client config|Настрйка клиентской конфигурации Clickhouse, включение best_effort для параметра date_time_input_format |
Configure clickhouse \| Open clickhouse port on firewalld| Открытие порта 8123/tcp для доступа к Clickhouse извне|

### Install Vector
#### Handlers
|Name  |Descriprion  |
|---------|---------|
|Restart Vector service|Перезапуск сервера Vector|



#### Tasks
|Name  |Descriprion  |
|---------|---------|
Install vector \| Download vector distrib|Скачивание дистрибутивов
Install vector \| Install vector package|Установка дистрибутивов
Install vector \| Delete default vector config|Удаление конфигурации по умолчанию(/etc/vector/vector.toml)
Install vector \| Set default vector config file for service|Установка конфигурации сервиса Vector по умолчанию|
Install vector \| Vector config from template|Настройка конфигурации сервиса Vector|
Install vector \| Flush handlers|Вызов handler для запуска сервиса|
Install vector \| Check if vector started|Проверка запуска сервиса|

---
### Playbook Tags
|Name  |Descriprion  |
|---------|---------|
|clickhouse_install|Установка Clickhouse|
|clickhouse_config|Настройка Clickhouse|
|vector_install|Установка и настройка Vector|
