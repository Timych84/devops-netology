# Домашнее задание к занятию "3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/blob/virt-11/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

```yaml
version: '3.1'

services:
  db:
    image: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: db
    volumes:
      - mysql:/var/lib/mysql
  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
volumes:
  mysql:
```

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-03-mysql/test_data) и
восстановитесь из него.


```bash
docker exec -i mysql-db-1 mysql -uroot -prootpass database  < ./test_dump.sql
```


Перейдите в управляющую консоль `mysql` внутри контейнера.


```bash
mysql -uroot -p database
```

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

```sql
status
...
Server version:         8.0.32 MySQL Community Server - GPL
...
```


Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

```sql
mysql> show tables;
+--------------------+
| Tables_in_database |
+--------------------+
| orders             |
+--------------------+
1 row in set (0.00 sec)


mysql> select * from orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)

mysql> select * from orders where price>300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```


В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней
- количество попыток авторизации - 3
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.


```sql
mysql> CREATE USER 'test'@'%' IDENTIFIED WITH mysql_native_password BY 'test-pass'
    -> WITH MAX_QUERIES_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3
    -> ATTRIBUTE '{"Name": "James", "Surname":"Pretty"}';
Query OK, 0 rows affected (0.01 sec)

mysql> GRANT SELECT ON db.* TO 'test'@'%';
Query OK, 0 rows affected (0.00 sec)
```
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и
**приведите в ответе к задаче**.

```sql
mysql> select * from INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
+------+------+----------------------------------------+
| USER | HOST | ATTRIBUTE                              |
+------+------+----------------------------------------+
| test | %    | {"Name": "James", "Surname": "Pretty"} |
+------+------+----------------------------------------+
1 row in set (0.01 sec)
```



## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

mysql> SELECT engine, table_name FROM information_schema.TABLES WHERE TABLE_SCHEMA='db';
+--------+------------+
| ENGINE | TABLE_NAME |
+--------+------------+
| InnoDB | orders     |
+--------+------------+
1 row in set (0.00 sec)



Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

```sql
mysql> ALTER TABLE orders ENGINE='MyISAM';
Query OK, 5 rows affected (0.08 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM db.orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)

mysql> SHOW PROFILES;
+----------+------------+-----------------------------------+
| Query_ID | Duration   | Query                             |
+----------+------------+-----------------------------------+
...
|        4 | 0.00031075 | SELECT * FROM db.orders           |
...
|       10 | 0.07899200 | ALTER TABLE orders ENGINE='MyISAM'|
|       11 | 0.00315100 | SELECT * FROM db.orders           |
+----------+------------+-----------------------------------+
11 rows in set, 1 warning (0.02 sec)

mysql> ALTER TABLE orders ENGINE='InnoDB';
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM db.orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)
```

Время выполнения:
```sql
mysql> SHOW PROFILES;
+----------+------------+------------------------------------+
| Query_ID | Duration   | Query                              |
+----------+------------+------------------------------------+
|        4 | 0.00031075 | SELECT * FROM db.orders            |
|       10 | 0.07899200 | ALTER TABLE orders ENGINE='MyISAM' |
|       11 | 0.00315100 | SELECT * FROM db.orders            |
|       12 | 0.02308175 | ALTER TABLE orders ENGINE='InnoDB' |
|       13 | 0.00039275 | SELECT * FROM db.orders            |
+----------+------------+------------------------------------+
13 rows in set, 1 warning (0.00 sec)


```



## Задача 4

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

```bash
[mysqld]

#Быстрая запись в ущерб надежности
innodb_flush_method=O_DSYNC

#скорость важнее сохранности данных
innodb_flush_log_at_trx_commit = 2


#Нужна компрессия таблиц для экономии места на диске, кокретного параметра для компрессии не нашел.
#Исходя из документации таблица должна создаваться с параметром ROW_FORMAT=COMPRESSED, возможно после можно использовать параметр innodb_page_size

#Размер буффера с незакомиченными транзакциями 1 Мб
innodb_log_buffer_size=1M

#Буффер кеширования 30% от ОЗУ(~30% от 8ГБ)
innodb_buffer_pool_size = 2457M

#Размер файла логов операций 100 Мб
#innodb_log_file_size=100M - считается Deprecated и заменена на innodb_redo_log_capacity, 2 файла по 100МБ
innodb_redo_log_capacity=200M


skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/
```
