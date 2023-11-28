variable "zone" {
  default = "ru-central1-a"
}

variable "ig-1-zones" {
  default = ["ru-central1-a"]
}

variable "FOLDER_ID" {
    type        = string
    description = "ENV Variable FOLDER_ID"
}

variable "ACCESS_KEY" {
    type        = string
    description = "ENV Variable ACCESS_KEY"
}

variable "SECRET_KEY" {
    type        = string
    description = "ENV Variable SECRET_KEY"
    sensitive = true
}

variable "ycinstance" {
  default = {
      name          = "nat-instance"
      username      = "vm-user"
      image_id      = "fd8b939lr87it9flb468"
      platform_id   = "standard-v1"
      core_fraction = 20
      cores         = 2
      memory        = 4
      hdd_type      = "network-hdd"
      hdd_size      = "10"
      nat           = false
      ssh_key       = "~/.ssh/id_rsa.pub"
      ssh_pr_key    = "~/.ssh/id_rsa"
  }
}
