# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
  - \l
- подключения к БД
  - \c
- вывода списка таблиц
  - \d
- вывода описания содержимого таблиц
  - \d имя_таблицы
- выхода из psql
  - \q

## Задача 2

Используя `psql` создайте БД `test_database`.

psql -U postgres -c "CREATE DATABASE test_database;"
CREATE DATABASE "test_database";


Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

cat test_dump.sql | docker exec -i postgresql-db-1 /bin/bash -c 'psql -U postgres -d test_database'


Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.


```sql
\c test_database;
ANALYZE orders;
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders`
с наибольшим средним значением размера элементов в байтах.


**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```sql
test_database=# select tablename, attname, avg_width from pg_stats where tablename = 'orders' order by avg_width desc;
 tablename | attname | avg_width
-----------+---------+-----------
 orders    | title   |        16
 orders    | id      |         4
 orders    | price   |         4
(3 rows)
```

Столбец title 16 байт.

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders? Можно сразу было сделать разделение таблицы.



```sql
test_database=# \d orders
                                 Table "public.orders"
 Column |         Type          | Collation | Nullable |              Default
--------+-----------------------+-----------+----------+------------------------------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass)
 title  | character varying(80) |           | not null |
 price  | integer               |           |          | 0
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)


CREATE TABLE orders_tmp (LIKE orders INCLUDING DEFAULTS INCLUDING CONSTRAINTS) PARTITION BY RANGE (price);

CREATE TABLE orders_2
    PARTITION OF orders_tmp
    FOR VALUES FROM (MINVALUE) TO (500);

CREATE TABLE orders_1
    PARTITION OF orders_tmp
    FOR VALUES FROM (500) TO (MAXVALUE);


ALTER TABLE orders_tmp ADD PRIMARY KEY (id, price);

INSERT INTO orders_tmp SELECT * FROM orders;


ALTER TABLE orders RENAME TO orders_bak;
ALTER TABLE orders_tmp RENAME TO orders;
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

```bash
pg_dump -U postgres test_database > /backup/test_database_dump.sql
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

добавить UNIQUE для столбца title,

```sql
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) UNIQUE NOT NULL,
    price integer DEFAULT 0
);
```
