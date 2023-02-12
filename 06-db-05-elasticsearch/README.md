# Домашнее задание к занятию "5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста

```dockerfile
FROM centos:7

ENV ES_PKG_NAME elasticsearch-8.6.1
ENV PATH /usr/share/elasticsearch/bin:$PATH

RUN \
  cd / && \
  yum update -q -y && \
  yum install -q -y perl-Digest-SHA wget && \
  wget -q https://artifacts.elastic.co/downloads/elasticsearch/$ES_PKG_NAME-linux-x86_64.tar.gz && \
  wget -q https://artifacts.elastic.co/downloads/elasticsearch/$ES_PKG_NAME-linux-x86_64.tar.gz.sha512 && \
  shasum -a 512 -c $ES_PKG_NAME-linux-x86_64.tar.gz.sha512 && \
  tar -xzf $ES_PKG_NAME-linux-x86_64.tar.gz && \
  rm -f $ES_PKG_NAME-linux-x86_64.tar.gz $ES_PKG_NAME-linux-x86_64.tar.gz.sha512 && \
  mv /$ES_PKG_NAME /usr/share/elasticsearch && \
  yum -q -y remove perl-Digest-SHA && \
  yum -q -y clean all && \
  rm -rf /var/cache && \
  groupadd -g 10001 elastic && \
  useradd -u 10000 -g elastic elastic && \
  chown -R elastic:elastic /usr/share/elasticsearch
RUN \
  mkdir /var/lib/elasticsearch /var/log/elasticsearch && \
  chown -R elastic:elastic /var/lib/elasticsearch /var/log/elasticsearch && \
  sed -i 's/#cluster.name: my-application/cluster.name: netology-cluster/g' /usr/share/elasticsearch/config/elasticsearch.yml && \
  sed -i 's/#node.name: node-1/node.name: netology_test/g' /usr/share/elasticsearch/config/elasticsearch.yml && \
  sed -i 's,#path.data: /path/to/data,path.data: /var/lib/elasticsearch,g' /usr/share/elasticsearch/config/elasticsearch.yml && \
  sed -i 's,#path.logs: /path/to/logs,path.logs: /var/log/elasticsearch,g' /usr/share/elasticsearch/config/elasticsearch.yml

USER elastic:elastic

WORKDIR /usr/share/elasticsearch

CMD ["/usr/share/elasticsearch/bin/elasticsearch"]

EXPOSE 9200
EXPOSE 9300
```


- ссылку на образ в репозитории dockerhub

[Репозиторий на DockerHub](https://hub.docker.com/r/timych84/elastic-tim)
- ответ `elasticsearch` на запрос пути `/` в json виде


```json
[elastic@ff9e31e30256 elasticsearch]$ curl -X GET "https://192.168.171.200:9200/?pretty"  -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure
{
  "name" : "netology_test",
  "cluster_name" : "netology-cluster",
  "cluster_uuid" : "r4pFnTpJSDm3AugJkluHtA",
  "version" : {
    "number" : "8.6.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "180c9830da956993e59e2cd70eb32b5e383ea42c",
    "build_date" : "2023-01-24T21:35:11.506992272Z",
    "build_snapshot" : false,
    "lucene_version" : "9.4.2",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```



Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html)
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |



```json
curl -X PUT "https://192.168.171.200:9200/ind-1?pretty"   -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "index": {
>       "number_of_shards": 1,
>       "number_of_replicas": 0
>     }
>   }
> }

curl -X PUT "https://192.168.171.200:9200/ind-2?pretty"   -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 2,
      "number_of_replicas": 1
    }
  }
}
'

curl -X PUT "https://192.168.171.200:9200/ind-3?pretty"   -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 4,
      "number_of_replicas": 2
    }
  }
}
'
```



Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.


```bash
timych@timych-ubu2:~$ curl --cacert ./http_ca.crt -XGET "https://192.168.171.200:9200/_cat/indices/ind-*?pretty" -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure
green  open ind-1 kZPX1Vt6T3ekmxwxFraPTg 1 0 0 0 225b 225b
yellow open ind-3 WrcOlocjTS-63POCgNNBjQ 4 2 0 0 900b 900b
yellow open ind-2 ToapxjI4Rrq0aSeLjFSLdA 2 1 0 0 450b 450b
```

