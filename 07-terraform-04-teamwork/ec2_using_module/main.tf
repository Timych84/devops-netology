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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "ids" {
   filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_groups" "sgs" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "test-instance"

  ami                    = data.aws_ami.ubuami.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = data.aws_security_groups.sgs.ids
  subnet_id              = data.aws_subnets.ids.ids[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
