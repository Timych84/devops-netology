resource "yandex_iam_service_account" "netology-k8s-sa" {
  name        = "netology-k8s-sa"
  description = "K8S regional service account"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.FOLDER_ID
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.netology-k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = var.FOLDER_ID
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.netology-k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.FOLDER_ID
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.netology-k8s-sa.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.FOLDER_ID
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.netology-k8s-sa.id}"
}

resource "yandex_vpc_security_group" "k8s-main-sg" {
  name        = "k8s-main-sg"
  description = "Правила группы обеспечивают базовую работоспособность кластера Managed Service for Kubernetes. Примените ее к кластеру Managed Service for Kubernetes и группам узлов."
  network_id  = yandex_vpc_network.netology_net.id
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
    v4_cidr_blocks    = concat(yandex_vpc_subnet.netology-k8s-subnet-a.v4_cidr_blocks, yandex_vpc_subnet.netology-k8s-subnet-b.v4_cidr_blocks, yandex_vpc_subnet.netology-k8s-subnet-c.v4_cidr_blocks)
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol          = "TCP"
    description       = "Правило для доступа к K8S API"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 443
  }

  ingress {
    protocol          = "TCP"
    description       = "Правило для доступа к K8S API"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 6443
  }
}



resource "yandex_vpc_security_group" "mysql-sg" {
  name       = "mysql-sg"
  network_id = yandex_vpc_network.netology_net.id

  ingress {
    description    = "MySQL"
    port           = 3306
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}