Получите состояние кластера `elasticsearch`, используя API.


```json
timych@timych-ubu2:~$ curl --cacert ./http_ca.crt -XGET "https://192.168.171.200:9200/_cluster/health?pretty" -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure
{
  "cluster_name" : "netology-cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 11,
  "active_shards" : 11,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 52.38095238095239
}
```



Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

- из-за того, что в созданных индексах указаны реплики, а при этом всё размещено на одной ноде.

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository)
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.


```json
timych@timych-ubu2:~$ curl -X PUT "https://192.168.171.200:9200/_snapshot/netology_backup?pretty" -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure  -H 'Content-Type: application/json' -d'
> {
>   "type": "fs",
>   "settings": {
>     "location": "/usr/share/elasticsearch/snapshots"
>   }
> }
> '
{
  "acknowledged" : true
}
```



Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.


```json
timych@timych-ubu2:~$ curl -X PUT "https://192.168.171.200:9200/test?pretty"   -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "index": {
>       "number_of_shards": 1,
>       "number_of_replicas": 0
>     }
>   }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}
timych@timych-ubu2:~$ curl --cacert ./http_ca.crt -XGET "https://192.168.171.200:9200/_cat/indices/*?pretty" -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure
green open test c8yiHFnGT02FmtaSmiu2Ug 1 0 0 0 225b 225b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html)
состояния кластера `elasticsearch`.


```json
timych@timych-ubu2:~$ curl -X PUT "https://192.168.171.200:9200/_snapshot/netology_backup/my_snapshot?pretty" -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure   -H 'Content-Type: application/json' -d'
> {
>   "indices": "test"
> }
> '
{
  "accepted" : true
}
```



**Приведите в ответе** список файлов в директории со `snapshot`ами.


```bash
[elastic@ff9e31e30256 elasticsearch]$ ll snapshots/
total 36
-rw-r--r-- 1 elastic elastic  1674 Feb 12 21:10 index-2
-rw-r--r-- 1 elastic elastic     8 Feb 12 21:10 index.latest
drwxr-xr-x 7 elastic elastic  4096 Feb 12 21:10 indices
-rw-r--r-- 1 elastic elastic 18962 Feb 12 21:10 meta-KFSgAHtPSsKQJ4A4Rv2SGA.dat
-rw-r--r-- 1 elastic elastic   485 Feb 12 21:10 snap-KFSgAHtPSsKQJ4A4Rv2SGA.dat
```


Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```json
timych@timych-ubu2:~$ curl -X DELETE "https://192.168.171.200:9200/test?pretty" --cacert ./http_ca.crt -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure
{
  "acknowledged" : true
}
timych@timych-ubu2:~$ curl -X PUT "https://192.168.171.200:9200/test-2?pretty"   -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "index": {
>       "number_of_shards": 1,
>       "number_of_replicas": 0
>     }
>   }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}

timych@timych-ubu2:~$ curl --cacert ./http_ca.crt -XGET "https://192.168.171.200:9200/_cat/indices/*?pretty" -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure
green open test-2 ypEenT7iSv6REorndeJvPg 1 0 0 0 225b 225b

```
[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.

```json
timych@timych-ubu2:~$ curl -X GET "https://192.168.171.200:9200/_cat/snapshots/netology_backup?v=true&s=id&pretty" -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure
id          repository       status start_epoch start_time end_epoch  end_time duration indices successful_shards failed_shards total_shards
my_snapshot netology_backup SUCCESS 1676236468  21:14:28   1676236469 21:14:29       1s       3                 3             0            3
```

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.


```json
timych@timych-ubu2:~$ curl -X POST "https://192.168.171.200:9200/_snapshot/netology_backup/my_snapshot/_restore?pretty"  -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure
{
  "accepted" : true
}

timych@timych-ubu2:~$ curl --cacert ./http_ca.crt -XGET "https://192.168.171.200:9200/_cat/indices/*?pretty" -u elastic:hBpqxHH3NNQy2q4kLzg8 --insecure
green open test-2 ypEenT7iSv6REorndeJvPg 1 0 0 0 225b 225b
green open test   RiR8KR0jSBuAG7T_PUsBsA 1 0 0 0 225b 225b
timych@timych-ubu2:~$
```



Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`
