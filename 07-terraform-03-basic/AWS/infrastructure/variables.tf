variable "aws_region_name" {
  default = "eu-central-1"
}

locals {
  instances = {
    stage = {
      server1 = {
        name = "${var.env_settings[terraform.workspace].nameprefix}-fe-0"
      }
    }
    prod = {
      server1 = {
        name = "${var.env_settings[terraform.workspace].nameprefix}-fe-0"
      }
      server2 = {
        name = "${var.env_settings[terraform.workspace].nameprefix}-fe-1"
      }
    }
  }
}


variable "env_settings" {
  default = {
    prod = {
      instances  = 2
      nameprefix = "prod-server"
      type       = "t2.small"
    }
    stage = {
      instances  = 1
      nameprefix = "stage-server"
      type       = "t2.micro"
    }
  }
}
