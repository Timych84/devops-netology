# Домашнее задание к занятию "2. Работа с Playbook"

1. Приготовьте свой собственный inventory файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

<details>
    <summary>ansible-lint</summary>

```bash
timych@timych-ubu2:~/clickhouse_n_vector/playbook$ ansible-lint site.yml
...
WARNING  Listing 1 violation(s) that are fatal
name[missing]: All tasks should be named.
site.yml:14 Task/Handler: block/always/rescue

You can skip specific rules or tags by adding them to your configuration file:
# .config/ansible-lint.yml
warn_list:  # or 'skip_list' to silence them completely
  - name[missing]  # Rule for checking task and play names.

              Rule Violation Summary
 count tag           profile rule associated tags
     1 name[missing] basic   idiom

Failed after min profile: 1 failure(s), 0 warning(s) on 1 files.
...
```
</details>

Добавил name: `- name: Install Clickhouse | Download clickhouse block` для блока скачивания дистрибутивов Clickhouse

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.


<details>
<summary>ansible-playbook -i inventory/prod.yml site.yml --check</summary>

```bash
timych@timych-ubu2:~/clickhouse_n_vector/playbook$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] **********************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install Clickhouse | Download clickhouse distrib] ****************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Install Clickhouse | Download clickhouse distrib] ****************************************************************************************************
changed: [clickhouse-01]

TASK [Install Clickhouse | Install clickhouse packages] ****************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system"]}
...ignoring

TASK [Install Clickhouse | Flush handlers] *****************************************************************************************************************

TASK [Install Clickhouse | Check if Clickhouse started] ****************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"msg": "The conditional check 'temp__service_facts.ansible_facts.services[\"clickhouse-server.service\"].state == 'running'' failed. The error was: error while evaluating conditional (temp__service_facts.ansible_facts.services[\"clickhouse-server.service\"].state == 'running'): 'dict object' has no attribute 'clickhouse-server.service'"}
...ignoring

TASK [Install Clickhouse | Create database] ****************************************************************************************************************
skipping: [clickhouse-01]

PLAY [Configure clickhouse] ********************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Configure clickhouse | Install epel] *****************************************************************************************************************
changed: [clickhouse-01]

TASK [Configure clickhouse | Install python-pip] ***********************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No package matching 'python-pip' found available, installed or updated", "rc": 126, "results": ["No package matching 'python-pip' found available, installed or updated"]}
...ignoring

TASK [Configure clickhouse | Install pip lxml] *************************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: ImportError: No module named pkg_resources
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "Failed to import the required Python library (setuptools) on centos7-node1's Python /usr/bin/python. Please read the module documentation and install it in the appropriate location. If the required library is installed, but Ansible is using the wrong Python interpreter, please consult the documentation on ansible_python_interpreter"}
...ignoring

TASK [Configure clickhouse | Create table for syslog] ******************************************************************************************************
skipping: [clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse server config] **********************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: ImportError: No module named lxml
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "Failed to import the required Python library (lxml) on centos7-node1's Python /usr/bin/python. Please read the module documentation and install it in the appropriate location. If the required library is installed, but Ansible is using the wrong Python interpreter, please consult the documentation on ansible_python_interpreter"}
...ignoring

TASK [Configure clickhouse | Modify clickhouse client config] **********************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: ImportError: No module named lxml
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "Failed to import the required Python library (lxml) on centos7-node1's Python /usr/bin/python. Please read the module documentation and install it in the appropriate location. If the required library is installed, but Ansible is using the wrong Python interpreter, please consult the documentation on ansible_python_interpreter"}
...ignoring

TASK [Configure clickhouse | Open clickhouse port on firewalld] ********************************************************************************************
changed: [clickhouse-01]

RUNNING HANDLER [Reload firewalld service] *****************************************************************************************************************
changed: [clickhouse-01]

PLAY [Install vector] **************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [vector-01]

TASK [Install vector | Download vector distrib] ************************************************************************************************************
changed: [vector-01]

TASK [Install vector | Install vector package] *************************************************************************************************************
fatal: [vector-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'vector-0.27.0.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'vector-0.27.0.rpm' found on system"]}
...ignoring

TASK [Install vector | Delete default vector config] *******************************************************************************************************
ok: [vector-01]

TASK [Install vector | Set default vector config file for service] *****************************************************************************************
changed: [vector-01]

TASK [Install vector | Vector config from template] ********************************************************************************************************
changed: [vector-01]

TASK [Install vector | Flush handlers] *********************************************************************************************************************

RUNNING HANDLER [Restart vector service] *******************************************************************************************************************
fatal: [vector-01]: FAILED! => {"changed": false, "msg": "Could not find the requested service vector: host"}

NO MORE HOSTS LEFT *****************************************************************************************************************************************

PLAY RECAP *************************************************************************************************************************************************
clickhouse-01              : ok=12   changed=4    unreachable=0    failed=0    skipped=2    rescued=1    ignored=6
vector-01                  : ok=6    changed=3    unreachable=0    failed=1    skipped=0    rescued=0    ignored=1
```

