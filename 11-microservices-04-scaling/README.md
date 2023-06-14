
# Домашнее задание к занятию "11.04 Микросервисы: масштабирование"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: Кластеризация

Предложите решение для обеспечения развертывания, запуска и управления приложениями.
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- Поддержка контейнеров;
- Обеспечивать обнаружение сервисов и маршрутизацию запросов;
- Обеспечивать возможность горизонтального масштабирования;
- Обеспечивать возможность автоматического масштабирования;
- Обеспечивать явное разделение ресурсов доступных извне и внутри системы;
- Обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т.п.

Обоснуйте свой выбор.

## Решение

Решение соответствующее требованиям - Kubernetes

|Требование  |Примечание  |
|---------|---------|
|Поддержка контейнеров|Поддерживаются различные рантаймы контейнеров containerd,docker, cri-o  |
|Обнаружение сервисов и маршрутизацию запросов|Используя Kubernetes DNS-Based Service Discovery, |
|Горизонтальное масштабирование|Можно легко увеличивать количество pod|
|Автоматическое масштабирование|Используя Horizontal Pod Autoscaling|
|Явное разделение ресурсов доступных извне и внутри системы|Используя NetworkPolicy|
|Возможность конфигурировать приложения с помощью переменных среды|Возможно используя ConfigMaps, а для чувствительных данных Secrets|

Выбранное решение покрывает полностю все требования и позовляет обеспечить
дальнейшее развитие.

В данный момент изучил упомянутые темы только в разрезе этого домашнего задания, далее насколько я понимаю мы изучим их в процессе обучения.


## Задача 2: Распределенный кэш * (необязательная)

Разработчикам вашей компании понадобился распределенный кэш для организации хранения временной информации по сессиям пользователей.
Вам необходимо построить Redis Cluster состоящий из трех шард с тремя репликами.

### Схема:

