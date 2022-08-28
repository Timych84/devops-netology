# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.\
    Преимущества:
    экономия дискового пространства. Использование разрежённых файлов считается одним из способов сжатия данных на уровне файловой системы;
    отсутствие временных затрат на запись нулевых байт;
    увеличение срока службы запоминающих устройств.

    Недостатки:
    накладные расходы на работу со списком дыр;
    фрагментация файла при частой записи данных в дыры;
    невозможность записи данных в дыры при отсутствии свободного места на диске;
    невозможность использования других индикаторов дыр, кроме нулевых байт.

1. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?\
    Не может т.к. жесткая ссылка и файл ссылаются на одинаковые inode, отличаются только имена файлов.
1. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.
    ```bash
    vagrant@vagrant:~$ lsblk
    NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    loop0                       7:0    0 67.2M  1 loop /snap/lxd/21835
    loop1                       7:1    0 43.6M  1 loop /snap/snapd/14978
    loop2                       7:2    0 61.9M  1 loop /snap/core20/1328
    sda                         8:0    0   64G  0 disk
    ├─sda1                      8:1    0    1M  0 part
    ├─sda2                      8:2    0  1.5G  0 part /boot
    └─sda3                      8:3    0 62.5G  0 part
    └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm  /
    sdb                         8:16   0  2.5G  0 disk
    sdc                         8:32   0  2.5G  0 disk
    ```
1. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.
    ```bash
    root@vagrant:~# fdisk /dev/sdb
    Command (m for help): n
    Partition type
    p   primary (0 primary, 0 extended, 4 free)
    e   extended (container for logical partitions)
    Select (default p):

    Using default response p.
    Partition number (1-4, default 1):
    First sector (2048-5242879, default 2048):
    Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

    Created a new partition 1 of type 'Linux' and of size 2 GiB.

    Command (m for help): n
    Partition type
    p   primary (1 primary, 0 extended, 3 free)
    e   extended (container for logical partitions)
    Select (default p):

    Using default response p.
    Partition number (2-4, default 2):
    First sector (4196352-5242879, default 4196352):
    Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):

    Created a new partition 2 of type 'Linux' and of size 511 MiB.

    Command (m for help): p
    Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    Disk model: VBOX HARDDISK
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x4358e6ed

    Device     Boot   Start     End Sectors  Size Id Type
    /dev/sdb1          2048 4196351 4194304    2G 83 Linux
    /dev/sdb2       4196352 5242879 1046528  511M 83 Linux
    Command (m for help): w
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.
    ```
1. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.
    ```bash
    root@vagrant:~# sfdisk --dump /dev/sdb > sdb.dump
    root@vagrant:~# sfdisk /dev/sdc < sdb.dump
    Checking that no-one is using this disk right now ... OK

    Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    Disk model: VBOX HARDDISK
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes

    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Created a new DOS disklabel with disk identifier 0x4358e6ed.
    /dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
    /dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
    /dev/sdc3: Done.
    New situation:
    Disklabel type: dos
    Disk identifier: 0x4358e6ed
    Device     Boot   Start     End Sectors  Size Id Type
    /dev/sdc1          2048 4196351 4194304    2G 83 Linux
    /dev/sdc2       4196352 5242879 1046528  511M 83 Linux
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.
   
   
   root@vagrant:~# fdisk -l /dev/sd[b,c]
    Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    Disk model: VBOX HARDDISK
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x4358e6ed

    Device     Boot   Start     End Sectors  Size Id Type
    /dev/sdb1          2048 4196351 4194304    2G 83 Linux
    /dev/sdb2       4196352 5242879 1046528  511M 83 Linux


    Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    Disk model: VBOX HARDDISK
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x4358e6ed

    Device     Boot   Start     End Sectors  Size Id Type
    /dev/sdc1          2048 4196351 4194304    2G 83 Linux
    /dev/sdc2       4196352 5242879 1046528  511M 83 Linux
    ```

1. Соберите `mdadm` RAID1 на паре разделов 2 Гб.
    ```bash
    mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sd[bc]1
    ```
2. Соберите `mdadm` RAID0 на второй паре маленьких разделов.
    ```bash
    mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sd[bc]2
    root@vagrant:~# cat /proc/mdstat
    Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
    md1 : active raid0 sdc2[1] sdb2[0]
        1042432 blocks super 1.2 512k chunks

    md0 : active raid1 sdc1[1] sdb1[0]
        2094080 blocks super 1.2 [2/2] [UU]
    #записываем конфигурацию md в /etc/mdadm/mdadm.conf
    sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
    #обновляем initRAM, чтобы md доабвлялся при загрузке системы и не переименовывался в md126,md127 и т.д.
    sudo update-initramfs -u        
    ```