</details>

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.


<details>
<summary>ansible-playbook -i inventory/prod.yml site.yml --diff</summary>


```bash
timych@timych-ubu2:~/clickhouse_n_vector/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] **********************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install Clickhouse | Download clickhouse distrib] ****************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Install Clickhouse | Download clickhouse distrib] ****************************************************************************************************
changed: [clickhouse-01]

TASK [Install Clickhouse | Install clickhouse packages] ****************************************************************************************************
changed: [clickhouse-01]

TASK [Install Clickhouse | Flush handlers] *****************************************************************************************************************

RUNNING HANDLER [Start clickhouse service] *****************************************************************************************************************
changed: [clickhouse-01]

TASK [Install Clickhouse | Check if Clickhouse started] ****************************************************************************************************
ok: [clickhouse-01]

TASK [Install Clickhouse | Create database] ****************************************************************************************************************
changed: [clickhouse-01]

PLAY [Configure clickhouse] ********************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Configure clickhouse | Install epel] *****************************************************************************************************************
changed: [clickhouse-01]

TASK [Configure clickhouse | Install python-pip] ***********************************************************************************************************
changed: [clickhouse-01]

TASK [Configure clickhouse | Install pip lxml] *************************************************************************************************************
changed: [clickhouse-01]

TASK [Configure clickhouse | Create table for syslog] ******************************************************************************************************
changed: [clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse server config] **********************************************************************************************
--- before
+++ after
@@ -1294,4 +1294,4 @@
         </tables>
     </rocksdb>
     -->
-</clickhouse>
+<listen_host>0.0.0.0</listen_host></clickhouse>

changed: [clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse client config] **********************************************************************************************
--- before
+++ after
@@ -18,7 +18,7 @@
                  first_or_random - if first replica one has higher number of errors, pick a random one from replicas with minimum number of errors.
             -->
             <load_balancing>random</load_balancing>
-        </default>
+        <date_time_input_format>best_effort</date_time_input_format></default>

         <!-- Profile that allows only read queries. -->
         <readonly>

changed: [clickhouse-01]

TASK [Configure clickhouse | Open clickhouse port on firewalld] ********************************************************************************************
changed: [clickhouse-01]

RUNNING HANDLER [Restart clickhouse service] ***************************************************************************************************************
changed: [clickhouse-01]

RUNNING HANDLER [Reload firewalld service] *****************************************************************************************************************
changed: [clickhouse-01]

PLAY [Install vector] **************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [vector-01]

TASK [Install vector | Download vector distrib] ************************************************************************************************************
changed: [vector-01]

TASK [Install vector | Install vector package] *************************************************************************************************************
changed: [vector-01]

TASK [Install vector | Delete default vector config] *******************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/etc/vector/vector.toml",
-    "state": "file"
+    "state": "absent"
 }

changed: [vector-01]

TASK [Install vector | Set default vector config file for service] *****************************************************************************************
--- before: /etc/default/vector
+++ after: /home/timych/.ansible/tmp/ansible-local-44264f6n6zhjs/tmp_9bg_98y/vector.j2
@@ -1,4 +1 @@
-# /etc/default/vector
-# This file can theoretically contain a bunch of environment variables
-# for Vector.  See https://vector.dev/docs/setup/configuration/#environment-variables
-# for details.
+VECTOR_CONFIG=/etc/vector/vector.yml

changed: [vector-01]

TASK [Install vector | Vector config from template] ********************************************************************************************************
--- before
+++ after: /home/timych/.ansible/tmp/ansible-local-44264f6n6zhjs/tmpav7nzyk0/vector.yml.j2
@@ -0,0 +1,24 @@
+sinks:
+    clickhouse_syslog:
+        database: logs
+        endpoint: http://192.168.171.221:8123
+        inputs:
+        - journald_src
+        skip_unknown_fields: true
+        table: syslogd
+        type: clickhouse
+    test_console:
+        encoding:
+            codec: json
+        inputs:
+        - dummy_logs
+        type: console
+sources:
+    dummy_logs:
+        format: syslog
+        interval: 5
+        type: demo_logs
+    journald_src:
+        current_boot_only: true
+        since_now: false
+        type: journald

changed: [vector-01]

TASK [Install vector | Flush handlers] *********************************************************************************************************************

RUNNING HANDLER [Restart vector service] *******************************************************************************************************************
changed: [vector-01]

TASK [Install vector | Check if vector started] ************************************************************************************************************
ok: [vector-01]

PLAY RECAP *************************************************************************************************************************************************
clickhouse-01              : ok=16   changed=13   unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
vector-01                  : ok=8    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
</details>




8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

<details>
<summary>ansible-playbook -i inventory/prod.yml site.yml --diff</summary>

```bash
timych@timych-ubu2:~/clickhouse_n_vector/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] **********************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install Clickhouse | Download clickhouse distrib] ****************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1001, "group": "timych", "item": "clickhouse-common-static", "mode": "0440", "msg": "Request failed", "owner": "timych", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1001, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Install Clickhouse | Download clickhouse distrib] ****************************************************************************************************
ok: [clickhouse-01]

