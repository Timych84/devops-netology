# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательные задания

1. Есть скрипт:
	```python
    #!/usr/bin/env python3
	a = 1
	b = '2'
	c = a + b
	```
	* Какое значение будет присвоено переменной c?\
    	Будет ошибка несовместимости типов переменных
	* Как получить для переменной c значение 12?\
		Можно задать a = '1', тогда c будет строковое знаечение 12
	* Как получить для переменной c значение 3?\
		Задать a = 1 и b = 2, тогда с будет равно числу 3

2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

	```python
    #!/usr/bin/env python3

    import os

	bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
	result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
	for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            break

	```
	Доработанный скрипт:

	```python
	#!/usr/bin/env python3

	import os
	git_repopath = "~/sysadm-homeworks"
	bash_command = ["cd " + git_repopath, "git status"]
	result_os = os.popen(' && '.join(bash_command)).read()
	for result in result_os.split('\n'):
		if result.find('modified') != -1:
			prepare_result = os.path.expanduser(git_repopath) + "/" + result.replace('\tmodified:   ', '')
			print(prepare_result)
	```


1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.
	```python
	#!/usr/bin/env python3

	import os
	import sys
	n = len(sys.argv)
	if n > 2:  # проверяем что аргумент один
		sys.exit("Too many arguments")
	elif n == 1:  # при проверке текущего пути
		git_repopath = os.getcwd()
	else:  # при наличии пути в аргументе
		git_repopath = sys.argv[1]
	if (os.path.exists(git_repopath)):   # проверяем что путь существует
		bash_command = ["cd " + git_repopath, "git status 2>&1"]
		result_os = os.popen(' && '.join(bash_command)).read()
		if result_os.find("not a git repository") != -1:  # проверяем что путь репозиторий git
			sys.exit(git_repopath + " not a git repository")
		else:
			for result in result_os.split('\n'):
				if result.find('modified') != -1:
					prepare_result = os.path.expanduser(git_repopath) + "/" + result.replace('\tmodified:   ', '')
					print(prepare_result)
	else:
		sys.exit("Path " + git_repopath + " not exists")
	```


1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.


	```python
	#!/usr/bin/env python3

	from time import sleep
	import dns.resolver
	import sys
	import yaml
	import os


	class CheckSite:
		def __init__(self, dnsname):
			self.dnsname = dnsname
			self.lastip = None
			self.ipstate = None

		def checkip(self):
			result = dns.resolver.resolve(self.dnsname)
			for val in result:
				newip = val.to_text()

			if self.lastip is None:
				self.lastip = newip
				self.ipstate = 'New'
				print(f"{self.dnsname} - {newip}")
			elif newip == self.lastip:
				print(f"{self.dnsname} - {newip}")
				self.ipstate = 'Same'
			elif (self.lastip is not None) and (newip != self.lastip):
				print(f"[ERROR] {testhost.dnsname} IP mismatch: {self.lastip} {newip}")
				self.lastip = newip
				self.ipstate = 'Changed'
			return self.ipstate


	hostlist = []
	n = len(sys.argv)
	if n > 2:  # проверяем что аргумент один
		sys.exit("Too many arguments")
	elif n == 1:  # не указан файл с хостами
		sys.exit("No file specified")
	else:  # при наличии пути в аргументе
		hostsfile = sys.argv[1]
	if (os.path.exists(hostsfile)):   # проверяем что путь существует
		with open(hostsfile) as f:
			data = yaml.load(f)
		for host in data['checkhosts']:
			hostlist.append(CheckSite(host))
		while True:
			for testhost in hostlist:
				print("-"*10)
				ipstate = testhost.checkip()
				# if ipstate == 'Changed':
				#     exit()
				sleep(1)
	else:
		sys.exit("File " + hostsfile + " not exists")
	```


## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения.


---

### Как сдавать задания

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
