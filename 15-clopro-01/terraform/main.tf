terraform {


  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "netology-tf-state"
    region                      = "ru-central1"
    key                         = "netology/netology.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  zone = var.zone
}

resource "yandex_compute_instance" "netology_instances" {
  for_each                  = var.ycinstances
  name                      = each.value.name
  zone                      = var.zone
  hostname                  = each.value.name
  allow_stopping_for_update = true

  resources {
    core_fraction = each.value.core_fraction
    cores         = each.value.cores
    memory        = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = each.value.image_id
      name     = each.value.name
      type     = each.value.hdd_type
      size     = each.value.hdd_size
    }
  }

  network_interface {
    subnet_id  = var.ycinstances[each.key].subnet == "private" ? yandex_vpc_subnet.private.id : yandex_vpc_subnet.public.id
    nat        = each.value.nat
    ip_address = try(each.value.ipaddress, null)
  }

  scheduling_policy {
    preemptible = true
  }
  lifecycle {
    create_before_destroy = true
  }
  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${each.value.username}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${each.value.ssh_key}")}"
  }
}
