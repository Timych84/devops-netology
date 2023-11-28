terraform {


  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "netology-tf-state"
    region                      = "ru-central1"
    key                         = "netology/netology-15-02.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  zone = var.zone
}

resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.FOLDER_ID
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"
}


resource "yandex_compute_instance_group" "ig-1" {
  name               = "nlb-vm-group"
  folder_id          = var.FOLDER_ID
  service_account_id = "${yandex_iam_service_account.ig-sa.id}"

  instance_template {
    platform_id = var.ycinstance.platform_id
    hostname    = "netology-test-{instance.zone_id}-{instance.index}"
    resources {
      core_fraction = var.ycinstance.core_fraction
      memory        = var.ycinstance.memory
      cores         = var.ycinstance.cores
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.ycinstance.image_id
        type     = var.ycinstance.hdd_type
        size     = var.ycinstance.hdd_size
      }
    }

    network_interface {
      network_id = yandex_vpc_network.default.id
      subnet_ids = ["${yandex_vpc_subnet.private.id}"]
      nat        = var.ycinstance.nat
    }

    metadata = {
      user-data =  "#cloud-config\nusers:\n  - name: ${var.ycinstance.username}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${var.ycinstance.ssh_key}")}\nwrite_files:\n  - path: '/var/www/html/index.nginx-debian.html'\n    content: |\n        ${indent(8,file("./index.html"))}\n    permissions: '0644'\n    defer: true\nruncmd:\n  - hostname > /root/hello.txt\n  - sed -i \"s/Your Server Name Here/$(hostname)/g\" /var/www/html/index.nginx-debian.html\n  - sed -i ${"\"s/--imagelink--/https:\\/\\/${yandex_storage_bucket.test.bucket_domain_name}\\/${yandex_storage_object.index-html.id}/g\""} /var/www/html/index.nginx-debian.html\n"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    zones = var.ig-1-zones
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name = "nlb-tg"
  }
}

resource "yandex_lb_network_load_balancer" "netology" {
  name = "nlb-1"
  listener {
    name = "nlb-listener"
    port = 80
  }
  attached_target_group {
    target_group_id = "${yandex_compute_instance_group.ig-1.load_balancer.0.target_group_id}"
    healthcheck {
      name                = "health-check-1"
      unhealthy_threshold = 5
      healthy_threshold   = 5
      http_options {
        path = "/"
        port = 80
      }
    }
  }
}
