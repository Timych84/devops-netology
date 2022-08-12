5. Какие ресурсы выделены по-умолчанию?   
    ```
    2 процессора
    1 ГБ оперативной памяти
    64 ГБ жесткий диск
    ```
6. Как добавить оперативной памяти или ресурсов процессора виртуальной машине?   
    В vagranfile добавить следующее:
    ```
    config.vm.provider "virtualbox" do |v|

      v.memory = 2048

      v.cpus = 2

    end
    ```
8. какой переменной можно задать длину журнала history, и на какой строчке manual это описывается?
   Строка зависит от размера экрана(ниже выдержка из man).
   Есть длина файла журнала(по умолчанию . bash_history) и длина журнада кэшированных команд:  
    ```
    HISTFILESIZE
          The maximum number of lines contained in the history file.  When this variable is assigned a value, the history file is truncated, if necessary, to contain no more than that number of lines by removing the oldest  en‐
          tries.   The  history  file is also truncated to this size after writing it when a shell exits.  If the value is 0, the history file is truncated to zero size.  Non-numeric values and numeric values less than zero in‐
          hibit truncation.  The shell sets the default value to the value of HISTSIZE after reading any startup files.
    HISTSIZE
          The  number of commands to remember in the command history (see HISTORY below).  If the value is 0, commands are not saved in the history list.  Numeric values less than zero result in every command being saved on the
          history list (there is no limit).  The shell sets the default value to 500 after reading any startup files.
    ```
    Что делает директива ignoreboth в bash?    
    ignoreboth - не будет записывать в историю команды, начинающиеся с пробела, а также команды, которые совпадают с предыдущей введенной командой
9. В каких сценариях использования применимы скобки {} и на какой строчке man bash это описано?

Скобки применяются
1. Для списка команд:

    Строка зависит от размера экрана(ниже выдержка из man), можно применять для группировки команд, например:
    ```
    vagrant@vagrant:~$ { pwd; ls /tmp; }

    /home/vagrant
    snap.lxd
    systemd-private-a8ae3ab30ce34fe8b40f8b6af498dcfb-ModemManager.service-fxZpbf
    systemd-private-a8ae3ab30ce34fe8b40f8b6af498dcfb-systemd-logind.service-tK82Fg
    systemd-private-a8ae3ab30ce34fe8b40f8b6af498dcfb-systemd-resolved.service-TeHnei
    ```
    из man bash:
    ```
    { list; }
                list is simply executed in the current shell environment.  list must be terminated with a newline or semicolon.  This is known as a group command.  The return status is
                the exit status of list.  Note that unlike the metacharacters ( and ), { and } are reserved words and must occur where a reserved word is permitted  to  be  recognized.
                Since they do not cause a word break, they must be separated from list by whitespace or another shell metacharacter.
    ```
2. Для генерации списков:

    Строка зависит от размера экрана(ниже выдержка из man), можно применять для генерации списка, например:
    ```
    vagrant@vagrant:~$ echo {00..10}
    00 01 02 03 04 05 06 07 08 09 10
    ```
    из man bash:

    ```
    Brace Expansion
        Brace  expansion  is a mechanism by which arbitrary strings may be generated.  This mechanism is similar to
        pathname expansion, but the filenames generated need not exist.  Patterns to be  brace  expanded  take  the
        form  of an optional preamble, followed by either a series of comma-separated strings or a sequence expres‐
        sion between a pair of braces, followed by an optional postscript.  The preamble is prefixed to each string
        contained  within  the braces, and the postscript is then appended to each resulting string, expanding left
        to right.

        Brace expansions may be nested.  The results of each expanded string are not sorted; left to right order is
        preserved.  For example, a{d,c,b}e expands into `ade ace abe'.
    ```
3. Для подстановки параметров: 

    Строка зависит от размера экрана(ниже выдержка из man), можно применять в виде ${} для изменения параметров, например:
    ```
    vagrant@vagrant:/tmp/tst$ i="bad good"
    vagrant@vagrant:/tmp/tst$ echo ${i#bad}
    good
    ```
    из man bash:
    ```    
      Parameter Expansion
          ${parameter}
                  The value of parameter is substituted.  The braces are required when parameter is a  positional  pa‐
                  rameter  with  more  than one digit, or when parameter is followed by a character which is not to be
                  interpreted as part of its name.  The parameter is a shell parameter as described above  PARAMETERS)
                  or an array reference (Arrays).
    ```
10. Основываясь на предыдущем вопросе, как создать однократным вызовом touch 100000 файлов? А получилось ли создать 300000? Если нет, то почему?
    Создать 100000 файлов:
    ```
    touch {00000..99999}.tst
    ```
    Создать 300000 файлов не получится из-за предельной длины аргумента (параметр ARG_MAX, в используемой ОС - 2097152), создать 300000 файлов можно например так:
    ```
    echo {000000..299999}.tst |xargs touch
    ```

11. В man bash поищите по /\[\[. Что делает конструкция [[ -d /tmp ]]
    
    [[ expression ]] - проверка выражения, возвращает результат в exit code, например 0 - true , 1 -false. Exit code можно посмотреть в echo $?.

    Конструкция [[ -d /tmp ]] проверяет наличие директории /tmp
    ```
    vagrant@vagrant:/tmp/tst$ [[ -d /tmp ]]; echo $?
    0
    vagrant@vagrant:/tmp/tst$ [[ -d /tmp1 ]]; echo $?
    1
    ```

12.  добейтесь в выводе type -a bash

      ```
      mkdir /tmp/new_path_directory/
      cp /usr/bin/bash /tmp/new_path_directory/
      export PATH=/tmp/new_path_directory:$PATH
      echo $PATH
      type -a bash
        bash is /tmp/new_path_directory/bash
        bash is /usr/bin/bash
        bash is /bin/bash
      which bash
        /tmp/new_path_directory/bash
      ```
      если нужно пережить перезагрузку - добавляем в ~/.bashrc export PATH=/tmp/new_path_directory:$PATH, но нужно будет при загрузке организовать создание директории в /tmp и копирование туда bash
13. Чем отличается планирование команд с помощью batch и at?
    
      at - запустить команду в заданное время\
      batch - запустить команду, когда нагрузка на процессор (load average) будет ниже 1.5



