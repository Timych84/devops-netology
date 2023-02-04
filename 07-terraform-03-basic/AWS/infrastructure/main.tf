provider "aws" {
  region = var.aws_region_name
}

terraform {
  backend "s3" {
    bucket         = "netology-tf-state"
    key            = "netology/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

data "aws_ami" "ubuami" {
  most_recent = true
  owners      = ["amazon"] # AWS
  filter {
    name   = "name"
    values = ["ubuntu/images/*jammy*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}



resource "aws_instance" "test_server" {
  ami           = data.aws_ami.ubuami.id
  instance_type = var.env_settings[terraform.workspace].type
  count         = var.env_settings[terraform.workspace].instances
  tags = {
    Name = "${var.env_settings[terraform.workspace].nameprefix}-${count.index}"
  }
}

resource "aws_instance" "test_server_foreach" {
  ami           = data.aws_ami.ubuami.id
  for_each      = local.instances[terraform.workspace]
  instance_type = var.env_settings[terraform.workspace].type
  tags = {
    Name = each.value.name
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
