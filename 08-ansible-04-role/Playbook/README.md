# Playbook for installing Clickhouse, Vector and Lighthouse on CentOS7 hosts
Плейбук позволяет установить Clickhouse, Vector и Lighthouse на хосты

Плейбук состоит из 3 play:
- Install Clickhouse
- Install Vector
- Install Lighthouse
---

## Variables
/group_vars/vector.yml:
|Name  |Descriprion  |
|---------|---------|
|clickhouse_ipaddress|IP-адрес сервера Clickhouse|

---
## Inventory
Присутствуют три группы хостов:
- Группа clickhouse
  - хост clickhouse-01
- Группа vector
  - хост vector-01
- Группа lighthouse
  - хост lighthouse-01

---
### Playbook Tags
|Name  |Descriprion  |
|---------|---------|
|clickhouse_install|Установка Clickhouse|
|vector_install|Установка и настройка Vector|
|lighthouse_install|Установка и настройка lighthouse|
