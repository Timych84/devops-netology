output "Servers_by_count" {
  value = length(yandex_compute_instance.test_server)
}

output "Servers_by_count_internal_ip_address" {
  value = yandex_compute_instance.test_server[*].network_interface.0.ip_address
}

output "Servers_by_count_external_ip_address" {
  value = yandex_compute_instance.test_server[*].network_interface.0.nat_ip_address
}


output "Servers_by_foreach" {
  value = length(yandex_compute_instance.test_server_foreach)
}

output "Servers_by_foreach_internal_ip_address" {
  value = [for inst in yandex_compute_instance.test_server_foreach : inst.network_interface.0.ip_address]
}

output "Servers_by_foreach_external_ip_address" {
  value = [for inst in yandex_compute_instance.test_server_foreach : inst.network_interface.0.nat_ip_address]
}

# output "account_id" {
#   value = data.aws_caller_identity.current.account_id
# }

# output "caller_arn" {
#   value = data.aws_caller_identity.current.arn
# }

# output "user_id" {
#   value = data.aws_caller_identity.current.user_id
# }

# output "region_name" {
#   value = data.aws_region.current.name
# }

# output "private_ip" {
#   value = aws_instance.test_server[*].private_ip
# }

# output "subnet_id" {
#   value = aws_instance.test_server[*].subnet_id
# }
