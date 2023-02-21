# Playbook for installing Clickhouse, Vector and Lighthouse on CentOS7 hosts
Плейбук позволяет установить Clickhouse, Vector и Lighthouse на хосты, а также сконфигурировать эти сервисы:
- на Clickhouse создается БД logs с таблицей journald для приема событий journald из Vector (дополнительно проверяется работа firewald, открывается порт для доступа к clickhouse снаружи)
- Vector конфигурируется для настройки отправки журналов ОС в Clickhouse
- На хост устанавливается Nginx и в качестве сайта по умолчанию разворачивается lighthouse из репозитория на git(дополнительно проверяется работа firewald, настраивается SELinux)

Плейбук состоит из 4 play:
- Install Clickhouse (Скачивание и первичная настройка Clickhouse)
- Configure Сlickhouse (Настройка Clickhouse для приема логов из Vector)
- Install Vector (Скачивание и настройка Vector)
- Install Lighthouse (Скачивание и настройка nginx и lighthouse)
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

/group_vars/lighthouse/vars.yml:
|Name  |Descriprion  |
|---------|---------|
|document_root|NGINX document root |
|app_root|Каталог приложения в document root|
|lighthouse_repo_url|Адрес репозитория lighthouse|
|nginx_config_file|Общий файл конфигурации nginx|
|lighthouse_nginx_config_file|Файл конфигурации nginx для lighthouse|

---
## Inventory
Inventory генерируется terraform на основании template/
Присутствуют три группы хостов:
- Группа clickhouse
  - хост clickhouse-01
- Группа vector
  - хост vector-01
- Группа lighthouse
  - хост lighthouse-01
---
## Templates
|Name  |Descriprion  |
|---------|---------|
|vector.j2|Шаблон файла конфигурации по умолчанию Vector|
|vector.yml.j2|Шаблон конфигурации Vector|
|nginx.conf.j2|Шаблон файла конфигурации по умолчанию Nginx|
|lighthouse.conf.j2|Шаблон файла конфигурации nginx для Lighthouse|

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
|Restart firewalld service|Перезагрузка службы файрвола|
|Reload firewalld service|Перезагрузка правил файрвола|

#### Tasks
|Name  |Descriprion  |
|---------|---------|
Configure clickhouse \| Install epel|Настройка репозиотрия EPEL|
Configure clickhouse \| Install python-pip and firewalld|Установка Python Pip  и службы firewalld|
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

### Install Lighthouse
#### Handlers
|Name  |Descriprion  |
|---------|---------|
|Restart nginx service|Перезапуск сервера nginx|
|Reload nginx service|Перечитывание и применение конфигурации сервера nginx|
|Restart firewalld service|Перезагрузка службы файрвола|

#### Tasks
|Name  |Descriprion  |
|---------|---------|
Install lighthouse \| Install epel repo|Настройка репозиотрия EPEL|
Install lighthouse \| Install nginx, git and firewalld|Установка nginx, git и службы firewalld|
Install lighthouse \| Flush handlers|Вызов handler для запуска сервиса|
|Установка модуля lxml|
Install lighthouse \| Clone a lighthouse repo|Клонирование репозитория lighthouse во временный каталог|
Install lighthouse \| Copy lighthouse to site folder| Копирование сайта в каталог сайта nginx с нужными правами|
Install lighthouse \| Configure SELinux for nginx|Настрйка контекста SELinux для файлов сайта|
Install lighthouse \| Open http/s port on firewalld| Открытие портов для доступа к lighthouse извне|
Install lighthouse \| Rewrite nginx main config file| Перезапись основного конфига nginx из шаблона|
Install lighthouse \| Rewrite nginx lighthouse config file| Запись конфига nginx для lighthouse из шаблона|
---
### Playbook Tags
|Name  |Descriprion  |
|---------|---------|
|clickhouse_install|Установка Clickhouse|
|clickhouse_config|Настройка Clickhouse|
|vector_install|Установка и настройка Vector|
|lighthouse_install|Установка и настройка lighthouse|
