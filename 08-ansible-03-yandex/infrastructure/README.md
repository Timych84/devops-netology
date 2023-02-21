# Terraform configuration for 08-ansible-03-yandex
Данная конфигурация для workspace "prod" создает 3 инстанса на Yandex Cloud для дальнейшего развертывания на них Clickhouse, Vector и Lighthouse.

После apply в каталоге "../playbook/inventory/prod_tf.yml" создается inventory для Ansible вида:

```yml
---
clickhouse:
  hosts:
    prod-server-clickhouse-01:
      ansible_host: xxx.xxx.xxx.xxx
vector:
  hosts:
    prod-server-vector-01:
      ansible_host: xxx.xxx.xxx.xxx
lighthouse:
  hosts:
    prod-server-lighthouse-01:
      ansible_host: xxx.xxx.xxx.xxx
```
