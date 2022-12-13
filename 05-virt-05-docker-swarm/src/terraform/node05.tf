resource "yandex_compute_instance" "node05" {
  name                      = "node05"
  zone                      = "ru-central1-a"
  hostname                  = "node05.netology.yc"
  allow_stopping_for_update = true

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.centos-7-base
      name     = "root-node05"
      type     = "network-hdd"
      size     = "40"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.default.id
    nat        = true
    ip_address = "192.168.101.15"
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }


  scheduling_policy {
    preemptible = true
  }

}
