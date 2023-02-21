
## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.
4. Приготовьте свой собственный inventory файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

<details>
    <summary>ansible-lint</summary>

```bash
timych@timych-ubu2:~/clickhouse_vector_lighthouse/playbook$ ansible-lint site.yml
WARNING: ansible-lint is no longer tested under Python 3.8 and will soon require 3.9. Do not report bugs for this version.
WARNING  Ignore loading rule from /home/timych/.local/lib/python3.8/site-packages/ansiblelint/rules/role_name.py due to cannot import name 'cache' from 'functools' (/usr/lib/python3.8/functools.py)

Passed with production profile: 0 failure(s), 0 warning(s) on 1 files.
A new release of ansible-lint is available: 6.12.2 → 6.13.1
```

</details>

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
<details>
<summary>ansible-playbook -i inventory/prod.yml site.yml --check</summary>

```bash
timych@timych-ubu2:~/clickhouse_vector_lighthouse/playbook$ ansible-playbook -i inventory/prod_tf.yml site.yml --check

PLAY [Install Clickhouse] *******************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Download clickhouse distrib] *************************************************************************************************************
changed: [prod-server-clickhouse-01] => (item=clickhouse-client)
changed: [prod-server-clickhouse-01] => (item=clickhouse-server)
failed: [prod-server-clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Install Clickhouse | Download clickhouse distrib] *************************************************************************************************************
changed: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Install clickhouse packages] *************************************************************************************************************
fatal: [prod-server-clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system"]}
...ignoring

TASK [Install Clickhouse | Flush handlers] **************************************************************************************************************************

TASK [Install Clickhouse | Check if Clickhouse started] *************************************************************************************************************
fatal: [prod-server-clickhouse-01]: FAILED! => {"msg": "The conditional check 'temp__service_facts.ansible_facts.services[\"clickhouse-server.service\"].state == 'running'' failed. The error was: error while evaluating conditional (temp__service_facts.ansible_facts.services[\"clickhouse-server.service\"].state == 'running'): 'dict object' has no attribute 'clickhouse-server.service'"}
...ignoring

TASK [Install Clickhouse | Create database] *************************************************************************************************************************
skipping: [prod-server-clickhouse-01]

PLAY [Configure Сlickhouse] *****************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Install epel] **************************************************************************************************************************
changed: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Install python-pip and firewalld] ******************************************************************************************************
fatal: [prod-server-clickhouse-01]: FAILED! => {"changed": false, "msg": "No package matching 'python-pip' found available, installed or updated", "rc": 126, "results": ["No package matching 'python-pip' found available, installed or updated"]}
...ignoring

TASK [Configure clickhouse | Install pip lxml] **********************************************************************************************************************
fatal: [prod-server-clickhouse-01]: FAILED! => {"changed": false, "msg": "Unable to find any of pip2, pip to use.  pip needs to be installed."}
...ignoring

TASK [Configure clickhouse | Create table for syslog] ***************************************************************************************************************
skipping: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse server config] *******************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: ImportError: No module named lxml
fatal: [prod-server-clickhouse-01]: FAILED! => {"changed": false, "msg": "Failed to import the required Python library (lxml) on prod-server-clickhouse-01.ru-central1.internal's Python /usr/bin/python. Please read the module documentation and install it in the appropriate location. If the required library is installed, but Ansible is using the wrong Python interpreter, please consult the documentation on ansible_python_interpreter"}
...ignoring

TASK [Configure clickhouse | Modify clickhouse client config] *******************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: ImportError: No module named lxml
fatal: [prod-server-clickhouse-01]: FAILED! => {"changed": false, "msg": "Failed to import the required Python library (lxml) on prod-server-clickhouse-01.ru-central1.internal's Python /usr/bin/python. Please read the module documentation and install it in the appropriate location. If the required library is installed, but Ansible is using the wrong Python interpreter, please consult the documentation on ansible_python_interpreter"}
...ignoring

TASK [Configure clickhouse | Open clickhouse port on firewalld] *****************************************************************************************************
fatal: [prod-server-clickhouse-01]: FAILED! => {"changed": false, "msg": "Python Module not found: firewalld and its python module are required for this module,                         version 0.2.11 or newer required (0.3.9 or newer for offline operations)"}
...ignoring

PLAY [Install Vector] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-vector-01]

TASK [Install vector | Download vector distrib] *********************************************************************************************************************
changed: [prod-server-vector-01]

TASK [Install vector | Install vector package] **********************************************************************************************************************
fatal: [prod-server-vector-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'vector-0.27.0.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'vector-0.27.0.rpm' found on system"]}
...ignoring

TASK [Install vector | Delete default vector config] ****************************************************************************************************************
ok: [prod-server-vector-01]

TASK [Install vector | Set default vector config file for service] **************************************************************************************************
changed: [prod-server-vector-01]

TASK [Install vector | Vector config from template] *****************************************************************************************************************
changed: [prod-server-vector-01]

TASK [Install vector | Flush handlers] ******************************************************************************************************************************

RUNNING HANDLER [Restart vector service] ****************************************************************************************************************************
fatal: [prod-server-vector-01]: FAILED! => {"changed": false, "msg": "Could not find the requested service vector: host"}
...ignoring

TASK [Install vector | Check if vector started] *********************************************************************************************************************
fatal: [prod-server-vector-01]: FAILED! => {"msg": "The conditional check 'temp__service_facts.ansible_facts.services[\"vector.service\"].state == 'running'' failed. The error was: error while evaluating conditional (temp__service_facts.ansible_facts.services[\"vector.service\"].state == 'running'): 'dict object' has no attribute 'vector.service'"}
...ignoring

PLAY [Install lighthouse] *******************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Install lighthouse | Install epel repo] ***********************************************************************************************************************
changed: [prod-server-lighthouse-01]

TASK [Install lighthouse | Install nginx, git and firewalld] ********************************************************************************************************
fatal: [prod-server-lighthouse-01]: FAILED! => {"changed": false, "msg": "No package matching 'nginx' found available, installed or updated", "rc": 126, "results": ["No package matching 'nginx' found available, installed or updated"]}
...ignoring

TASK [Install lighthouse | Flush handlers] **************************************************************************************************************************

TASK [Install lighthouse | Clone a lighthouse repo] *****************************************************************************************************************
fatal: [prod-server-lighthouse-01]: FAILED! => {"changed": false, "msg": "Failed to find required executable \"git\" in paths: /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin"}
...ignoring

TASK [Synchronize two directories on one remote host.] **************************************************************************************************************
fatal: [prod-server-lighthouse-01]: FAILED! => {"changed": false, "cmd": "/bin/rsync --delay-updates -F --compress --dry-run --archive --no-perms --exclude=.git --chown=nginx:nginx --chmod=D750,F640 --out-format='<<CHANGED>>%i %n%L' /var/www/html/lighthouse_repo/ /var/www/html/lighthouse", "msg": "rsync: change_dir \"/var/www/html/lighthouse_repo\" failed: No such file or directory (2)\nUnknown --usermap name on receiver: nginx\nUnknown --groupmap name on receiver: nginx\nrsync: change_dir#3 \"/var/www/html\" failed: No such file or directory (2)\nrsync error: errors selecting input/output files, dirs (code 3) at main.c(694) [Receiver=3.1.2]\n", "rc": 3}
...ignoring

TASK [Install lighthouse | Configure SELinux for nginx] *************************************************************************************************************
skipping: [prod-server-lighthouse-01]

TASK [Install lighthouse | Open http/s port on firewalld] ***********************************************************************************************************
failed: [prod-server-lighthouse-01] (item=http) => {"ansible_loop_var": "item", "changed": false, "item": "http", "msg": "Python Module not found: firewalld and its python module are required for this module,                         version 0.2.11 or newer required (0.3.9 or newer for offline operations)"}
failed: [prod-server-lighthouse-01] (item=https) => {"ansible_loop_var": "item", "changed": false, "item": "https", "msg": "Python Module not found: firewalld and its python module are required for this module,                         version 0.2.11 or newer required (0.3.9 or newer for offline operations)"}
...ignoring

TASK [Install lighthouse | Rewrite nginx main config file] **********************************************************************************************************
changed: [prod-server-lighthouse-01]

TASK [Install lighthouse | Rewrite nginx lighthouse config file] ****************************************************************************************************
changed: [prod-server-lighthouse-01]

RUNNING HANDLER [Reload nginx service] ******************************************************************************************************************************
fatal: [prod-server-lighthouse-01]: FAILED! => {"changed": false, "msg": "Could not find the requested service nginx: host"}
...ignoring

PLAY RECAP **********************************************************************************************************************************************************
prod-server-clickhouse-01  : ok=11   changed=2    unreachable=0    failed=0    skipped=2    rescued=1    ignored=7
prod-server-lighthouse-01  : ok=9    changed=3    unreachable=0    failed=0    skipped=1    rescued=0    ignored=5
prod-server-vector-01      : ok=8    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=3
```

