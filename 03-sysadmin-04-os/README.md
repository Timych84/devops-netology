# Домашнее задание к занятию "3.4. Операционные системы, лекция 2"

1. На лекции мы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:

    * поместите его в автозагрузку,
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.

    ```bash
    #распаковываем архив
    tar -xvf node_exporter-1.3.1.linux-amd64.tar.gz
    #переносим в /usr/local/bin/
    mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
    #добавляем пользователя, от которого будет запускаться node_exporter как сервис
    useradd -rs /bin/false node_exporter


    vi /etc/systemd/system/node_exporter.service
        [Unit]
        Description=Node Exporter
        After=network.target

        [Service]
        User=node_exporter
        Group=node_exporter
        Type=simple
        EnvironmentFile=/usr/local/etc/node_exporter
        ExecStart=/usr/local/bin/node_exporter $OPTIONS

        [Install]
        WantedBy=multi-user.target

    #Для примера можно добавить опцию --collector.textfile.directory из файла /usr/local/etc/node_exporter
    #Создаем папку куда можно будет класть файлы для textfile_collector
    mkdir -p /var/lib/node_exporter/textfile_collector
    #Даем права папке куда можно будет класть файлы для textfile_collector
    chown -R node_exporter:node_exporter /var/lib/node_exporter
    #редактируем файл с опциями, добавляем папку куда можно будет класть файлы для textfile_collector
    vi /usr/local/etc/node_exporter
        OPTIONS="--collector.textfile.directory /var/lib/node_exporter/textfile_collector" 
    #перечитываем юнит файлы
    systemctl daemon-reload
    #запускаем node_exporter как службу
    systemctl start node_exporter
    #проверяем запуск node_exporter как службы
    systemctl status node_exporter
        ● node_exporter.service - Node Exporter
            Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
            Active: active (running) since Wed 2022-08-24 19:31:09 UTC; 37min ago
        Main PID: 2067415 (node_exporter)
            Tasks: 8 (limit: 2274)
            Memory: 5.8M
            CGroup: /system.slice/node_exporter.service
                    └─2067415 /usr/local/bin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector
    #Добавляем запуск node_exporter в автозагрузку
    systemctl enable node_exporter
    #перезагружаем, проверяем, что служба работает
    reboot
    uptime
    20:10:35 up 0 min,  1 user,  load average: 0.12, 0.03, 0.01
    systemctl status node_exporter.service
        ● node_exporter.service - Node Exporter
            Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
            Active: active (running) since Wed 2022-08-24 20:10:09 UTC; 23s ago
        Main PID: 673 (node_exporter)
            Tasks: 4 (limit: 2274)
            Memory: 14.0M
            CGroup: /system.slice/node_exporter.service
                    └─673 /usr/local/bin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector
    #проверяем доступность сервиса
    curl -L localhost:9100
        <html>
        <head><title>Node Exporter</title></head>
        <body>
        <h1>Node Exporter</h1>
        <p><a href="/metrics">Metrics</a></p>
        </body>
        </html>
    ```

1. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.

1. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). После успешной установки:
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

    После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

    ```bash
    vagrant@vagrant:~$ systemctl status netdata.service
    ● netdata.service - netdata - Real-time performance monitoring
        Loaded: loaded (/lib/systemd/system/netdata.service; enabled; vendor preset: enabled)
        Active: active (running) since Fri 2022-08-26 19:41:49 UTC; 3min 0s ago
        Docs: man:netdata
                file:///usr/share/doc/netdata/html/index.html
                https://github.com/netdata/netdata
    Main PID: 672 (netdata)
        Tasks: 22 (limit: 2274)
        Memory: 68.7M
        CGroup: /system.slice/netdata.service
                ├─672 /usr/sbin/netdata -D
                ├─821 bash /usr/lib/netdata/plugins.d/tc-qos-helper.sh 1
                ├─839 /usr/lib/netdata/plugins.d/nfacct.plugin 1
                └─870 /usr/lib/netdata/plugins.d/apps.plugin 1

    Aug 26 19:41:49 vagrant systemd[1]: Started netdata - Real-time performance monitoring.
    Aug 26 19:41:49 vagrant netdata[672]: SIGNAL: Not enabling reaper
    Aug 26 19:41:49 vagrant netdata[672]: 2022-08-26 19:41:49: netdata INFO  : MAIN : SIGNAL: Not enabling reaper
    ```
    Посмотрел, годится для одиночных серверов, например домашнего самодельного NAS вполне подойдет.
1. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?
    ```bash
    root@vagrant:~/testscripts# dmesg  |grep -i virtual
    [    0.000000] DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
    [    0.002051] CPU MTRRs all blank - virtualized system.
    [    0.093505] Booting paravirtualized kernel on KVM
    [    2.600549] systemd[1]: Detected virtualization oracle.
    ```

1. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?
    ```bash
    vagrant@vagrant:~$ sysctl fs.nr_open
    fs.nr_open = 1048576
    ```    
    Параметр fs.nr_open - лимит на максимальное количество открытых дескрипторов также можно посмотреть в:
    ```bash
    vagrant@vagrant:~$ cat /proc/sys/fs/nr_open
    1048576
    ```
    Также есть лимит на количество открытых фалйов ulimit -n(есть мягкий и жесткий лимит, непривилегированный пользователь может менять лимит в пределах значеня жесткого лимита):
    ```bash
    vagrant@vagrant:~$ ulimit -S -n
        1024
    vagrant@vagrant:~$ ulimit -H -n
        1048576
    vagrant@vagrant:~$ ulimit -S -n 1048576
    vagrant@vagrant:~$ ulimit -S -n
        1048576
    vagrant@vagrant:~$  ulimit -S -n 1048577
    -bash: ulimit: open files: cannot modify limit: Invalid argument
    ```
    
1. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.

    ```bash
    root@vagrant:~# unshare --fork --pid --mount-proc sleep 1h
    ^Z
    bg
    root@vagrant:~# ps
        PID TTY          TIME CMD
    6424 pts/1    00:00:00 sudo
    6425 pts/1    00:00:00 su
    6426 pts/1    00:00:00 bash
    6495 pts/1    00:00:00 unshare
    6496 pts/1    00:00:00 sleep
    6498 pts/1    00:00:00 ps

    vagrant@vagrant:~/test$ sudo nsenter --target 6496 --pid --mount
    root@vagrant:/# ps aux
    USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root           1  0.0  0.0   5476   584 pts/1    S+   12:34   0:00 sleep 15m
    root           2  0.1  0.2   8304  5144 pts/2    S    12:34   0:00 -bash
    root          15  0.0  0.1   8888  3324 pts/2    R+   12:34   0:00 ps aux
    ```

2. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

Если разобрать команду то получтся:

1. :() - обявляется функция с именем ":"
1. :|:& - вызывает сама себя и отправляет вывод в нее же и всё это запускается в фоне
1. ;: - конец определния функции и сразу же ее запуск 
1. Таким образом получится, что функция начнет постоянно вызывать саму себя пока не упрется в ограничение количества процессов на пользователя, дальше система не даст создавать дополнительные форки.


    ```bash
    root@vagrant:~# ulimit -S -u
    7580

    root@vagrant:~# ulimit -S -u 1000
    #после этого стабилизация произойдет быстрее
    
    [  984.073380] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-1.scope
    ```

 
 ---
