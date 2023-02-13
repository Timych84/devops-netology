# Домашнее задание к занятию "1. Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

```
timych@timych-ubu2:~/ansible_netology/playbook$ ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] *****************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************
ok: [localhost]

TASK [Print OS] ***********************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *********************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP ****************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.


```bash
sed -i 's/.*some_fact: 12/some_fact: all default fact/g' group_vars/all/examp.yml
```

3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.


```bash
timych@timych-ubu2:~/ansible_netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml

...
TASK [Print fact] *********************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

...
```

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.



```bash
sed -i 's/.*some_fact: "deb"/some_fact: "deb default fact"/g' group_vars/deb/examp.yml
sed -i 's/.*some_fact: "el"/some_fact: "el default fact"/g' group_vars/el/examp.yml

```
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
```bash
timych@timych-ubu2:~/ansible_netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml

...
TASK [Print fact] *********************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
...

```

7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.


```bash
timych@timych-ubu2:~/ansible_netology/playbook$ ansible-vault encrypt group_vars/deb/examp.yml group_vars/el/examp.yml
```

8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.


```bash
timych@timych-ubu2:~/ansible_netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password:

...
TASK [Print fact] *********************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
...
```

9.  Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

ansible-doc -t connection -l
вероятно подходит ansible_connection: local

10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

```bash
timych@timych-ubu2:~/ansible_netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password:

...
TASK [Print fact] *********************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "local default fact"
}
...
```


12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.


```bash
imych@timych-ubu2:~/ansible_netology/playbook$ ansible-vault decrypt group_vars/*/*.yml
Vault password:
Decryption successful
```

2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.


```bash
timych@timych-ubu2:~/ansible_netology/playbook$ ansible-vault  encrypt_string
New Vault password:
Confirm New Vault password:
Reading plaintext input from stdin. (ctrl-d to end input, twice if your content does not already have a newline)
PaSSw0rd
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          30366664313939363531666431376339313131633537353161636635383263343261333934353239
          6564343033633763326333336466346338613863373230340a363239666439303431356562363964
          39633535626165663030303537346234353861613031346363633162636239306631626630663866
          3830353364363638640a303962616263346636393438653133333937343131313739316464656538
          3161
```


3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.

```bash
timych@timych-ubu2:~/ansible_netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password:

...
TASK [Print fact] *********************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
...
```

4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.

Dockerfile для Ubuntu(установка python в образ):

```dockerfile
FROM ubuntu:20.04
RUN apt-get update && \
apt-get install -y python3 && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*
CMD ["/bin/bash"]
```


docker-compose.yaml
```yaml
version: "3"
services:
  centos7:
    image: centos:7
    container_name: centos7
    stdin_open: true
    tty: true
  ubuntu:
    build: ./ubuntu
    container_name: ubuntu
    stdin_open: true
    tty: true
  fedora:
    image: fedora:38
    container_name: fedora
    stdin_open: true
    tty: true
```

Скрипт создания контейнеров, выполнения плейбука и удаления контейнеров после выполнения

```bash
#/bin/bash
docker compose up -d
ansible-playbook -i inventory/prod.yml site.yml --vault-password-file ./.vault_pass.txt
docker compose down
```

6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
