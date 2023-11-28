output "load_balancer_public_ip" {
  description = "Private IP addresses"
  value = try("${[for s in yandex_lb_network_load_balancer.netology.listener: s.external_address_spec.*.address][0][0]}")
}


output "instance_group_masters_private_ips" {
  description = "Private IP addresses"
  value = yandex_compute_instance_group.ig-1.instances.*.network_interface.0.ip_address
}

output "objpath" {
  description = "objpath"
  value = "${yandex_storage_bucket.test.bucket_domain_name}/${yandex_storage_object.index-html.id}"
}
