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


4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
5. В iovisor BCC есть утилита `opensnoop`:
    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).
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
    
    ; - запускать команды по очереди
    && - запустить вторую если у первой exit code=0 
    set -e дает команду на выход из shell если exit code не равен 0
    Но при этом если протестировать конструкцию `test -d /tmp/some_dir && echo Hi` то shell не выходит, при этом при `test -d /tmp/some_dir` - shell сразу завершает работу.

8.  Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?
    set -e дает команду на выход из shell если exit code не равен 0\
    set -u Treats unset or undefined variables as an error when substituting\
    set -x Prints out command arguments during execution.\
    set -o pipefail The return value of a pipeline is the status of the last command that had a non-zero status upon exit. If no command had a non-zero status upon exit, the value is zero.\

9.  Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).


vagrant@vagrant:~$ ps -axfo stat |sort | uniq -c
      9 I
     39 I<
      1 R+
     29 S
      3 S+
      7 S<
      1 Sl
      1 SLsl
      2 SN
      1 S<s
     17 Ss
      3 Ss+
      7 Ssl
      1 STAT

 