![11-04-01](https://user-images.githubusercontent.com/1122523/114282923-9b16f900-9a4f-11eb-80aa-61ed09725760.png)

---

## Решение

Для выполнения сделал Playbook:

```yml
---
- name: Install Redis in Docker
  hosts: redis_cluster
  become: true
  tasks:
    - name: Add Docker GPG apt Key
      ansible.builtin.apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present
    - name: Add Docker Repository
      ansible.builtin.apt_repository:
        repo: deb https://download.docker.com/linux/ubuntu focal stable
        state: present
    - name: Update apt and install docker-ce
      ansible.builtin.apt:
        name: "{{ item }}"
        state: latest
        update_cache: true
      with_items:
        - docker-ce
        - docker-compose-plugin
    - name: Install pip
      ansible.builtin.apt:
        name: pip
        state: latest
        update_cache: true
    - name: Install Docker Module for Python
      ansible.builtin.pip:
        name:
          - docker
          - urllib3<2
    - name: Add the current user to docker group
      ansible.builtin.user:
        name: timych
        append: true
        groups: docker
    - name: Start and enable Docker service
      ansible.builtin.service:
        name: docker
        state: started
        enabled: true
      tags: docker
    - name: Copy Redis configuration file
      ansible.builtin.copy:
        src: "{{ item }}"
        dest: /opt/redis/
        mode: '0644'
      tags: redis
      with_items:
        - ./redis-node-master.conf
        - ./redis-node-slave.conf
    - name: Pull Redis Docker image
      community.docker.docker_image:
        name: redis
        source: pull
      tags: redis
    - name: Create a volume for Redis master
      community.docker.docker_volume:
        name: redis-master-data
    - name: Create a volume for Redis slave
      community.docker.docker_volume:
        name: redis-slave-data
    - name: Create Redis master container
      community.docker.docker_container:
        name: redis_master
        image: redis
        state: started
        ports:
          - "{{ redis_master_port }}:{{ redis_master_port }}"
          - "{{ redis_cluster_master_port }}:{{ redis_cluster_master_port }}"
        restart_policy: always
        command: redis-server /usr/local/etc/redis/redis.conf
        volumes:
          - "/opt/redis/redis-node-master.conf:/usr/local/etc/redis/redis.conf"
          - redis-master-data:/data
      tags: redis
    - name: Create Redis slave container
      community.docker.docker_container:
        name: redis_slave
        image: redis
        state: started
        ports:
          - "{{ redis_slave_port }}:{{ redis_slave_port }}"
          - "{{ redis_cluster_slave_port }}:{{ redis_cluster_slave_port }}"
        restart_policy: always
        command: redis-server /usr/local/etc/redis/redis.conf
        volumes:
          - "/opt/redis/redis-node-slave.conf:/usr/local/etc/redis/redis.conf"
          - redis-slave-data:/data
      tags: redis
```
Конифигурационные фалы Redis.


redis-node-master.conf:
```ini
port 6373
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
```

redis-node-slave.conf:

```ini
port 6374
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
```


Запускаем playbook на следующем inventory:

```yml
---
all:
  hosts:
    redis-host-1:
      ansible_host: 192.168.171.101
    redis-host-2:
      ansible_host: 192.168.171.102
    redis-host-3:
      ansible_host: 192.168.171.103
redis_cluster:
  hosts:
    redis-host-1:
    redis-host-2:
    redis-host-3:
```

Результат:


```bash
timych@timych-ubu2:~/11-microservices-04-scaling$ ansible-playbook -i inventory.yaml redis-cluster.yaml

PLAY [Install Redis in Docker] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************
ok: [redis-host-2]
ok: [redis-host-1]
ok: [redis-host-3]

TASK [Add Docker GPG apt Key] *************************************************************************************************************************************************************************
changed: [redis-host-3]
changed: [redis-host-1]
changed: [redis-host-2]

TASK [Add Docker Repository] **************************************************************************************************************************************************************************
changed: [redis-host-3]
changed: [redis-host-1]
changed: [redis-host-2]

TASK [Update apt and install docker-ce] ***************************************************************************************************************************************************************
changed: [redis-host-3] => (item=docker-ce)
changed: [redis-host-1] => (item=docker-ce)
ok: [redis-host-3] => (item=docker-compose-plugin)
ok: [redis-host-1] => (item=docker-compose-plugin)
changed: [redis-host-2] => (item=docker-ce)
ok: [redis-host-2] => (item=docker-compose-plugin)

TASK [Install pip] ************************************************************************************************************************************************************************************
changed: [redis-host-1]
changed: [redis-host-2]
changed: [redis-host-3]

TASK [Install Docker Module for Python] ***************************************************************************************************************************************************************
changed: [redis-host-1]
changed: [redis-host-3]
changed: [redis-host-2]

TASK [Add the current user to docker group] ***********************************************************************************************************************************************************
changed: [redis-host-2]
changed: [redis-host-3]
changed: [redis-host-1]

TASK [Start and enable Docker service] ****************************************************************************************************************************************************************
ok: [redis-host-1]
ok: [redis-host-3]
ok: [redis-host-2]

TASK [Copy Redis configuration file] ******************************************************************************************************************************************************************
changed: [redis-host-1] => (item=./redis-node-master.conf)
changed: [redis-host-3] => (item=./redis-node-master.conf)
changed: [redis-host-2] => (item=./redis-node-master.conf)
changed: [redis-host-2] => (item=./redis-node-slave.conf)
changed: [redis-host-1] => (item=./redis-node-slave.conf)
changed: [redis-host-3] => (item=./redis-node-slave.conf)

TASK [Pull Redis Docker image] ************************************************************************************************************************************************************************
changed: [redis-host-1]
changed: [redis-host-2]
changed: [redis-host-3]

TASK [Create a volume for Redis master] ***************************************************************************************************************************************************************
changed: [redis-host-1]
changed: [redis-host-2]
changed: [redis-host-3]

TASK [Create a volume for Redis slave] ****************************************************************************************************************************************************************
changed: [redis-host-1]
changed: [redis-host-2]
changed: [redis-host-3]

TASK [Create Redis master container] ******************************************************************************************************************************************************************
changed: [redis-host-3]
changed: [redis-host-2]
changed: [redis-host-1]

TASK [Create Redis slave container] *******************************************************************************************************************************************************************
changed: [redis-host-1]
changed: [redis-host-3]
changed: [redis-host-2]

PLAY RECAP ********************************************************************************************************************************************************************************************
redis-host-1               : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
redis-host-2               : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
redis-host-3               : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Далее по заданию требуется чтобы конкретные экземпляры redis были репликой для конкретных экземпляров redis.
Создаем кластер без реплик:

```bash
timych@timych-ubu-n1:~$ docker exec -it redis_master redis-cli --cluster create 192.168.171.101:6373 192.168.171.102:6373 192.168.171.103:6373 --cluster-yes
>>> Performing hash slots allocation on 3 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
M: 9a4496441e0fbba5d083e65a5e6123553c05c145 192.168.171.101:6373
   slots:[0-5460] (5461 slots) master
M: 7efa8f215912dc8ff8ababfd9781340667b6bbd9 192.168.171.102:6373
   slots:[5461-10922] (5462 slots) master
M: 5f9d9de492cc4019a0b231f40fed256b3ae1143e 192.168.171.103:6373
   slots:[10923-16383] (5461 slots) master
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join

>>> Performing Cluster Check (using node 192.168.171.101:6373)
M: 9a4496441e0fbba5d083e65a5e6123553c05c145 192.168.171.101:6373
   slots:[0-5460] (5461 slots) master
M: 7efa8f215912dc8ff8ababfd9781340667b6bbd9 192.168.171.102:6373
   slots:[5461-10922] (5462 slots) master
M: 5f9d9de492cc4019a0b231f40fed256b3ae1143e 192.168.171.103:6373
   slots:[10923-16383] (5461 slots) master
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```
Далее добавляем реплики к конкретным мастерам:


```bash
timych@timych-ubu-n1:~$ docker exec -it redis_master redis-cli --cluster add-node 192.168.171.103:6374 192.168.171.101:6373 --cluster-slave --cluster-master-id 9a4496441e0fbba5d083e65a5e6123553c05c145
>>> Adding node 192.168.171.103:6374 to cluster 192.168.171.101:6373
>>> Performing Cluster Check (using node 192.168.171.101:6373)
M: 9a4496441e0fbba5d083e65a5e6123553c05c145 192.168.171.101:6373
   slots:[0-5460] (5461 slots) master
M: 7efa8f215912dc8ff8ababfd9781340667b6bbd9 192.168.171.102:6373
   slots:[5461-10922] (5462 slots) master
M: 5f9d9de492cc4019a0b231f40fed256b3ae1143e 192.168.171.103:6373
   slots:[10923-16383] (5461 slots) master
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 192.168.171.103:6374 to make it join the cluster.
Waiting for the cluster to join

>>> Configure node as replica of 192.168.171.101:6373.
[OK] New node added correctly.
timych@timych-ubu-n1:~$ docker exec -it redis_master redis-cli --cluster add-node 192.168.171.102:6374 192.168.171.101:6373 --cluster-slave --cluster-master-id 5f9d9de492cc4019a0b231f40fed256b3ae1143e
>>> Adding node 192.168.171.102:6374 to cluster 192.168.171.101:6373
>>> Performing Cluster Check (using node 192.168.171.101:6373)
M: 9a4496441e0fbba5d083e65a5e6123553c05c145 192.168.171.101:6373
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: 7efa8f215912dc8ff8ababfd9781340667b6bbd9 192.168.171.102:6373
   slots:[5461-10922] (5462 slots) master
S: 7d264061a122e625305518d27fa125f0701e7b09 192.168.171.103:6374
   slots: (0 slots) slave
   replicates 9a4496441e0fbba5d083e65a5e6123553c05c145
M: 5f9d9de492cc4019a0b231f40fed256b3ae1143e 192.168.171.103:6373
   slots:[10923-16383] (5461 slots) master
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 192.168.171.102:6374 to make it join the cluster.
Waiting for the cluster to join

>>> Configure node as replica of 192.168.171.103:6373.
[OK] New node added correctly.
timych@timych-ubu-n1:~$ docker exec -it redis_master redis-cli --cluster add-node 192.168.171.101:6374 192.168.171.101:6373 --cluster-slave --cluster-master-id 7efa8f215912dc8ff8ababfd9781340667b6bbd9
>>> Adding node 192.168.171.101:6374 to cluster 192.168.171.101:6373
>>> Performing Cluster Check (using node 192.168.171.101:6373)
M: 9a4496441e0fbba5d083e65a5e6123553c05c145 192.168.171.101:6373
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: 5f9d9de492cc4019a0b231f40fed256b3ae1143e 192.168.171.103:6373
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: 7efa8f215912dc8ff8ababfd9781340667b6bbd9 192.168.171.102:6373
   slots:[5461-10922] (5462 slots) master
S: 7d264061a122e625305518d27fa125f0701e7b09 192.168.171.103:6374
   slots: (0 slots) slave
   replicates 9a4496441e0fbba5d083e65a5e6123553c05c145
S: 96462acd34e074fa70d56414c0d1e346149724fc 192.168.171.102:6374
   slots: (0 slots) slave
   replicates 5f9d9de492cc4019a0b231f40fed256b3ae1143e
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 192.168.171.101:6374 to make it join the cluster.
Waiting for the cluster to join

>>> Configure node as replica of 192.168.171.102:6373.
[OK] New node added correctly.
```

Проверяем корректность работы:

```bash
timych@timych-ubu-n1:~$ docker exec -it redis_master  redis-cli -h 192.168.171.101 -p 6373 -c CLUSTER NODES
5f9d9de492cc4019a0b231f40fed256b3ae1143e 192.168.171.103:6373@16373 master - 0 1686755894214 3 connected 10923-16383
198b0a23f424319b66252e885948de0b9dc3afbf 172.17.0.1:6374@16374 slave 7efa8f215912dc8ff8ababfd9781340667b6bbd9 0 1686755893105 2 connected
9a4496441e0fbba5d083e65a5e6123553c05c145 172.17.0.2:6373@16373 myself,master - 0 1686755894000 1 connected 0-5460
7efa8f215912dc8ff8ababfd9781340667b6bbd9 192.168.171.102:6373@16373 master - 0 1686755894000 2 connected 5461-10922
7d264061a122e625305518d27fa125f0701e7b09 192.168.171.103:6374@16374 slave 9a4496441e0fbba5d083e65a5e6123553c05c145 0 1686755894000 1 connected
96462acd34e074fa70d56414c0d1e346149724fc 192.168.171.102:6374@16374 slave 5f9d9de492cc4019a0b231f40fed256b3ae1143e 0 1686755894719 3 connected
timych@timych-ubu-n1:~$ docker exec -it redis_master  redis-cli --cluster check 192.168.171.101:6373
192.168.171.101:6373 (9a449644...) -> 0 keys | 5461 slots | 1 slaves.
192.168.171.103:6373 (5f9d9de4...) -> 0 keys | 5461 slots | 1 slaves.
192.168.171.102:6373 (7efa8f21...) -> 0 keys | 5462 slots | 1 slaves.
[OK] 0 keys in 3 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 192.168.171.101:6373)
M: 9a4496441e0fbba5d083e65a5e6123553c05c145 192.168.171.101:6373
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: 5f9d9de492cc4019a0b231f40fed256b3ae1143e 192.168.171.103:6373
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 198b0a23f424319b66252e885948de0b9dc3afbf 172.17.0.1:6374
   slots: (0 slots) slave
   replicates 7efa8f215912dc8ff8ababfd9781340667b6bbd9
