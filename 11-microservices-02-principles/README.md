
# Домашнее задание к занятию «Микросервисы: принципы»

Вы работаете в крупной компании, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps-специалисту необходимо выдвинуть предложение по организации инфраструктуры для разработки и эксплуатации.

## Задача 1: API Gateway

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:
- маршрутизация запросов к нужному сервису на основе конфигурации,
- возможность проверки аутентификационной информации в запросах,
- обеспечение терминации HTTPS.

Обоснуйте свой выбор.

На рынке пристутствует большое количество решений, которые можно использовать в качестве API Gateway. Я рассмотрел четыре из них: Kong, Tyk, KrakenD, Nginx.

|Наименование решения  |Маршрутизация запросов к нужному сервису на основе конфигурации  |Возможность проверки аутентификационной информации в запросах  |Обеспечение терминации HTTPS  |
|---------|---------|---------|---------|
|Kong     |+ API/config         |+         |+         |
|Tyk     |+ API         |+         |+         |
|KrakenD     |+         |+         |+         |
|Nginx    |+         |+         |+         |


1. Kong - решение в основе которого лежит Nginx, имеет большое количество вариантов развертывания, для штатной работы требует наличия БД.
1. Tyk - решение написанное на Go, производитель позиционирует как решение с очень широкими возможностями в области безопасности, обладает высокой произоводительностью.
1. KrakenD - также написан на Go, позволяет легко разворачиваться, позиционируется как очень быстрое решение, имеет удобный инструмент по генерации конфигов.

Все рассмотренные продукты удовлетворяют требованиям.
В данном решении из-за небольшого набора требований я бы сделал выбор в пользу Nginx как самого легковесного решения пусть и без широкого функционала из коробки.


## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.
ns
Решение должно соответствовать следующим требованиям:
- поддержка кластеризации для обеспечения надёжности,
- хранение сообщений на диске в процессе доставки,
- высокая скорость работы,
- поддержка различных форматов сообщений,
- разделение прав доступа к различным потокам сообщений,
- простота эксплуатации.

Обоснуйте свой выбор.


|Требование                                             |Kafka    |RabbitMQ |Redis    |
|-|-|-|-|
|Поддержка кластеризации для обеспечения надёжности     |+        |+        |+        |
|Xранение сообщений на диске в процессе доставки        |+        |+        |-        |
|Высокая скорость работы                                |++       |+        |++       |
|Поддержка различных форматов сообщений                 |+        |+        |+        |
|Разделение прав доступа к различным потокам сообщений  |+        |+        |+        |
|Простота эксплуатации                                  |+        |+        |++       |


С точки зрения производительности, а также при обязательном требовании хранения сообщений на диске в процессе доставки лучшим решинем мне кажется Kafka. В случае сложной маршрутизации сообщений больше подойдет RabbitMQ. В целом если нужно простое и быстрое решение, то возможно больше подойдет Redis с настройкой сброса сообщений на диск


## Задача 3: API Gateway * (необязательная)

### Есть три сервиса:

**minio**
- хранит загруженные файлы в бакете images,
- S3 протокол,

**uploader**
- принимает файл, если картинка сжимает и загружает его в minio,
- POST /v1/upload,

**security**
- регистрация пользователя POST /v1/user,
- получение информации о пользователе GET /v1/user,
- логин пользователя POST /v1/token,
- проверка токена GET /v1/token/validation.

### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:

**POST /v1/register**
1. Анонимный доступ.
2. Запрос направляется в сервис security POST /v1/user.

**POST /v1/token**
1. Анонимный доступ.
2. Запрос направляется в сервис security POST /v1/token.

**GET /v1/user**
1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
2. Запрос направляется в сервис security GET /v1/user.

**POST /v1/upload**
1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
2. Запрос направляется в сервис uploader POST /v1/upload.

**GET /v1/user/{image}**
1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
2. Запрос направляется в сервис minio GET /images/{image}.

### Ожидаемый результат

Результатом выполнения задачи должен быть docker compose файл, запустив который можно локально выполнить следующие команды с успешным результатом.
Предполагается, что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки, который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
Авторизация
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token

**Загрузка файла**

curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload

**Получение файла**
curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg

---

#### [Дополнительные материалы: как запускать, как тестировать, как проверить](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles)



---
### Решение

Конфигурация nginx для работы приложений и консоли MinIO:

```ini
events {
    worker_connections 1024;
    multi_accept on;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    server {
        listen 8080 default_server;

        location /v1 {

            location /v1/register {
                proxy_pass http://security:3000/v1/user;
            }

            location /v1/token {
                proxy_pass http://security:3000/v1/token;
            }

            location /v1/token/validation {
                internal;
                proxy_pass http://security:3000/v1/token/validation;
                proxy_pass_request_body off;
                proxy_set_header        Content-Length "";
                proxy_set_header        X-Original-URI $request_uri;
            }

            location /v1/user {
                proxy_pass http://security:3000/v1/user;
            }

            location ~ ^/v1/user/(.*)$ {
                auth_request /v1/token/validation;
                rewrite ^/v1/user/(.*)$ /data/$1 break;
                proxy_pass http://storage:9000;
            }

            location /v1/status {
                auth_request /v1/token/validation;
                proxy_pass http://security:3000/status;
            }

            location /v1/upload {
                auth_request /v1/token/validation;
                proxy_pass http://uploader:3000/v1/upload;
            }

            location /v1/images {
                auth_request /v1/token/validation;
                proxy_pass http://storage:9000/data;
            }


        }
    }
    server {
        listen 8080;
        server_name minio.example.com;
        ignore_invalid_headers off;
        client_max_body_size 0;
        proxy_buffering off;
        proxy_request_buffering off;
        location / {
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-NginX-Proxy true;
            real_ip_header X-Real-IP;
            proxy_connect_timeout 300;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            chunked_transfer_encoding off;
            proxy_pass http://storage:9001/;

        }
    }

}
```

Получаем токен:

```bash
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://192.168.171.200/v1/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
```


Проверка токена(отключена для внешнего доступа в итоговом конфиге nginx):

```bash
curl -X GET -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I'  http://192.168.171.200/v1/token/validation
```

Загрузка файла:

```bash
curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @Untitled.jpg http://192.168.171.200/v1/upload
{"filename":"46bfa775-2a60-4f56-b261-7c9f048e10b5.jpg"}
```

Скачивание файла (2 варианта v1/user/ и v1/images/):

```bash
curl -X GET -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I'  http://192.168.171.200/v1/user/46bfa775-2a60-4f56-b261-7c9f048e10b5.jpg -o download.jpg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  5181  100  5181    0     0  1686k      0 --:--:-- --:--:-- --:--:-- 1686k

curl -X GET -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I'  http://192.168.171.200/v1/images/46bfa775-2a60-4f56-b261-7c9f048e10b5.jpg -o download.jpg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  5181  100  5181    0     0  1686k      0 --:--:-- --:--:-- --:--:-- 1686k
```

[Итоговый Docker Compose](https://github.com/Timych84/devops-netology/blob/main/11-microservices-02-principles/docker-compose.yaml)

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
