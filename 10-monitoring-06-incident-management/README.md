# Домашнее задание к занятию 17 «Инцидент-менеджмент»

## Основная часть

Составьте постмортем на основе реального сбоя системы GitHub в 2018 году.

Информация о сбое:

* [в виде краткой выжимки на русском языке](https://habr.com/ru/post/427301/);
* [развёрнуто на английском языке](https://github.blog/2018-10-30-oct21-post-incident-analysis/).


### Решение


|       Постмортем            |       |
|:--------------------------  |:----- |
| Краткое описание инцидента  | 21.10.2017 в 22.52 при замене оптического оборудования произошла кратковременная потеря связи между площадками, которая привела к рассогласованию данных в базах данных на 24 часа 11 минут.
| Предшествующие события      | Проведение работ по замене неисправного 100G оптического оборудования |
| Причина инцидента           | Неправильная конфигурация Orchestrator, неправильная работа с репликами БД размещенными на удаленных друг от друга площадках |
| Воздействие                 | Из-за кратковременного пропадания связи произошло рассогласование данных между площадками, небольшая часть данных успела записаться на одной площадке, и большая часть - на другой. Проблемы с отображением информации у пользователей, не работал функционал Webhook и GitHub Pages|
| Обнаружение                 | Ошибки от системы мониторинга |
| Реакция                     | При обнаружении ошибки принято решение о приостановке возможности внесения изменений, начале восстановления из резервных копий и дальнейшей обработке неконсистентных данных  |
| Восстановление              | Принято решение о приоритете в сохранности данных, произведено восстановление баз данных из резервных копий в облаке, восстановлена синхронизация, разобраны неконсистетные данные |
| Таймлайн                    | 22:52 После замены оборудования произошло разделение сети и начался процесс нового лидера с помощью Orchestrator |
|								| 22:54 Сообщения об ошибках от системы мониторинга. |
| 					        | 23:07  Ручная блокировка внутренних инструментов развертывания для предотвращения дополнительных изменения |
| 					        | 23:13 Исследование инженерами баз данных проблемы, определение требуемых действий |
| 					        | 23:19 Из-за того что данные были записыаны на обе площадки и их требуется сохранить, принято решение о приоритете сохранности данных над деградацией сервиса |
| 					        | 00:05 Разработка плана восстановления согласованности данных с помощью воостановления резервных копий и синхронизации реплик |
| 					        | 00:41 Начало процесса восстановления, поиск способов ускорить процесс |
| 					        | 06:51 Завершение процесса восстановления и начала репликации данных |
| 					        | 07:46 Публикация в блоге сообщения о проблеме, публикация ранее была затруднена из-за сбоев в работе GitHub Pages |
| 					        | 11:12 Все базы данных были восстановлены, при этом наблюдаются проблемы с репликацией данных, что приводило к тому, что пользователи видели неконсистентные данные |
| 					        | 13:15 Достигнут пик траффика, продолжался рост задержек репликации, были предоставлены дополнительные реплики для чтения|
| 					        | 16:24 Реплики были синхронизированы, был произведен возврат на исходную топологию |
| 					        | 16:45 Решение проблем с накопившимся backlog задач, увеличение TTL, чтобы задачи не сбрасывались из-за долгого ожидания.  |
| 					        | 23:03 Все ожидающие задачи были выполнены, статус сайта - зеленый |
| Последующие действия        |1. Обработка неконсистентных данных из логов БД |
| 					        |2. Изменена конфигурация оркестартора для соответствия топологии, система не была подготовлена к работе на разнесенных по территории страны площадках |
| 					        |3. Ускорен переход на новый механизм оповещения |
| 					        |4. Продолжение начатьх процессов по переходу на работу в режиме active/active/active, позволяющую выдерживать отказ целого датацентра |
---


### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---