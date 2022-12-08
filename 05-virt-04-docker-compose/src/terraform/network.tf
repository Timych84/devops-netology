# Network
# resource "yandex_vpc_network" "tim-net" {
#   name = "tim-network"
# }

# resource "yandex_vpc_subnet" "default" {
#   name           = "subnet"
#   zone           = "ru-central1-b"
#   network_id     = yandex_vpc_network.tim-net.id
#   v4_cidr_blocks = ["192.168.101.0/24"]
# }
