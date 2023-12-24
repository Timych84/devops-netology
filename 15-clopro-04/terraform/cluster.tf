locals {
  cloud_id    = "b1gq90dgh25********"
  folder_id   = "b1gia87mbaom********"
  k8s_version = "1.25"
  sa_name     = "myaccount"
}

resource "yandex_kubernetes_cluster" "k8s-regional" {
  name       = "netology-k8s-cluster"
  network_id = yandex_vpc_network.netology_net.id
  master {
    version = local.k8s_version
    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.netology-k8s-subnet-a.zone
        subnet_id = yandex_vpc_subnet.netology-k8s-subnet-a.id
      }
      location {
        zone      = yandex_vpc_subnet.netology-k8s-subnet-b.zone
        subnet_id = yandex_vpc_subnet.netology-k8s-subnet-b.id
      }
      location {
        zone      = yandex_vpc_subnet.netology-k8s-subnet-c.zone
        subnet_id = yandex_vpc_subnet.netology-k8s-subnet-c.id
      }
    }
    public_ip = true
    # security_group_ids = [yandex_vpc_security_group.k8s-main-sg.id]
  }

  service_account_id      = yandex_iam_service_account.netology-k8s-sa.id
  node_service_account_id = yandex_iam_service_account.netology-k8s-sa.id
  depends_on = [
    yandex_iam_service_account.netology-k8s-sa,
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.editor,
    yandex_kms_symmetric_key.kms-key,
    yandex_vpc_security_group.k8s-main-sg
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}
