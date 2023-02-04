output "amis" {
  value = data.aws_ami.ubuami.id
}

output "Servers_by_count" {
  value = length(aws_instance.test_server)
}

output "Servers_by_count_internal_ip_address" {
  value = aws_instance.test_server[*].private_ip
}

output "Servers_by_count_external_ip_address" {
  value = aws_instance.test_server[*].public_ip
}

output "Servers_by_foreach" {
  value = length(aws_instance.test_server_foreach)
}

output "Servers_by_foreach_internal_ip_address" {
  value = [for inst in aws_instance.test_server_foreach : inst.private_ip]
}

output "Servers_by_foreach_external_ip_address" {
  value = [for inst in aws_instance.test_server_foreach : inst.public_ip]
}
