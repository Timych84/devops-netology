# Домашнее задание к занятию "6.2. SQL"


## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume,
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.


```yml
version: '3'

services:
  db:
    image: postgres:12.13-alpine3.17
    restart: always
    volumes:
      - postgresql_db:/var/lib/postgresql/data
      - backup_db:/backup
    env_file:
      - db.env

volumes:
  postgresql_db:
  backup_db:
```



## Задача 2

В БД из задачи 1:
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)


```sql
CREATE DATABASE test_db;
\c test_db
CREATE USER "test-admin-user" WITH PASSWORD 'Passw0rd';


CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  name TEXT,
  price INTEGER
);

CREATE TABLE clients (
  id SERIAL PRIMARY KEY,
  surname TEXT,
  country TEXT,
  order_id integer REFERENCES orders (id)
);

GRANT ALL PRIVILEGES ON DATABASE "test_db" TO "test-admin-user";

GRANT ALL ON ALL TABLES IN SCHEMA public TO "test-admin-user";

CREATE USER "test-simple-user" WITH PASSWORD 'Passw0rd';

GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO "test-simple-user";

```



Приведите:
- итоговый список БД после выполнения пунктов выше,


```sql
postgres=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)
```


- описание таблиц (describe)


```sql
postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# \d+
                            List of relations
 Schema |      Name      |   Type   |  Owner   |    Size    | Description
--------+----------------+----------+----------+------------+-------------
 public | clients        | table    | postgres | 16 kB      |
 public | clients_id_seq | sequence | postgres | 8192 bytes |
 public | orders         | table    | postgres | 16 kB      |
 public | orders_id_seq  | sequence | postgres | 8192 bytes |
(4 rows)

test_db=# \d orders
                            Table "public.orders"
 Column |  Type   | Collation | Nullable |              Default
--------+---------+-----------+----------+------------------------------------
 id     | integer |           | not null | nextval('orders_id_seq'::regclass)
 name   | text    |           |          |
 price  | integer |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)

test_db=# \d clients
                             Table "public.clients"
  Column  |  Type   | Collation | Nullable |               Default
----------+---------+-----------+----------+-------------------------------------
 id       | integer |           | not null | nextval('clients_id_seq'::regclass)
 surname  | text    |           |          |
 country  | text    |           |          |
 order_id | integer |           |          |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)


```


- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db


```sql
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema='public';

     grantee      | privilege_type
------------------+----------------
 postgres         | INSERT
 postgres         | SELECT
 postgres         | UPDATE
 postgres         | DELETE
 postgres         | TRUNCATE
 postgres         | REFERENCES
 postgres         | TRIGGER
 test-admin-user  | INSERT
 test-admin-user  | SELECT
 test-admin-user  | UPDATE
 test-admin-user  | DELETE
 test-admin-user  | TRUNCATE
 test-admin-user  | REFERENCES
 test-admin-user  | TRIGGER
 test-simple-user | INSERT
 test-simple-user | SELECT
 test-simple-user | UPDATE
 test-simple-user | DELETE
 postgres         | INSERT
 postgres         | SELECT
 postgres         | UPDATE
 postgres         | DELETE
 postgres         | TRUNCATE
 postgres         | REFERENCES
 postgres         | TRIGGER
 test-admin-user  | INSERT
 test-admin-user  | SELECT
 test-admin-user  | UPDATE
 test-admin-user  | DELETE
 test-admin-user  | TRUNCATE
 test-admin-user  | REFERENCES
 test-admin-user  | TRIGGER
 test-simple-user | INSERT
 test-simple-user | SELECT
 test-simple-user | UPDATE
 test-simple-user | DELETE
(36 rows)
```



select
 *
from information_schema.role_table_grants
;

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы
- приведите в ответе:
    - запросы
    - результаты их выполнения.



```sql
INSERT INTO
    orders (name, price)
VALUES
    ('Шоколад',10),
    ('Принтер',3000),
    ('Книга',500),
    ('Монитор','7000'),
    ('Гитара','4000');
INSERT 0 5


INSERT INTO
    clients (surname, country)
VALUES
    ('Иванов Иван Иванович', 'USA'),
    ('Петров Петр Петрович', 'Canada'),
    ('Иоганн Себастьян Бах', 'Japan'),
    ('Ронни Джеймс Дио', 'Russia'),
    ('Ritchie Blackmore', 'Russia')
INSERT 0 5

select count(*) from clients;
 count
-------
     5
(1 row)

select count(*) from orders;
 count
-------
     5
(1 row)

```


## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

```sql
UPDATE clients
SET order_id = 3
WHERE surname='Иванов Иван Иванович';

UPDATE clients
SET order_id = 4
WHERE surname='Петров Петр Петрович';

UPDATE clients
SET order_id = 5
WHERE surname='Иоганн Себастьян Бах';

```


Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.


```sql
test_db=# SELECT * FROM clients where order_id is not null;
 id |       surname        | country | order_id
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(3 rows)

test_db=# SELECT c.surname, o.name  FROM clients c join orders o on c.order_id = o.id  where order_id is not null;
       surname        |  name
----------------------+---------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
(3 rows)

```


## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

```sql
test_db=# EXPLAIN (FORMAT YAML) SELECT * FROM clients where order_id is not null;
              QUERY PLAN
--------------------------------------
 - Plan:                             +
     Node Type: "Seq Scan"           +
     Parallel Aware: false           +
     Relation Name: "clients"        +
     Alias: "clients"                +
     Startup Cost: 0.00              +
     Total Cost: 18.10               +
     Plan Rows: 806                  +
     Plan Width: 72                  +
     Filter: "(order_id IS NOT NULL)"
(1 row)
```

- Тип: последовательное сканирование
- Startup Cost: Затраты на получение первой строки(0 т.к. последовательное скнирование)
- Total Cost: Затраты на получение всех строк(в случае с seq scan формула: (disk pages read * seq_page_cost) + (rows scanned * cpu_tuple_cost))
- Plan Rows: оценка количества строк(по оценке планировщика)
- Plan Width: Размер строки в байтах
- Filter: Применяемый фильтр к каждой строке(в данном случае не нулевой order_id)


## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).



```bash
pg_dump -U postgres test_db > /backup/test_db_dump.sql
```


Остановите контейнер с PostgreSQL (но не удаляйте volumes).


```bash
docker compose stop
[+] Running 1/1
 ⠿ Container postgresql-db-1  Stopped                                                                                                            0.4s
```


Поднимите новый пустой контейнер с PostgreSQL.

Запускаем новый контейнер с примонтированием volume с дампом базы:
```bash
docker run -d  -v postgresql_backup_db:/backup --env-file db.env --name new_postgres postgres:12.13-alpine3.17
```

Восстановите БД test_db в новом контейнере.


Создаем БД и восстанавливаем в нее дамп:

```bash
docker exec -it new_postgres /bin/bash
 psql -U postgres -c "CREATE DATABASE test_db;"
 psql -U postgres -d test_db < /backup/test_db_dump.sql
```

или одной командой:

```bash
docker exec -it new_postgres /bin/bash -c 'psql -U postgres -c "CREATE DATABASE test_db;"; psql -U postgres -d test_db < /backup/test_db_dump.sql'
```

в данном варианте не восстанавливаются привилегии, для этого надо применять или pg_dumpall или пользоваться другими способами резервного копирования(pg_basebackup, wal-g, pg_probackup и т.д.)

---