TASK [Install Clickhouse | Install clickhouse packages] ****************************************************************************************************
ok: [clickhouse-01]

TASK [Install Clickhouse | Flush handlers] *****************************************************************************************************************

TASK [Install Clickhouse | Check if Clickhouse started] ****************************************************************************************************
ok: [clickhouse-01]

TASK [Install Clickhouse | Create database] ****************************************************************************************************************
ok: [clickhouse-01]

PLAY [Configure clickhouse] ********************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Configure clickhouse | Install epel] *****************************************************************************************************************
ok: [clickhouse-01]

TASK [Configure clickhouse | Install python-pip] ***********************************************************************************************************
ok: [clickhouse-01]

TASK [Configure clickhouse | Install pip lxml] *************************************************************************************************************
ok: [clickhouse-01]

TASK [Configure clickhouse | Create table for syslog] ******************************************************************************************************
ok: [clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse server config] **********************************************************************************************
ok: [clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse client config] **********************************************************************************************
ok: [clickhouse-01]

TASK [Configure clickhouse | Open clickhouse port on firewalld] ********************************************************************************************
ok: [clickhouse-01]

PLAY [Install vector] **************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [vector-01]

TASK [Install vector | Download vector distrib] ************************************************************************************************************
ok: [vector-01]

TASK [Install vector | Install vector package] *************************************************************************************************************
ok: [vector-01]

TASK [Install vector | Delete default vector config] *******************************************************************************************************
ok: [vector-01]

TASK [Install vector | Set default vector config file for service] *****************************************************************************************
ok: [vector-01]

TASK [Install vector | Vector config from template] ********************************************************************************************************
ok: [vector-01]

TASK [Install vector | Flush handlers] *********************************************************************************************************************

TASK [Install vector | Check if vector started] ************************************************************************************************************
ok: [vector-01]

PLAY RECAP *************************************************************************************************************************************************
clickhouse-01              : ok=13   changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
vector-01                  : ok=7    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
</details>

9.  Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10.  Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.



---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