1. Создайте 2 независимых PV на получившихся md-устройствах.
    ```bash
    root@vagrant:~# pvcreate /dev/md0
    Physical volume "/dev/md0" successfully created.
    root@vagrant:~# pvcreate /dev/md1
    Physical volume "/dev/md1" successfully created.
   ```
1. Создайте общую volume-group на этих двух PV.
    ```bash
    root@vagrant:~# vgcreate netology-vg /dev/md0 /dev/md1
    ```
1. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
    ```bash
    root@vagrant:~# lvcreate -L 100m -n netology-lv netology-vg /dev/md1
    root@vagrant:~# lvs -a -o +devices
    LV          VG          Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices
    netology-lv netology-vg -wi-a----- 100.00m                                                     /dev/md1(0)
    ubuntu-lv   ubuntu-vg   -wi-ao---- <31.25g                                                     /dev/sda3(0)
    ```
1. Создайте `mkfs.ext4` ФС на получившемся LV.
    ```bash
    root@vagrant:~# mkfs.ext4 /dev/netology-vg/netology-lv
    mke2fs 1.45.5 (07-Jan-2020)
    Creating filesystem with 25600 4k blocks and 25600 inodes

    Allocating group tables: done
    Writing inode tables: done
    Creating journal (1024 blocks): done
    Writing superblocks and filesystem accounting information: done
    ``` 
1. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.
    ```bash
    root@vagrant:~# mkdir /tmp/new
    root@vagrant:~# mount /dev/netology-vg/netology-lv /tmp/new
    ```
1. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.
    ```bash
    root@vagrant:/tmp/new# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
    ```
1.  Прикрепите вывод `lsblk`.
    ```bash
    root@vagrant:/tmp/new# lsblk
    NAME                            MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
    loop0                             7:0    0 61.9M  1 loop  /snap/core20/1328
    loop1                             7:1    0 67.2M  1 loop  /snap/lxd/21835
    loop2                             7:2    0   47M  1 loop  /snap/snapd/16292
    loop3                             7:3    0 43.6M  1 loop  /snap/snapd/14978
    loop4                             7:4    0   62M  1 loop  /snap/core20/1611
    loop5                             7:5    0 67.8M  1 loop  /snap/lxd/22753
    sda                               8:0    0   64G  0 disk
    ├─sda1                            8:1    0    1M  0 part
    ├─sda2                            8:2    0  1.5G  0 part  /boot
    └─sda3                            8:3    0 62.5G  0 part
    └─ubuntu--vg-ubuntu--lv       253:0    0 31.3G  0 lvm   /
    sdb                               8:16   0  2.5G  0 disk
    ├─sdb1                            8:17   0    2G  0 part
    │ └─md0                           9:0    0    2G  0 raid1
    └─sdb2                            8:18   0  511M  0 part
    └─md1                           9:1    0 1018M  0 raid0
        └─netology--vg-netology--lv 253:1    0  100M  0 lvm   /tmp/new
    sdc                               8:32   0  2.5G  0 disk
    ├─sdc1                            8:33   0    2G  0 part
    │ └─md0                           9:0    0    2G  0 raid1
    └─sdc2                            8:34   0  511M  0 part
    └─md1                           9:1    0 1018M  0 raid0
        └─netology--vg-netology--lv 253:1    0  100M  0 lvm   /tmp/new
    ```
1. Протестируйте целостность файла:
    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```
    ```bash
    root@vagrant:/tmp/new# gzip -t /tmp/new/test.gz
    root@vagrant:/tmp/new# echo $?
    0
    ```
1. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
    ```bash
    root@vagrant:/tmp/new# pvmove /dev/md1 /dev/md0
    /dev/md1: Moved: 12.00%
    /dev/md1: Moved: 100.00%
    root@vagrant:/tmp/new# lvs -a -o +devices
    LV          VG          Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices
    netology-lv netology-vg -wi-ao---- 100.00m                                                     /dev/md0(0)
    ubuntu-lv   ubuntu-vg   -wi-ao---- <31.25g                                                     /dev/sda3(0)
    ```


1. Сделайте `--fail` на устройство в вашем RAID1 md.
    ```bash
    root@vagrant:/tmp/new# mdadm --manage /dev/md0 --fail /dev/sdb1
    mdadm: set /dev/sdb1 faulty in /dev/md0
    ```
1. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
    ```bash
    [ 2775.981439] md/raid1:md0: Disk failure on sdb1, disabling device.
                md/raid1:md0: Operation continuing on 1 devices.
    ```
1. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:
    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```
    ```bash
    root@vagrant:/tmp/new# gzip -t /tmp/new/test.gz
    root@vagrant:/tmp/new# echo $?
    0
    ```
1. Погасите тестовый хост, `vagrant destroy`.

