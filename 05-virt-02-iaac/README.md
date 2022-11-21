

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.

  Применение IaaC паттернов позволяет всегда получать одинаковую конфигурацию инфраструктуры. Исключается человеческий фактор, сокращается время развертывания из-за уменьшения или исключения ручных операций.

- Какой из принципов IaaC является основополагающим?

  Основным принципом является идемпотентность, получение одинакового результата при повторных действиях

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?

    - Легкое использование, всё описывается YAML конфигурацией
    - Большое количество модулей с возможностью писать собственные на python
    - отсутсвие необходимости установки агентов

- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

    В целом push более надежный способ так как с ноды управления точно известно применилась ли конфигурация на целевых хостах. Нет необходимости следить за агентами на целевых хостах. При этом есть некоторая проблема с безопасностью из-за хранения ключей доступа к серверам на ноде управления.


## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

    *Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*




    ```bash
    timych@timych-ubu2:~/vagrant/netology$ VBoxManage --version
    6.1.38_Ubuntur153438

    timych@timych-ubu2:~/vagrant/netology$ vagrant --version
    Vagrant 2.3.3

    timych@timych-ubu2:~/vagrant/netology$ ansible --version
    ansible [core 2.12.10]
    config file = /home/timych/vagrant/netology/ansible.cfg
    configured module search path = ['/home/timych/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
    ansible python module location = /usr/lib/python3/dist-packages/ansible
    ansible collection location = /home/timych/.ansible/collections:/usr/share/ansible/collections
    executable location = /usr/bin/ansible
    python version = 3.8.10 (default, Jun 22 2022, 20:18:18) [GCC 9.4.0]
    jinja version = 2.10.1
    libyaml = True
    ```


## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды

Можно установить как в лекции через плейбук
Можно в vagrantfile добавить и vagrant сам установит docker:

```ruby
config.vm.provision "docker"
```

При установке через плейбук:
- Vagrantfile:
```ruby
ISO = "bento/ubuntu-20.04"
NET = "192.168.56."
DOMAIN = ".netology"
HOST_PREFIX = "server"
INVENTORY_PATH = "./inventory"

servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ip => NET + "11",
    :ssh_host => "20011",
    :ssh_vm => "22",
    :ram => 1024,
    :core => 1
  }
]

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = ISO
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.network :forwarded_port, guest: machine[:ssh_vm], host: machine[:ssh_host]
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:core]]
        vb.name = machine[:hostname]
      end
      node.vm.provision "ansible" do |setup|
        setup.inventory_path = INVENTORY_PATH
        setup.playbook = "./playbook.yml"
        setup.become = true
        setup.extra_vars = { ansible_user: 'vagrant' }
      end
    end
  end
end
```

 - playbook.yml:

```yml
---
- name: 'Playbook'
  hosts: nodes
  become: yes

  tasks:
    - name: Installing tools
      apt:
        package: "{{ item }}"
        state: present
        update_cache: yes
      with_items:
        - git
        - curl

    - name: Installing docker
      shell: curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh

    - name: testwhoami
      shell: whoami >> whoami.txt

    - name: Add the current user to docker group
      user:
        name: vagrant
        append: yes
        groups: docker
```

- ansible.cfg:


```properties
[defaults]
inventory=./inventory
deprecation_warnings=False
command_warnings=False
ansible_port=22
interpreter_python=/usr/bin/python3
host_key_checking = False
```

- inventory file, hosts:


```properties
[nodes:children]
manager
worker

[manager]
server1.netology ansible_host=192.168.56.11 ansible_user=vagrant

[worker]
```

Итоговый вывод:

```
docker ps
```


```bash
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
