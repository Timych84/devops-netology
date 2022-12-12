
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

https://hub.docker.com/r/timych84/nginx-timych


## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
  - Java приложение подходит для работы в контейнерах,
  - https://blogs.oracle.com/java/post/java-se-support-for-docker-cpu-and-memory-limits
  - из преимуществ простота развертывания и переноса, отсутствие пересечения с другими сервисами.
- Nodejs веб-приложение;
    - Подходит. Простота развертывания, возможность параллельного запуска нескольких контейнеров.
- Мобильное приложение c версиями для Android и iOS;
  - Возможно использовать при тестировании приложений.
- Шина данных на базе Apache Kafka;
  - Хорошо подходит для работы в контейнере. Упрощается масштабирование, простота развертывания.
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
  - Хорошо подходит для контейнеризации, но нужно решать вопрос хранения данных вне контейнера
- Мониторинг-стек на базе Prometheus и Grafana;
    - Хорошо подходит для контейнеризации, но нужно решать вопрос хранения данных вне контейнера
- MongoDB, как основное хранилище данных для java-приложения;
  - Подходит любая реализация в зависимости от масштабов решиения и требуемой производительности.
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.
  - Можно использовать и ВМ и в контейнере в зависимости от масштабов и требований. Есть готовые решения на docker.

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

https://hub.docker.com/r/timych84/ansible

Dockerfile:

```dockerfile
# pull base image
FROM alpine:3.16

ARG ANSIBLE_CORE_VERSION_ARG="2.9.27"
ARG ANSIBLE_LINT="5.4.0"
ENV ANSIBLE_LINT=${ANSIBLE_LINT}
ENV ANSIBLE_CORE=${ANSIBLE_CORE_VERSION_ARG}
# ENV ANSIBLE_CORE "2.9.27"
# ENV ANSIBLE_LINT "5.4.0"

# Labels.
LABEL maintainer="tdalexeev@gmail.com"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.name="timych84/ansible"
LABEL org.label-schema.description="Ansible inside Docker"
LABEL org.label-schema.vendor="Timych84"
LABEL org.label-schema.docker.cmd="docker run --rm -it -v $(pwd):/ansible -v ~/.ssh/id_rsa:/root/id_rsa timych84/ansible:2.9.27"

RUN CARGO_NET_GIT_FETCH_WITH_CLI=1 && \
    apk --no-cache add \
        sudo \
        python3\
        py3-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        musl-dev \
        gcc \
        cargo \
        openssl-dev \
        libressl-dev \
        build-base && \
    CARGO_NET_GIT_FETCH_WITH_CLI=1 && \
    pip install --upgrade pip wheel && \
    pip install --upgrade cryptography cffi && \
    pip install ansible==${ANSIBLE_CORE} && \
    pip install mitogen==0.2.10 ansible-lint==${ANSIBLE_LINT} jmespath && \
    pip install --upgrade pywinrm && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
```
