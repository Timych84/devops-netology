resource "yandex_vpc_network" "netology_net" {
  name = "netology_net"
}

resource "yandex_vpc_subnet" "netology-mysql-subnet-a" {
  name             = "netology-mysql-subnet-a"
  zone             = "ru-central1-a"
  network_id       = yandex_vpc_network.netology_net.id
  v4_cidr_blocks   = ["10.3.0.0/24"]
}

resource "yandex_vpc_subnet" "netology-mysql-subnet-b" {
  name             = "netology-mysql-subnet-b"
  zone             = "ru-central1-b"
  network_id       = yandex_vpc_network.netology_net.id
  v4_cidr_blocks   = ["10.4.0.0/24"]
}


resource "yandex_vpc_subnet" "netology-k8s-subnet-a" {
  name             = "netology-k8s-subnet-a"
  zone             = "ru-central1-a"
  network_id       = yandex_vpc_network.netology_net.id
  v4_cidr_blocks   = ["10.5.0.0/24"]
}

resource "yandex_vpc_subnet" "netology-k8s-subnet-b" {
  name             = "netology-k8s-subnet-b"
  zone             = "ru-central1-b"
  network_id       = yandex_vpc_network.netology_net.id
  v4_cidr_blocks   = ["10.6.0.0/24"]
}

resource "yandex_vpc_subnet" "netology-k8s-subnet-c" {
  name             = "netology-k8s-subnet-c"
  zone             = "ru-central1-c"
  network_id       = yandex_vpc_network.netology_net.id
  v4_cidr_blocks   = ["10.7.0.0/24"]
}
