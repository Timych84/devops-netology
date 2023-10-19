# Домашнее задание к занятию «Управление доступом»

### Цель задания

В тестовой среде Kubernetes нужно предоставить ограниченный доступ пользователю.

------

### Чеклист готовности к домашнему заданию

1. Установлено k8s-решение, например MicroK8S.
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым github-репозиторием.

------

### Инструменты / дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) RBAC.
2. [Пользователи и авторизация RBAC в Kubernetes](https://habr.com/ru/company/flant/blog/470503/).
3. [RBAC with Kubernetes in Minikube](https://medium.com/@HoussemDellai/rbac-with-kubernetes-in-minikube-4deed658ea7b).

------

### Задание 1. Создайте конфигурацию для подключения пользователя

1. Создайте и подпишите SSL-сертификат для подключения к кластеру.
2. Настройте конфигурационный файл kubectl для подключения.
3. Создайте роли и все необходимые настройки для пользователя.
4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).
5. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.

------

### Решение


1. Создание "пользователя" и настройка kubectl config

    ```bash
    openssl genrsa -out netology.key 2048
    openssl req -new -key netology.key -out netology.csr -subj "/CN=netology_user/O=netology"
    openssl x509 -req -in netology.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out netology.crt -days 365
    ```
    Далее копируем на машину откуда будем подключаться файлы:
   - ca.crt
   - netology.crt
   - netology.key

    Настраиваем конифгурацию kubectl:


    ```bash
    kubectl config --kubeconfig=netology-config set-cluster test-cluster --server=https://192.168.171.101:6443 --certificate-authority=ca.crt
    Cluster "test-cluster" set.

    kubectl config --kubeconfig=netology-config set-credentials netology_user --client-key=netology.key --client-certificate=netology.crt --embed-certs=tru
    e
    User "netology_user" set.

    kubectl config --kubeconfig=netology-config set-context netology-context --cluster=test-cluster --namespace=netology --user=netology_user
    Context "netology-context" created.

    kubectl config --kubeconfig=netology-config use-context netology-context
    Switched to context "netology-context".

    timych@timych-ubu2:~/kuber-homeworks-2.4$ kubectl --kubeconfig=netology-config config view
    ```
    Конфигурация kubectl:
    ```yml
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority: ca.crt
        server: https://192.168.171.101:6443
      name: test-cluster
    contexts:
    - context:
        cluster: test-cluster
        namespace: netology
        user: netology_user
      name: netology-context
    current-context: netology-context
    kind: Config
    preferences: {}
    users:
    - name: netology_user
      user:
        client-certificate-data: DATA+OMITTED
        client-key-data: DATA+OMITTED
    ```
1. Создаем объекты в k8s
   1. Манифест Role
       ```yml
       apiVersion: rbac.authorization.k8s.io/v1
       kind: Role
       metadata:
         namespace: netology
         name: pod-log-n-describe
       rules:
       - apiGroups: [""]
         resources: ["pods","pods/log"]
         verbs: ["get","list"] #Для выполнения задания достаточно только get, добавил list для возможности получения списка подов```
   2. Манифест RoleBinding
       ```yml
       apiVersion: rbac.authorization.k8s.io/v1
       kind: RoleBinding
       metadata:
         name: pod-log-n-describe
         namespace: netology
       subjects:
       - kind: User
         name: netology_user
         apiGroup: rbac.authorization.k8s.io
       roleRef:
         kind: Role
         name: pod-log-n-describe
         apiGroup: rbac.authorization.k8s.io
       ```
       </details>

1. Проверяем:
    ```bash
    kubectl --kubeconfig=netology-config get pods
        NAME                                  READY   STATUS    RESTARTS        AGE
        netology-deployment-c59d75c46-7cggq   1/1     Running   6 (2d21h ago)   65d
    kubectl --kubeconfig=netology-config get pod netology-deployment-c59d75c46-7cggq
        NAME                                  READY   STATUS    RESTARTS        AGE
        netology-deployment-c59d75c46-7cggq   1/1     Running   6 (2d21h ago)   65d
    kubectl --kubeconfig=netology-config logs netology-deployment-c59d75c46-7cggq
        The directory /usr/share/nginx/html is not mounted.
        Therefore, over-writing the default index.html file with some useful information:
        WBITT Network MultiTool (with NGINX) - netology-deployment-c59d75c46-7cggq - 10.233.74.82 - HTTP: 8080 , HTTPS: 11443 . (Formerly praqma/network-multitool)
        Replacing default HTTP port (80) with the value specified by the user - (HTTP_PORT: 8080).
        Replacing default HTTPS port (443) with the value specified by the user - (HTTPS_PORT: 11443).
    ```

1. Ссылки:

    [Манифесты](https://github.com/Timych84/devops-netology/blob/main/kuber-homeworks-2.4/manifest/)





### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

------
