variable "zone" {
  default = "ru-central1-a"
}

variable "ycinstances" {
  default = {
    nat-instance = {
      name          = "nat-instance"
      username      = "nat-user"
      image_id      = "fd8v8e1pus04ru8ibe12"
      core_fraction = 20
      cores         = 2
      memory        = 4
      hdd_type      = "network-hdd"
      hdd_size      = "10"
      subnet        = "public"
      ipaddress     = "192.168.10.254"
      nat           = true
      ssh_key       = "~/.ssh/id_rsa.pub"
    }
    public-vm = {
      name          = "public-vm"
      username      = "vm-user"
      image_id      = "fd8m3j9ott9u69hks0gg"
      core_fraction = 20
      cores         = 2
      memory        = 2
      hdd_type      = "network-hdd"
      hdd_size      = "20"
      subnet        = "public"
      nat           = true
      ssh_key       = "~/.ssh/id_rsa.pub"
    }
    private-vm = {
      name          = "private-vm"
      username      = "vm-user"
      image_id      = "fd8m3j9ott9u69hks0gg"
      core_fraction = 20
      cores         = 2
      memory        = 2
      hdd_type      = "network-hdd"
      hdd_size      = "20"
      subnet        = "private"
      nat           = false
      ssh_key       = "~/.ssh/id_rsa.pub"
    }
  }
}
