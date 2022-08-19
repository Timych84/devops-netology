# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной  программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. Вам нужно найти тот единственный, который относится именно к `cd`. Обратите внимание, что `strace` выдаёт результат своей работы в поток stderr, а не в stdout.
    ```
    chdir("/tmp")                           = 0
    ```

2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:
    ```bash
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
    ```
    Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.
    ```
    stat("/home/vagrant/.magic.mgc", 0x7fff934a0fb0) = -1 ENOENT (No such file or directory)
    stat("/home/vagrant/.magic", 0x7fff934a0fb0) = -1 ENOENT (No such file or directory)
    openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
    stat("/etc/magic", {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
    openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
    fstat(3, {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
    read(3, "# Magic local data for file(1) c"..., 4096) = 111
    read(3, "", 4096)                       = 0
    close(3)                                = 0
    openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
    fstat(3, {st_mode=S_IFREG|0644, st_size=5811536, ...}) = 0
    mmap(NULL, 5811536, PROT_READ|PROT_WRITE, MAP_PRIVATE, 3, 0) = 0x7f04ce381000
    close(3)                                = 0
    ```
    Во всех случаях обращается к /usr/share/misc/magic.mgc, из man magic:
    ```
    magic — file command's magic pattern file
    ```

3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).
    ```bash
    $ vim 1.tst
    $ rm .1.tst.swp
    $ lsof |grep vim
     vi 1302096 vagrant 4u REG 253,0 12288 1881393 /home/vagrant/.1.tst.swp(deleted)
    $ file /proc/1302096/fd/4
     /proc/1302096/fd/4: symbolic link to /home/vagrant/.1.tst.swp (deleted)
    $ echo > /proc/1302096/fd/4
    ```

4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
   
   Зомби-процессы не потребляют ресурсы ОС.

5. В iovisor BCC есть утилита `opensnoop`:
    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).
    ```bash
    vagrant@vagrant:~$ sudo /usr/sbin/opensnoop-bpfcc
    PID    COMM               FD ERR PATH
    388    systemd-udevd      14   0 /sys/fs/cgroup/unified/system.slice/systemd-udevd.service/cgroup.procs
    388    systemd-udevd      14   0 /sys/fs/cgroup/unified/system.slice/systemd-udevd.service/cgroup.threads
    653    irqbalance          6   0 /proc/interrupts
    653    irqbalance          6   0 /proc/stat
    653    irqbalance          6   0 /proc/irq/20/smp_affinity
    653    irqbalance          6   0 /proc/irq/0/smp_affinity
    653    irqbalance          6   0 /proc/irq/1/smp_affinity
    653    irqbalance          6   0 /proc/irq/8/smp_affinity
    653    irqbalance          6   0 /proc/irq/12/smp_affinity
    653    irqbalance          6   0 /proc/irq/14/smp_affinity
    653    irqbalance          6   0 /proc/irq/15/smp_affinity
    858    vminfo              5   0 /var/run/utmp
    648    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
    648    dbus-daemon        21   0 /usr/share/dbus-1/system-services
    648    dbus-daemon        -1   2 /lib/dbus-1/system-services
    648    dbus-daemon        21   0 /var/lib/snapd/dbus-1/system-services/
    ```


6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.
    ```
    uname({sysname="Linux", nodename="vagrant", ...}) = 0
    fstat(1, {st_mode=S_IFCHR|0600, st_rdev=makedev(0x88, 0x3), ...}) = 0
    uname({sysname="Linux", nodename="vagrant", ...}) = 0
    uname({sysname="Linux", nodename="vagrant", ...}) = 0
    write(1, "Linux vagrant 5.4.0-110-generic "..., 108) = 108
    ```
    в man 2 uname есть ссылка на:
    ```
       Part of the utsname information is also accessible via
       /proc/sys/kernel/{ostype, hostname, osrelease, version,
       domainname}
    ```

7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
    ```bash
    root@netology1:~# test -d /tmp/some_dir; echo Hi
    Hi
    root@netology1:~# test -d /tmp/some_dir && echo Hi
    root@netology1:~#
    ```
    Есть ли смысл использовать в bash `&&`, если применить `set -e`?
    
    ; - запускать команды по очереди\
    && - запустить вторую если у первой exit code=0 \
    set -e дает команду на выход из shell если exit code не равен 0
    Но при этом если протестировать конструкцию `test -d /tmp/some_dir && echo Hi` то shell не выходит, при этом при `test -d /tmp/some_dir` - shell сразу завершает работу.

8.  Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?
   
    set -e дает команду на выход из shell если exit code не равен 0\
    set -u  дает команду на выход из shell если идет обращение к необъявленной переменной\
    set -x Выводить на экран команды перед их выполнением.\
    set -o pipefail возвращает ошибку в exit code при любой ошибке даже если последняя команда в pipe была успешной(по умолчанию exit code не 0 возвращается только если последняя команда выдает ошибку)\

    Использование этого набора команд позволяет избавиться от ошибок и не продолжать выполнение оставшейся части скрипта в случае наличия ошибок. Также можно выводить что-то наподобие отладочной информации с ключом -x.

9.  Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

    ```bash
    vagrant@vagrant:~$ ps -axfo stat |grep -v "STAT" |sort | uniq -c -w1
        48 I
        1 R+
        84 S
    ```
    В основном два статуса:
    S - interruptible sleep (waiting for an event to complete). Спящие процессы ожидающие событий.
    I - Idle kernel thread. Процессы ядра в ожидании


 