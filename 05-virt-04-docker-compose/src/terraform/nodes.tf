resource "yandex_compute_instance" "node01" {
  name                      = "node01"
  platform_id               = "standard-v2"
  zone                      = "ru-central1-b"
  hostname                  = "node01.timych.cloud"
  allow_stopping_for_update = true

  resources {
    core_fraction = 20
    cores  = 2
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = var.centos-7-base
      name     = "root-node01"
      type     = "network-hdd"
      size     = "10"
    }
  }

  network_interface {
    # subnet_id = yandex_vpc_subnet.default.id
    subnet_id = "e2lme62seggvl8kvuorb"
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }

  provisioner "file" {
    source      = "/home/timych/grafana/src"
    destination = "/home/centos"


  }
 connection {
   type        = "ssh"
   host        = yandex_compute_instance.node01.network_interface.0.nat_ip_address
   user        = "centos"
   private_key = file("~/.ssh/id_rsa")
   timeout     = "4m"
 }

}

resource "yandex_compute_instance" "node02" {
  name                      = "node02"
  platform_id               = "standard-v2"
  zone                      = "ru-central1-b"
  hostname                  = "node02.timych.cloud"
  allow_stopping_for_update = true

  resources {
    core_fraction = 20
    cores  = 2
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = var.centos-7-base
      name     = "root-node02"
      type     = "network-hdd"
      size     = "10"
    }
  }

  network_interface {
    # subnet_id = yandex_vpc_subnet.default.id
    subnet_id = "e2lme62seggvl8kvuorb"
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }

  provisioner "file" {
    source      = "/home/timych/grafana/src"
    destination = "/home/centos"


  }
 connection {
   type        = "ssh"
   host        = yandex_compute_instance.node01.network_interface.0.nat_ip_address
   user        = "centos"
   private_key = file("~/.ssh/id_rsa")
   timeout     = "4m"
 }

}
