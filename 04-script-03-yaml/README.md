### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-03-yaml/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```

  Нужно найти и исправить все ошибки, которые допускает наш сервис


```json
{ "info" : "Sample JSON output from our service\t",
"elements" :[
    { "name" : "first",
    "type" : "server",
    "ip" : 7175
    },
    { "name" : "second",
    "type" : "proxy",
    "ip" : "71.78.22.43"
    }
]
}
```


## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

from time import sleep
import dns.resolver
import sys
import yaml
import json
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
            print(f"[ERROR] {self.dnsname} IP mismatch: {self.lastip} {newip}")
            self.lastip = newip
            self.ipstate = 'Changed'
        return self.ipstate, self.lastip


def main():
    hostlist = []
    hostdict = {}
    #hostdict['checkhosts'] = {}
    # Проверяем аргументы
    n = len(sys.argv)
    if n > 4:
        sys.exit("Too many arguments")
    elif n <= 3:
        sys.exit("Too few arguments")
    else:  # при наличии путей в аргументе
        hostsfile = sys.argv[1]
        host_resultfile_yaml = sys.argv[2]
        host_resultfile_json = sys.argv[3]

    if (os.path.exists(hostsfile)):   # проверяем что путь существует
        with open(hostsfile) as f:
            data = yaml.load(f)
        for host in data['checkhosts']:
            hostlist.append(CheckSite(host))
        while True:
            for testhost in hostlist:
                print("-"*10)
                ipresult = testhost.checkip()
                if ipresult[0] in ('New', 'Changed'): #если новые записи или что-то изменилось - перезаписываем файлы
                    hostdict[testhost.dnsname] = ipresult[1]
                    with open(host_resultfile_yaml, 'w') as f:
                        yaml.dump(hostdict, f, explicit_start=True)
                    with open(host_resultfile_json, 'w') as f:
                        json.dump(hostdict, f, indent=2)
                sleep(1)
    else:
        sys.exit("File " + hostsfile + " not exists")


if __name__ == '__main__':
    main()
```

### Вывод скрипта при запуске при тестировании:
```
----------
drive.google.com - 142.250.180.238
----------
mail.google.com - 142.250.180.229
----------
google.com - 142.250.180.238
----------
drive.google.com - 142.250.180.238
----------
mail.google.com - 142.250.180.229
----------
google.com - 142.250.180.238
----------
drive.google.com - 142.250.180.238
----------
[ERROR] mail.google.com IP mismatch: 142.250.180.229 142.250.201.197
----------
[ERROR] google.com IP mismatch: 142.250.180.238 142.251.39.14
----------
drive.google.com - 142.250.180.238
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{
  "drive.google.com": "142.250.180.238",
  "mail.google.com": "142.250.201.197",
  "google.com": "142.251.39.14"
}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
---
drive.google.com: 142.250.180.238
google.com: 142.251.39.14
mail.google.com: 142.250.201.197
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
import sys
import yaml
import json


def valid_file(filename):
    """Проверяет файл на наличие yaml или json контента\n
    Возвращает\n
    - является ли содержимое yaml и/или json (is_yaml, is_json)\n
    - ошибку (error)\n
    - содержимое в виде словаря (content)
    """
    error = None
    content = None
    try:
        with open(filename) as f:
            content = yaml.safe_load(f)
        is_yaml = True
    except Exception as e:
        error = e
        is_yaml = False
    try:
        with open(filename) as f:
            content = json.load(f)
        is_json = True
    except Exception as e:
        error = e
        is_json = False

    return {"is_yaml": is_yaml,
            "is_json": is_json,
            "error": error,
            "content": content, }


def write_yaml(filename, content):
    """Записывает содержимое словаря(content) в файл(filename) в формате yaml
    """
    print(f"Writing yaml content to {filename}")
    with open(filename, 'w') as f:
        yaml.dump(content, f, explicit_start=True)


def write_json(filename, content):
    """Записывает содержимое словаря(content) в файл(filename) в формате json
    """
    print(f"Writing json content to {filename}")
    with open(filename, 'w') as f:
        json.dump(content, f, indent=2)


def get_file_extension(filename):
    """Определяет расширение файла(filename).\n
    Возвращает:
    - расширение файла
    - имя файла без расширения
    """
    infile_splitted = filename.split(".")
    if infile_splitted[-1] in ("yaml", "yml"):
        file_extension = "yaml"
    elif infile_splitted[-1] == "json":
        file_extension = "json"
    else:
        print("Wrong file extension!")
        exit()
    return file_extension, infile_splitted[:-1]


def outfile_namegen(infile, true_format):
    """Генерирует имя выходного файла на основании:
    - входного файла(infile)
    - формата содержимого(true_format)\n
    Возвращает:
    - имя файла
    """
    file_extension = get_file_extension(infile)
    if true_format == "yaml":
        if file_extension[0] == "yaml":
            outfile = file_extension[1][0] + ".json"
        if file_extension[0] == "json":
            outfile = file_extension[1][0] + "_from_yaml_inside_json.json"
    if true_format == "json":
        if file_extension[0] == "json":
            outfile = file_extension[1][0] + ".yaml"
        if file_extension[0] == "yaml":
            outfile = file_extension[1][0] + "_from_json_inside_yaml.yaml"
    return outfile


def checkargs(n):
    """Проверка необходимого количества аргументов
    """
    arg_count = len(sys.argv)
    if arg_count > n:
        sys.exit("Too many arguments")
    elif arg_count <= (n - 1):
        sys.exit("Too few arguments")
    else:  # при наличии путей в аргументе
        return True


def main():
    checkargs(2)
    infile = sys.argv[1]
    result = valid_file(infile)
    #  print(file_extension)
    if not result["is_yaml"] and not (result["is_json"]):  # ошибка в файле
        print(result["error"])
        exit()
    if result["is_yaml"] and not (result["is_json"]):  # файл yaml
        print("Detected yaml content")
        write_json(outfile_namegen(infile, "yaml"), result['content'])
    else:  # файл json
        print("Detected json/yaml content")
        write_yaml(outfile_namegen(infile, "json"), result['content'])


if __name__ == '__main__':
    main()
```

### Пример работы скрипта 1 :

```bash
python3 yaml_json_converter.py test.yaml
Detected yaml content
Writing json content to test.json
```
test.yaml:

```yml
---
drive.google.com: 142.250.180.231
google.com: 142.251.39.14
mail.google.com: 142.250.201.197
```
test.json:

```json
{
  "drive.google.com": "142.250.180.231",
  "google.com": "142.251.39.14",
  "mail.google.com": "142.250.201.197"
}
```

### Пример работы скрипта 2 :

```bash
python3 yaml_json_converter.py test.yaml
Detected json/yaml content
Writing yaml content to test_from_json_inside_yaml.yaml
```
test.yaml:

```json
{
  "drive.google.com": "142.250.180.231",
  "google.com": "142.251.39.14",
  "mail.google.com": "142.250.201.197"
}

```
test_from_json_inside_yaml.yaml:

```yaml
---
drive.google.com: 142.250.180.231
google.com: 142.251.39.14
mail.google.com: 142.250.201.197

```
