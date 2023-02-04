terraform {


  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "netology-tf-state"
    region                      = "ru-central1"
    key                         = "netology/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  zone = var.zone
}
resource "yandex_compute_instance" "test_server" {
  count                     = var.env_settings[terraform.workspace].instances
  name                      = "${var.env_settings[terraform.workspace].nameprefix}-${count.index}"
  zone                      = var.zone
  hostname                  = "${var.env_settings[terraform.workspace].nameprefix}-${count.index}"
  allow_stopping_for_update = true

  resources {
    core_fraction = var.env_settings[terraform.workspace].core_fraction
    cores         = var.env_settings[terraform.workspace].cores
    memory        = var.env_settings[terraform.workspace].memory
  }

  boot_disk {
    initialize_params {
      image_id = var.centos-7-base
      name     = "${var.env_settings[terraform.workspace].nameprefix}-${count.index}"
      type     = var.env_settings[terraform.workspace].hdd_type
      size     = var.env_settings[terraform.workspace].hdd_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat        = true
    # ip_address = "192.168.101.11"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "test_server_foreach" {
  for_each      = local.instances[terraform.workspace]
  name                      = each.value.name
  zone                      = var.zone
  hostname                  = each.value.name
  allow_stopping_for_update = true

  resources {
    core_fraction = var.env_settings[terraform.workspace].core_fraction
    cores         = var.env_settings[terraform.workspace].cores
    memory        = var.env_settings[terraform.workspace].memory
  }

  boot_disk {
    initialize_params {
      image_id = var.centos-7-base
      name     = each.value.name
      type     = var.env_settings[terraform.workspace].hdd_type
      size     = var.env_settings[terraform.workspace].hdd_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat        = true
    # ip_address = "192.168.101.11"
  }

  scheduling_policy {
    preemptible = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
