provider "aws" {
  region = var.aws_region_name
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
  ami            = data.aws_ami.ubuami.id
  instance_type  = "t2.micro"

  tags = {
    Name = "ExampleTestServerInstance"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "amis" {
  value = data.aws_ami.ubuami.id
}
