locals {
  instance_details = {
    for key, instance in yandex_compute_instance.netology_instances :
    key => {
      name = instance.name
      public_ip   = instance.network_interface.0.nat_ip_address
      private_ip   = instance.network_interface.0.ip_address
    }
  }
}


output "instance_details" {
  value = local.instance_details
}
