output "amis" {
  value = data.aws_ami.ubuami.id
}

output "vpc" {
  value = data.aws_vpc.default.id
}

output "subnet" {
  value = data.aws_subnets.ids.id
}

output "sg" {
  value = data.aws_security_groups.sgs.ids
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "region_name" {
  value = data.aws_region.current.name
}

output "private_ip" {
  value = module.ec2_instance.private_ip
}
