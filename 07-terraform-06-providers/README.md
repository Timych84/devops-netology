# Домашнее задание к занятию "6. Написание собственных провайдеров для Terraform."

Бывает, что
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.

## Задача 1.
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда:
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на
гитхабе.

https://github.com/hashicorp/terraform-provider-aws/blob/453a3bf86ca3333e9ccefc9c332a82e08797b1e8/internal/provider/provider.go#L934

https://github.com/hashicorp/terraform-provider-aws/blob/453a3bf86ca3333e9ccefc9c332a82e08797b1e8/internal/provider/provider.go#L417

1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`.
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.


С "name_prefix" (terraform-provider-aws/internal/service/sqs/queue.go):

```go
"name": {
    Type:          schema.TypeString,
    Optional:      true,
    Computed:      true,
    ForceNew:      true,
    ConflictsWith: []string{"name_prefix"},
},
"name_prefix": {
    Type:          schema.TypeString,
    Optional:      true,
    Computed:      true,
    ForceNew:      true,
    ConflictsWith: []string{"name"},
```
* Какая максимальная длина имени?
  - FIFO queue 75, видимо из-за окончания .fifo
  - Standard queue 80

* Какому регулярному выражению должно подчиняться имя?

```go
if fifoQueue {
        re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,75}\.fifo$`)
    } else {
        re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,80}$`)
    }
```
