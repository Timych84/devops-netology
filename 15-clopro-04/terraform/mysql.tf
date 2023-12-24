resource "yandex_mdb_mysql_cluster" "netology-mysql-cl" {
  name                = "netology-mysql-cl"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.netology_net.id
  version             = "8.0"
  security_group_ids  = [ yandex_vpc_security_group.mysql-sg.id ]
  deletion_protection = true
  maintenance_window {
    type = "ANYTIME"
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-hdd"
    disk_size          = 20
  }

  host {
    zone             = "ru-central1-a"
    name             = "netology-mysql-a"
    subnet_id        = yandex_vpc_subnet.netology-mysql-subnet-a.id
    assign_public_ip = true
  }

  host {
    zone             = "ru-central1-b"
    name             = "netology-mysql-b"
    subnet_id        = yandex_vpc_subnet.netology-mysql-subnet-b.id
    assign_public_ip = true
    backup_priority  = 10
  }
}

resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.netology-mysql-cl.id
  name       = "netology_db"
}

resource "yandex_mdb_mysql_user" "netology" {
  cluster_id = yandex_mdb_mysql_cluster.netology-mysql-cl.id
  name       = "netology"
  password   = var.NETOLOGY_DBPASS
  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }
}