</details>

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.


<details>
<summary>ansible-playbook -i inventory/prod.yml site.yml --diff</summary>

```bash
timych@timych-ubu2:~/clickhouse_vector_lighthouse/playbook$ ansible-playbook -i inventory/prod_tf.yml site.yml --diff

PLAY [Install Clickhouse] *******************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Download clickhouse distrib] *************************************************************************************************************
changed: [prod-server-clickhouse-01] => (item=clickhouse-client)
changed: [prod-server-clickhouse-01] => (item=clickhouse-server)
failed: [prod-server-clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Install Clickhouse | Download clickhouse distrib] *************************************************************************************************************
changed: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Install clickhouse packages] *************************************************************************************************************
changed: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Flush handlers] **************************************************************************************************************************

RUNNING HANDLER [Start clickhouse service] **************************************************************************************************************************
changed: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Check if Clickhouse started] *************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Create database] *************************************************************************************************************************
changed: [prod-server-clickhouse-01]

PLAY [Configure Сlickhouse] *****************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Install epel] **************************************************************************************************************************
changed: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Install python-pip and firewalld] ******************************************************************************************************
changed: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Install pip lxml] **********************************************************************************************************************
changed: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Create table for syslog] ***************************************************************************************************************
changed: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse server config] *******************************************************************************************************
--- before
+++ after
@@ -1294,4 +1294,4 @@
         </tables>
     </rocksdb>
     -->
-</clickhouse>
+<listen_host>0.0.0.0</listen_host></clickhouse>

changed: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse client config] *******************************************************************************************************
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

changed: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Open clickhouse port on firewalld] *****************************************************************************************************
changed: [prod-server-clickhouse-01]

RUNNING HANDLER [Restart clickhouse service] ************************************************************************************************************************
changed: [prod-server-clickhouse-01]

RUNNING HANDLER [Restart firewalld service] *************************************************************************************************************************
changed: [prod-server-clickhouse-01]

RUNNING HANDLER [Reload firewalld service] **************************************************************************************************************************
changed: [prod-server-clickhouse-01]

PLAY [Install Vector] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-vector-01]

TASK [Install vector | Download vector distrib] *********************************************************************************************************************
changed: [prod-server-vector-01]

TASK [Install vector | Install vector package] **********************************************************************************************************************
changed: [prod-server-vector-01]

TASK [Install vector | Delete default vector config] ****************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/etc/vector/vector.toml",
-    "state": "file"
+    "state": "absent"
 }

changed: [prod-server-vector-01]

TASK [Install vector | Set default vector config file for service] **************************************************************************************************
--- before: /etc/default/vector
+++ after: /home/timych/.ansible/tmp/ansible-local-123629r3o_ztsj/tmpbefrpa7o/vector.j2
@@ -1,4 +1 @@
-# /etc/default/vector
-# This file can theoretically contain a bunch of environment variables
-# for Vector.  See https://vector.dev/docs/setup/configuration/#environment-variables
-# for details.
+VECTOR_CONFIG=/etc/vector/vector.yml

changed: [prod-server-vector-01]

TASK [Install vector | Vector config from template] *****************************************************************************************************************
--- before
+++ after: /home/timych/.ansible/tmp/ansible-local-123629r3o_ztsj/tmpsyq9y_zi/vector.yml.j2
@@ -0,0 +1,24 @@
+sinks:
+    clickhouse_syslog:
+        database: logs
+        endpoint: http://192.168.101.9:8123
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

changed: [prod-server-vector-01]

TASK [Install vector | Flush handlers] ******************************************************************************************************************************

RUNNING HANDLER [Restart vector service] ****************************************************************************************************************************
changed: [prod-server-vector-01]

TASK [Install vector | Check if vector started] *********************************************************************************************************************
ok: [prod-server-vector-01]

PLAY [Install lighthouse] *******************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Install lighthouse | Install epel repo] ***********************************************************************************************************************
changed: [prod-server-lighthouse-01]

TASK [Install lighthouse | Install nginx, git and firewalld] ********************************************************************************************************
changed: [prod-server-lighthouse-01]

TASK [Install lighthouse | Flush handlers] **************************************************************************************************************************

RUNNING HANDLER [Restart nginx service] *****************************************************************************************************************************
changed: [prod-server-lighthouse-01]

RUNNING HANDLER [Restart firewalld service] *************************************************************************************************************************
changed: [prod-server-lighthouse-01]

TASK [Install lighthouse | Clone a lighthouse repo] *****************************************************************************************************************
>> Newly checked out d701335c25cd1bb9b5155711190bad8ab852c2ce
changed: [prod-server-lighthouse-01]

TASK [Synchronize two directories on one remote host.] **************************************************************************************************************
cd+++++++++ ./
>f+++++++++ LICENSE
>f+++++++++ README.md
>f+++++++++ app.js
>f+++++++++ index.html
>f+++++++++ jquery.js
cd+++++++++ css/
>f+++++++++ css/bootstrap-responsive.css
>f+++++++++ css/bootstrap-responsive.min.css
>f+++++++++ css/bootstrap.css
>f+++++++++ css/bootstrap.min.css
cd+++++++++ img/
>f+++++++++ img/glyphicons-halflings-white.png
>f+++++++++ img/glyphicons-halflings.png
>f+++++++++ img/loading.svg
cd+++++++++ js/
>f+++++++++ js/ag-grid.min.js
>f+++++++++ js/bootstrap.js
>f+++++++++ js/bootstrap.min.js
cd+++++++++ js/ace-min/
>f+++++++++ js/ace-min/ace.js
>f+++++++++ js/ace-min/ch_completions_help.js
>f+++++++++ js/ace-min/clickhouse_highlight_rules.js
>f+++++++++ js/ace-min/ext-beautify.js
>f+++++++++ js/ace-min/ext-elastic_tabstops_lite.js
>f+++++++++ js/ace-min/ext-emmet.js
>f+++++++++ js/ace-min/ext-error_marker.js
>f+++++++++ js/ace-min/ext-keybinding_menu.js
>f+++++++++ js/ace-min/ext-language_tools.js
>f+++++++++ js/ace-min/ext-linking.js
>f+++++++++ js/ace-min/ext-modelist.js
>f+++++++++ js/ace-min/ext-options.js
>f+++++++++ js/ace-min/ext-searchbox.js
>f+++++++++ js/ace-min/ext-settings_menu.js
>f+++++++++ js/ace-min/ext-spellcheck.js
>f+++++++++ js/ace-min/ext-split.js
>f+++++++++ js/ace-min/ext-static_highlight.js
>f+++++++++ js/ace-min/ext-statusbar.js
>f+++++++++ js/ace-min/ext-textarea.js
>f+++++++++ js/ace-min/ext-themelist.js
>f+++++++++ js/ace-min/ext-whitespace.js
>f+++++++++ js/ace-min/keybinding-emacs.js
>f+++++++++ js/ace-min/keybinding-vim.js
>f+++++++++ js/ace-min/mode-abap.js
>f+++++++++ js/ace-min/mode-abc.js
>f+++++++++ js/ace-min/mode-actionscript.js
>f+++++++++ js/ace-min/mode-ada.js
>f+++++++++ js/ace-min/mode-apache_conf.js
>f+++++++++ js/ace-min/mode-applescript.js
>f+++++++++ js/ace-min/mode-asciidoc.js
>f+++++++++ js/ace-min/mode-assembly_x86.js
>f+++++++++ js/ace-min/mode-autohotkey.js
>f+++++++++ js/ace-min/mode-batchfile.js
>f+++++++++ js/ace-min/mode-bro.js
>f+++++++++ js/ace-min/mode-c9search.js
>f+++++++++ js/ace-min/mode-c_cpp.js
>f+++++++++ js/ace-min/mode-cirru.js
>f+++++++++ js/ace-min/mode-clickhouse.js
>f+++++++++ js/ace-min/mode-clojure.js
>f+++++++++ js/ace-min/mode-cobol.js
>f+++++++++ js/ace-min/mode-coffee.js
>f+++++++++ js/ace-min/mode-coldfusion.js
>f+++++++++ js/ace-min/mode-csharp.js
>f+++++++++ js/ace-min/mode-csound_document.js
>f+++++++++ js/ace-min/mode-csound_orchestra.js
>f+++++++++ js/ace-min/mode-csound_score.js
>f+++++++++ js/ace-min/mode-csp.js
>f+++++++++ js/ace-min/mode-css.js
>f+++++++++ js/ace-min/mode-curly.js
>f+++++++++ js/ace-min/mode-d.js
>f+++++++++ js/ace-min/mode-dart.js
>f+++++++++ js/ace-min/mode-diff.js
>f+++++++++ js/ace-min/mode-django.js
>f+++++++++ js/ace-min/mode-dockerfile.js
>f+++++++++ js/ace-min/mode-dot.js
>f+++++++++ js/ace-min/mode-drools.js
>f+++++++++ js/ace-min/mode-edifact.js
>f+++++++++ js/ace-min/mode-eiffel.js
>f+++++++++ js/ace-min/mode-ejs.js
>f+++++++++ js/ace-min/mode-elixir.js
>f+++++++++ js/ace-min/mode-elm.js
>f+++++++++ js/ace-min/mode-erlang.js
>f+++++++++ js/ace-min/mode-forth.js
>f+++++++++ js/ace-min/mode-fortran.js
>f+++++++++ js/ace-min/mode-ftl.js
>f+++++++++ js/ace-min/mode-gcode.js
>f+++++++++ js/ace-min/mode-gherkin.js
>f+++++++++ js/ace-min/mode-gitignore.js
>f+++++++++ js/ace-min/mode-glsl.js
>f+++++++++ js/ace-min/mode-gobstones.js
>f+++++++++ js/ace-min/mode-golang.js
>f+++++++++ js/ace-min/mode-graphqlschema.js
>f+++++++++ js/ace-min/mode-groovy.js
>f+++++++++ js/ace-min/mode-haml.js
>f+++++++++ js/ace-min/mode-handlebars.js
>f+++++++++ js/ace-min/mode-haskell.js
>f+++++++++ js/ace-min/mode-haskell_cabal.js
>f+++++++++ js/ace-min/mode-haxe.js
>f+++++++++ js/ace-min/mode-hjson.js
>f+++++++++ js/ace-min/mode-html.js
>f+++++++++ js/ace-min/mode-html_elixir.js
>f+++++++++ js/ace-min/mode-html_ruby.js
>f+++++++++ js/ace-min/mode-ini.js
>f+++++++++ js/ace-min/mode-io.js
>f+++++++++ js/ace-min/mode-jack.js
>f+++++++++ js/ace-min/mode-jade.js
>f+++++++++ js/ace-min/mode-java.js
>f+++++++++ js/ace-min/mode-javascript.js
>f+++++++++ js/ace-min/mode-json.js
>f+++++++++ js/ace-min/mode-jsoniq.js
>f+++++++++ js/ace-min/mode-jsp.js
>f+++++++++ js/ace-min/mode-jssm.js
>f+++++++++ js/ace-min/mode-jsx.js
>f+++++++++ js/ace-min/mode-julia.js
>f+++++++++ js/ace-min/mode-kotlin.js
>f+++++++++ js/ace-min/mode-latex.js
>f+++++++++ js/ace-min/mode-less.js
>f+++++++++ js/ace-min/mode-liquid.js
>f+++++++++ js/ace-min/mode-lisp.js
>f+++++++++ js/ace-min/mode-livescript.js
>f+++++++++ js/ace-min/mode-logiql.js
>f+++++++++ js/ace-min/mode-lsl.js
>f+++++++++ js/ace-min/mode-lua.js
>f+++++++++ js/ace-min/mode-luapage.js
>f+++++++++ js/ace-min/mode-lucene.js
>f+++++++++ js/ace-min/mode-makefile.js
>f+++++++++ js/ace-min/mode-markdown.js
>f+++++++++ js/ace-min/mode-mask.js
>f+++++++++ js/ace-min/mode-matlab.js
>f+++++++++ js/ace-min/mode-maze.js
>f+++++++++ js/ace-min/mode-mel.js
>f+++++++++ js/ace-min/mode-mixal.js
>f+++++++++ js/ace-min/mode-mushcode.js
>f+++++++++ js/ace-min/mode-mysql.js
>f+++++++++ js/ace-min/mode-nix.js
>f+++++++++ js/ace-min/mode-nsis.js
>f+++++++++ js/ace-min/mode-objectivec.js
>f+++++++++ js/ace-min/mode-ocaml.js
>f+++++++++ js/ace-min/mode-pascal.js
>f+++++++++ js/ace-min/mode-perl.js
>f+++++++++ js/ace-min/mode-pgsql.js
>f+++++++++ js/ace-min/mode-php.js
>f+++++++++ js/ace-min/mode-pig.js
>f+++++++++ js/ace-min/mode-plain_text.js
>f+++++++++ js/ace-min/mode-powershell.js
>f+++++++++ js/ace-min/mode-praat.js
>f+++++++++ js/ace-min/mode-prolog.js
>f+++++++++ js/ace-min/mode-properties.js
>f+++++++++ js/ace-min/mode-protobuf.js
>f+++++++++ js/ace-min/mode-python.js
>f+++++++++ js/ace-min/mode-r.js
>f+++++++++ js/ace-min/mode-razor.js
>f+++++++++ js/ace-min/mode-rdoc.js
>f+++++++++ js/ace-min/mode-red.js
>f+++++++++ js/ace-min/mode-redshift.js
>f+++++++++ js/ace-min/mode-rhtml.js
>f+++++++++ js/ace-min/mode-rst.js
>f+++++++++ js/ace-min/mode-ruby.js
>f+++++++++ js/ace-min/mode-rust.js
>f+++++++++ js/ace-min/mode-sass.js
>f+++++++++ js/ace-min/mode-scad.js
>f+++++++++ js/ace-min/mode-scala.js
>f+++++++++ js/ace-min/mode-scheme.js
>f+++++++++ js/ace-min/mode-scss.js
>f+++++++++ js/ace-min/mode-sh.js
>f+++++++++ js/ace-min/mode-sjs.js
>f+++++++++ js/ace-min/mode-smarty.js
>f+++++++++ js/ace-min/mode-snippets.js
>f+++++++++ js/ace-min/mode-soy_template.js
>f+++++++++ js/ace-min/mode-space.js
>f+++++++++ js/ace-min/mode-sparql.js
>f+++++++++ js/ace-min/mode-sql.js
>f+++++++++ js/ace-min/mode-sqlserver.js
>f+++++++++ js/ace-min/mode-stylus.js
>f+++++++++ js/ace-min/mode-svg.js
>f+++++++++ js/ace-min/mode-swift.js
>f+++++++++ js/ace-min/mode-tcl.js
>f+++++++++ js/ace-min/mode-tex.js
>f+++++++++ js/ace-min/mode-text.js
>f+++++++++ js/ace-min/mode-textile.js
>f+++++++++ js/ace-min/mode-toml.js
>f+++++++++ js/ace-min/mode-tsx.js
>f+++++++++ js/ace-min/mode-turtle.js
>f+++++++++ js/ace-min/mode-twig.js
>f+++++++++ js/ace-min/mode-typescript.js
>f+++++++++ js/ace-min/mode-vala.js
>f+++++++++ js/ace-min/mode-vbscript.js
>f+++++++++ js/ace-min/mode-velocity.js
>f+++++++++ js/ace-min/mode-verilog.js
>f+++++++++ js/ace-min/mode-vhdl.js
>f+++++++++ js/ace-min/mode-wollok.js
>f+++++++++ js/ace-min/mode-xml.js
>f+++++++++ js/ace-min/mode-xquery.js
>f+++++++++ js/ace-min/mode-yaml.js
>f+++++++++ js/ace-min/theme-ambiance.js
>f+++++++++ js/ace-min/theme-chaos.js
>f+++++++++ js/ace-min/theme-chrome.js
>f+++++++++ js/ace-min/theme-clouds.js
>f+++++++++ js/ace-min/theme-clouds_midnight.js
>f+++++++++ js/ace-min/theme-cobalt.js
>f+++++++++ js/ace-min/theme-crimson_editor.js
>f+++++++++ js/ace-min/theme-dawn.js
>f+++++++++ js/ace-min/theme-dracula.js
>f+++++++++ js/ace-min/theme-dreamweaver.js
>f+++++++++ js/ace-min/theme-eclipse.js
>f+++++++++ js/ace-min/theme-github.js
>f+++++++++ js/ace-min/theme-gob.js
>f+++++++++ js/ace-min/theme-gruvbox.js
>f+++++++++ js/ace-min/theme-idle_fingers.js
>f+++++++++ js/ace-min/theme-iplastic.js
>f+++++++++ js/ace-min/theme-katzenmilch.js
>f+++++++++ js/ace-min/theme-kr_theme.js
>f+++++++++ js/ace-min/theme-kuroir.js
>f+++++++++ js/ace-min/theme-merbivore.js
>f+++++++++ js/ace-min/theme-merbivore_soft.js
>f+++++++++ js/ace-min/theme-mono_industrial.js
>f+++++++++ js/ace-min/theme-monokai.js
>f+++++++++ js/ace-min/theme-pastel_on_dark.js
>f+++++++++ js/ace-min/theme-solarized_dark.js
>f+++++++++ js/ace-min/theme-solarized_light.js
>f+++++++++ js/ace-min/theme-sqlserver.js
>f+++++++++ js/ace-min/theme-terminal.js
>f+++++++++ js/ace-min/theme-textmate.js
>f+++++++++ js/ace-min/theme-tomorrow.js
>f+++++++++ js/ace-min/theme-tomorrow_night.js
>f+++++++++ js/ace-min/theme-tomorrow_night_blue.js
>f+++++++++ js/ace-min/theme-tomorrow_night_bright.js
>f+++++++++ js/ace-min/theme-tomorrow_night_eighties.js
>f+++++++++ js/ace-min/theme-twilight.js
>f+++++++++ js/ace-min/theme-vibrant_ink.js
>f+++++++++ js/ace-min/theme-xcode.js
>f+++++++++ js/ace-min/worker-coffee.js
>f+++++++++ js/ace-min/worker-css.js
>f+++++++++ js/ace-min/worker-html.js
>f+++++++++ js/ace-min/worker-javascript.js
>f+++++++++ js/ace-min/worker-json.js
>f+++++++++ js/ace-min/worker-lua.js
>f+++++++++ js/ace-min/worker-php.js
>f+++++++++ js/ace-min/worker-xml.js
>f+++++++++ js/ace-min/worker-xquery.js
cd+++++++++ js/ace-min/snippets/
>f+++++++++ js/ace-min/snippets/abap.js
>f+++++++++ js/ace-min/snippets/abc.js
>f+++++++++ js/ace-min/snippets/actionscript.js
>f+++++++++ js/ace-min/snippets/ada.js
>f+++++++++ js/ace-min/snippets/apache_conf.js
>f+++++++++ js/ace-min/snippets/applescript.js
>f+++++++++ js/ace-min/snippets/asciidoc.js
>f+++++++++ js/ace-min/snippets/assembly_x86.js
>f+++++++++ js/ace-min/snippets/autohotkey.js
>f+++++++++ js/ace-min/snippets/batchfile.js
>f+++++++++ js/ace-min/snippets/bro.js
>f+++++++++ js/ace-min/snippets/c9search.js
>f+++++++++ js/ace-min/snippets/c_cpp.js
>f+++++++++ js/ace-min/snippets/cirru.js
>f+++++++++ js/ace-min/snippets/clickhouse.js
>f+++++++++ js/ace-min/snippets/clojure.js
>f+++++++++ js/ace-min/snippets/cobol.js
>f+++++++++ js/ace-min/snippets/coffee.js
>f+++++++++ js/ace-min/snippets/coldfusion.js
>f+++++++++ js/ace-min/snippets/csharp.js
>f+++++++++ js/ace-min/snippets/csound_document.js
>f+++++++++ js/ace-min/snippets/csound_orchestra.js
>f+++++++++ js/ace-min/snippets/csound_score.js
>f+++++++++ js/ace-min/snippets/csp.js
>f+++++++++ js/ace-min/snippets/css.js
>f+++++++++ js/ace-min/snippets/curly.js
>f+++++++++ js/ace-min/snippets/d.js
>f+++++++++ js/ace-min/snippets/dart.js
>f+++++++++ js/ace-min/snippets/diff.js
>f+++++++++ js/ace-min/snippets/django.js
>f+++++++++ js/ace-min/snippets/dockerfile.js
>f+++++++++ js/ace-min/snippets/dot.js
>f+++++++++ js/ace-min/snippets/drools.js
>f+++++++++ js/ace-min/snippets/edifact.js
>f+++++++++ js/ace-min/snippets/eiffel.js
>f+++++++++ js/ace-min/snippets/ejs.js
>f+++++++++ js/ace-min/snippets/elixir.js
>f+++++++++ js/ace-min/snippets/elm.js
>f+++++++++ js/ace-min/snippets/erlang.js
>f+++++++++ js/ace-min/snippets/forth.js
>f+++++++++ js/ace-min/snippets/fortran.js
>f+++++++++ js/ace-min/snippets/ftl.js
>f+++++++++ js/ace-min/snippets/gcode.js
>f+++++++++ js/ace-min/snippets/gherkin.js
>f+++++++++ js/ace-min/snippets/gitignore.js
>f+++++++++ js/ace-min/snippets/glsl.js
>f+++++++++ js/ace-min/snippets/gobstones.js
>f+++++++++ js/ace-min/snippets/golang.js
>f+++++++++ js/ace-min/snippets/graphqlschema.js
>f+++++++++ js/ace-min/snippets/groovy.js
>f+++++++++ js/ace-min/snippets/haml.js
>f+++++++++ js/ace-min/snippets/handlebars.js
>f+++++++++ js/ace-min/snippets/haskell.js
>f+++++++++ js/ace-min/snippets/haskell_cabal.js
>f+++++++++ js/ace-min/snippets/haxe.js
>f+++++++++ js/ace-min/snippets/hjson.js
>f+++++++++ js/ace-min/snippets/html.js
>f+++++++++ js/ace-min/snippets/html_elixir.js
>f+++++++++ js/ace-min/snippets/html_ruby.js
>f+++++++++ js/ace-min/snippets/ini.js
>f+++++++++ js/ace-min/snippets/io.js
>f+++++++++ js/ace-min/snippets/jack.js
>f+++++++++ js/ace-min/snippets/jade.js
>f+++++++++ js/ace-min/snippets/java.js
>f+++++++++ js/ace-min/snippets/javascript.js
>f+++++++++ js/ace-min/snippets/json.js
>f+++++++++ js/ace-min/snippets/jsoniq.js
>f+++++++++ js/ace-min/snippets/jsp.js
>f+++++++++ js/ace-min/snippets/jssm.js
>f+++++++++ js/ace-min/snippets/jsx.js
>f+++++++++ js/ace-min/snippets/julia.js
>f+++++++++ js/ace-min/snippets/kotlin.js
>f+++++++++ js/ace-min/snippets/latex.js
>f+++++++++ js/ace-min/snippets/less.js
>f+++++++++ js/ace-min/snippets/liquid.js
>f+++++++++ js/ace-min/snippets/lisp.js
>f+++++++++ js/ace-min/snippets/livescript.js
>f+++++++++ js/ace-min/snippets/logiql.js
>f+++++++++ js/ace-min/snippets/lsl.js
>f+++++++++ js/ace-min/snippets/lua.js
>f+++++++++ js/ace-min/snippets/luapage.js
>f+++++++++ js/ace-min/snippets/lucene.js
>f+++++++++ js/ace-min/snippets/makefile.js
>f+++++++++ js/ace-min/snippets/markdown.js
>f+++++++++ js/ace-min/snippets/mask.js
>f+++++++++ js/ace-min/snippets/matlab.js
>f+++++++++ js/ace-min/snippets/maze.js
>f+++++++++ js/ace-min/snippets/mel.js
>f+++++++++ js/ace-min/snippets/mixal.js
>f+++++++++ js/ace-min/snippets/mushcode.js
>f+++++++++ js/ace-min/snippets/mysql.js
>f+++++++++ js/ace-min/snippets/nix.js
>f+++++++++ js/ace-min/snippets/nsis.js
>f+++++++++ js/ace-min/snippets/objectivec.js
>f+++++++++ js/ace-min/snippets/ocaml.js
>f+++++++++ js/ace-min/snippets/pascal.js
>f+++++++++ js/ace-min/snippets/perl.js
>f+++++++++ js/ace-min/snippets/pgsql.js
>f+++++++++ js/ace-min/snippets/php.js
>f+++++++++ js/ace-min/snippets/pig.js
>f+++++++++ js/ace-min/snippets/plain_text.js
>f+++++++++ js/ace-min/snippets/powershell.js
>f+++++++++ js/ace-min/snippets/praat.js
>f+++++++++ js/ace-min/snippets/prolog.js
>f+++++++++ js/ace-min/snippets/properties.js
>f+++++++++ js/ace-min/snippets/protobuf.js
>f+++++++++ js/ace-min/snippets/python.js
>f+++++++++ js/ace-min/snippets/r.js
>f+++++++++ js/ace-min/snippets/razor.js
>f+++++++++ js/ace-min/snippets/rdoc.js
>f+++++++++ js/ace-min/snippets/red.js
>f+++++++++ js/ace-min/snippets/redshift.js
>f+++++++++ js/ace-min/snippets/rhtml.js
>f+++++++++ js/ace-min/snippets/rst.js
>f+++++++++ js/ace-min/snippets/ruby.js
>f+++++++++ js/ace-min/snippets/rust.js
>f+++++++++ js/ace-min/snippets/sass.js
>f+++++++++ js/ace-min/snippets/scad.js
>f+++++++++ js/ace-min/snippets/scala.js
>f+++++++++ js/ace-min/snippets/scheme.js
>f+++++++++ js/ace-min/snippets/scss.js
>f+++++++++ js/ace-min/snippets/sh.js
>f+++++++++ js/ace-min/snippets/sjs.js
>f+++++++++ js/ace-min/snippets/smarty.js
>f+++++++++ js/ace-min/snippets/snippets.js
>f+++++++++ js/ace-min/snippets/soy_template.js
>f+++++++++ js/ace-min/snippets/space.js
>f+++++++++ js/ace-min/snippets/sparql.js
>f+++++++++ js/ace-min/snippets/sql.js
>f+++++++++ js/ace-min/snippets/sqlserver.js
>f+++++++++ js/ace-min/snippets/stylus.js
>f+++++++++ js/ace-min/snippets/svg.js
>f+++++++++ js/ace-min/snippets/swift.js
>f+++++++++ js/ace-min/snippets/tcl.js
>f+++++++++ js/ace-min/snippets/tex.js
>f+++++++++ js/ace-min/snippets/text.js
>f+++++++++ js/ace-min/snippets/textile.js
>f+++++++++ js/ace-min/snippets/toml.js
>f+++++++++ js/ace-min/snippets/tsx.js
>f+++++++++ js/ace-min/snippets/turtle.js
>f+++++++++ js/ace-min/snippets/twig.js
>f+++++++++ js/ace-min/snippets/typescript.js
>f+++++++++ js/ace-min/snippets/vala.js
>f+++++++++ js/ace-min/snippets/vbscript.js
>f+++++++++ js/ace-min/snippets/velocity.js
>f+++++++++ js/ace-min/snippets/verilog.js
>f+++++++++ js/ace-min/snippets/vhdl.js
>f+++++++++ js/ace-min/snippets/wollok.js
>f+++++++++ js/ace-min/snippets/xml.js
>f+++++++++ js/ace-min/snippets/xquery.js
>f+++++++++ js/ace-min/snippets/yaml.js
changed: [prod-server-lighthouse-01]

TASK [Install lighthouse | Configure SELinux for nginx] *************************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Install lighthouse | Open http/s port on firewalld] ***********************************************************************************************************
changed: [prod-server-lighthouse-01] => (item=http)
changed: [prod-server-lighthouse-01] => (item=https)

TASK [Install lighthouse | Rewrite nginx main config file] **********************************************************************************************************
--- before: /etc/nginx/nginx.conf
+++ after: /home/timych/.ansible/tmp/ansible-local-123629r3o_ztsj/tmp0s1qo8cs/nginx.conf.j2
@@ -1,7 +1,3 @@
-# For more information on configuration, see:
-#   * Official English Documentation: http://nginx.org/en/docs/
-#   * Official Russian Documentation: http://nginx.org/ru/docs/
-
 user nginx;
 worker_processes auto;
 error_log /var/log/nginx/error.log;
@@ -34,51 +30,4 @@
     # See http://nginx.org/en/docs/ngx_core_module.html#include
     # for more information.
     include /etc/nginx/conf.d/*.conf;
-
-    server {
-        listen       80;
-        listen       [::]:80;
-        server_name  _;
-        root         /usr/share/nginx/html;
-
-        # Load configuration files for the default server block.
-        include /etc/nginx/default.d/*.conf;
-
-        error_page 404 /404.html;
-        location = /404.html {
-        }
-
-        error_page 500 502 503 504 /50x.html;
-        location = /50x.html {
-        }
-    }
-
-# Settings for a TLS enabled server.
-#
-#    server {
-#        listen       443 ssl http2;
-#        listen       [::]:443 ssl http2;
-#        server_name  _;
-#        root         /usr/share/nginx/html;
-#
-#        ssl_certificate "/etc/pki/nginx/server.crt";
-#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
-#        ssl_session_cache shared:SSL:1m;
-#        ssl_session_timeout  10m;
-#        ssl_ciphers HIGH:!aNULL:!MD5;
-#        ssl_prefer_server_ciphers on;
-#
-#        # Load configuration files for the default server block.
-#        include /etc/nginx/default.d/*.conf;
-#
-#        error_page 404 /404.html;
-#            location = /40x.html {
-#        }
-#
-#        error_page 500 502 503 504 /50x.html;
-#            location = /50x.html {
-#        }
-#    }
-
 }
-

changed: [prod-server-lighthouse-01]

TASK [Install lighthouse | Rewrite nginx lighthouse config file] ****************************************************************************************************
--- before
+++ after: /home/timych/.ansible/tmp/ansible-local-123629r3o_ztsj/tmp36htg3ud/lighthouse.conf.j2
@@ -0,0 +1,16 @@
+server {
+    listen      80;
+    listen      [::]:80;
+    server_name _;
+    root        /var/www/html/lighthouse;
+
+    # logging
+    access_log  /var/log/nginx/access.log combined buffer=512k flush=1m;
+    error_log   /var/log/nginx/error.log warn;
+
+    # index.html fallback
+    location / {
+        try_files $uri $uri/ /index.html;
+    }
+
+}

changed: [prod-server-lighthouse-01]

RUNNING HANDLER [Reload nginx service] ******************************************************************************************************************************
changed: [prod-server-lighthouse-01]

PLAY RECAP **********************************************************************************************************************************************************
prod-server-clickhouse-01  : ok=17   changed=14   unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
prod-server-lighthouse-01  : ok=12   changed=10   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
prod-server-vector-01      : ok=8    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

<details>
<summary>ansible-playbook -i inventory/prod.yml site.yml --diff</summary>
timych@timych-ubu2:~/clickhouse_vector_lighthouse/playbook$ ansible-playbook -i inventory/prod_tf.yml site.yml --diff

PLAY [Install Clickhouse] *******************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Download clickhouse distrib] *************************************************************************************************************
ok: [prod-server-clickhouse-01] => (item=clickhouse-client)
ok: [prod-server-clickhouse-01] => (item=clickhouse-server)
failed: [prod-server-clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1001, "group": "timych", "item": "clickhouse-common-static", "mode": "0440", "msg": "Request failed", "owner": "timych", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1001, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Install Clickhouse | Download clickhouse distrib] *************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Install clickhouse packages] *************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Flush handlers] **************************************************************************************************************************

TASK [Install Clickhouse | Check if Clickhouse started] *************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Install Clickhouse | Create database] *************************************************************************************************************************
ok: [prod-server-clickhouse-01]

PLAY [Configure Сlickhouse] *****************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Install epel] **************************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Install python-pip and firewalld] ******************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Install pip lxml] **********************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Create table for syslog] ***************************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse server config] *******************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Modify clickhouse client config] *******************************************************************************************************
ok: [prod-server-clickhouse-01]

TASK [Configure clickhouse | Open clickhouse port on firewalld] *****************************************************************************************************
ok: [prod-server-clickhouse-01]

PLAY [Install Vector] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-vector-01]

TASK [Install vector | Download vector distrib] *********************************************************************************************************************
ok: [prod-server-vector-01]

TASK [Install vector | Install vector package] **********************************************************************************************************************
ok: [prod-server-vector-01]

TASK [Install vector | Delete default vector config] ****************************************************************************************************************
ok: [prod-server-vector-01]

TASK [Install vector | Set default vector config file for service] **************************************************************************************************
ok: [prod-server-vector-01]

TASK [Install vector | Vector config from template] *****************************************************************************************************************
ok: [prod-server-vector-01]

TASK [Install vector | Flush handlers] ******************************************************************************************************************************

TASK [Install vector | Check if vector started] *********************************************************************************************************************
ok: [prod-server-vector-01]

PLAY [Install lighthouse] *******************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Install lighthouse | Install epel repo] ***********************************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Install lighthouse | Install nginx, git and firewalld] ********************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Install lighthouse | Flush handlers] **************************************************************************************************************************

TASK [Install lighthouse | Clone a lighthouse repo] *****************************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Synchronize two directories on one remote host.] **************************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Install lighthouse | Configure SELinux for nginx] *************************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Install lighthouse | Open http/s port on firewalld] ***********************************************************************************************************
ok: [prod-server-lighthouse-01] => (item=http)
ok: [prod-server-lighthouse-01] => (item=https)

TASK [Install lighthouse | Rewrite nginx main config file] **********************************************************************************************************
ok: [prod-server-lighthouse-01]

TASK [Install lighthouse | Rewrite nginx lighthouse config file] ****************************************************************************************************
ok: [prod-server-lighthouse-01]

PLAY RECAP **********************************************************************************************************************************************************
prod-server-clickhouse-01  : ok=13   changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
prod-server-lighthouse-01  : ok=9    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
prod-server-vector-01      : ok=7    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
</details>

9.  Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10.  Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.


[Готовый playbook с описанием](https://github.com/Timych84/devops-netology/tree/main/08-ansible-03-yandex/playbook)


---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
