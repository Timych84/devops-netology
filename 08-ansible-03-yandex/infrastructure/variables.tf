locals {
  instances = {
    stage = {
      server1 = {
        name = "${var.env_settings[terraform.workspace].nameprefix}-fe-0"
      }
    }
    prod = {
      server1 = {
        name = "${var.env_settings[terraform.workspace].nameprefix}-clickhouse-01"
        label = "clickhouse"
      }
      server2 = {
        name = "${var.env_settings[terraform.workspace].nameprefix}-vector-01"
        label = "vector"
      }
      server3 = {
        name = "${var.env_settings[terraform.workspace].nameprefix}-lighthouse-01"
        label = "lighthouse"
      }
    }
  }
}

variable "centos-7-base" {
  default = "fd83i2c8nu5lmo8aodom"
}

variable "zone" {
  default = "ru-central1-a"
}

variable "env_settings" {
  default = {
    prod = {
      instances     = 2
      nameprefix    = "prod-server"
      core_fraction = 20
      cores         = 2
      memory        = 4
      hdd_type      = "network-hdd"
      hdd_size      = "10"
    }
    stage = {
      instances     = 1
      nameprefix    = "stage-server"
      core_fraction = 20
      cores         = 2
      memory        = 4
      hdd_type      = "network-hdd"
      hdd_size      = "20"
    }
  }
}