M: 7efa8f215912dc8ff8ababfd9781340667b6bbd9 192.168.171.102:6373
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 7d264061a122e625305518d27fa125f0701e7b09 192.168.171.103:6374
   slots: (0 slots) slave
   replicates 9a4496441e0fbba5d083e65a5e6123553c05c145
S: 96462acd34e074fa70d56414c0d1e346149724fc 192.168.171.102:6374
   slots: (0 slots) slave
   replicates 5f9d9de492cc4019a0b231f40fed256b3ae1143e
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```


```bash
timych@timych-ubu-n1:~$ docker exec -it redis_master  redis-cli -h 192.168.171.101 -p 6373 -c
192.168.171.101:6373> set a 1
-> Redirected to slot [15495] located at 192.168.171.103:6373
OK
192.168.171.103:6373> set b 2
-> Redirected to slot [3300] located at 192.168.171.101:6373
OK
192.168.171.101:6373> set c 3
-> Redirected to slot [7365] located at 192.168.171.102:6373
OK
192.168.171.102:6373> set d 4
-> Redirected to slot [11298] located at 192.168.171.103:6373
OK
192.168.171.103:6373> set e 5
OK
192.168.171.103:6373> set f 6
-> Redirected to slot [3168] located at 192.168.171.101:6373
OK
192.168.171.101:6373> get a
-> Redirected to slot [15495] located at 192.168.171.103:6373
"1"
192.168.171.103:6373> get b
-> Redirected to slot [3300] located at 192.168.171.101:6373
"2"
192.168.171.101:6373> get c
-> Redirected to slot [7365] located at 192.168.171.102:6373
"3"
192.168.171.102:6373> get d
-> Redirected to slot [11298] located at 192.168.171.103:6373
"4"
192.168.171.103:6373> get e
"5"
192.168.171.103:6373> get f
-> Redirected to slot [3168] located at 192.168.171.101:6373
"6"
```



### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
