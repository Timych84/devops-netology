
## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.



## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- Шина данных на базе Apache Kafka;
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;
- MongoDB, как основное хранилище данных для java-приложения;
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.



    ```bash
    timych@timych-ubu-n1:~$ docker run -dit --name debian-tim -v ~/data:/data debian:11.5 /bin/bash
    timych@timych-ubu-n1:~$ docker run -dit --name centos-tim -v ~/data:/data centos:centos7.9.2009 /bin/bash

    timych@timych-ubu-n1:~$ docker exec -it centos-tim /bin/bash
    [root@395450d7c283 /]# vi /data/testfile_centos.tst

    timych@timych-ubu-n1:~$ vi ~/data/testfile_host.tst

    timych@timych-ubu-n1:~$ docker exec -it debian-tim /bin/bash
    root@8c1419c06c05:/# ls -la /data/
    total 16
    drwxrwxr-x 2 1000 1000 4096 Nov 25 10:54 .
    drwxr-xr-x 1 root root 4096 Nov 25 10:46 ..
    -rw-r--r-- 1 root root    5 Nov 25 10:52 testfile_centos.tst
    -rw-rw-r-- 1 1000 1000    8 Nov 25 10:49 testfile_host.tst

    root@8c1419c06c05:/# cat /data/testfile_centos.tst
    TEST

    root@8c1419c06c05:/# cat /data/testfile_host.tst
    testing

    ```


## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

https://hub.docker.com/repository/docker/timych84/ansible


https://hub.docker.com/r/timych84/ansible
