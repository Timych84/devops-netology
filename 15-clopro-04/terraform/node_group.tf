resource "yandex_kubernetes_node_group" "netology-k8s-nodegroup" {
  cluster_id = yandex_kubernetes_cluster.k8s-regional.id
  name       = "netology-k8s-nodegroup"
  instance_template {
    name       = "netology-{instance.short_id}-{instance_group.id}"
    platform_id = "standard-v3"
    network_acceleration_type = "standard"
    network_interface {
      nat                = true
      subnet_ids = [yandex_vpc_subnet.netology-k8s-subnet-a.id]
    }
    resources {
      memory = 4
      cores  = 2
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }
  scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 3
    }
  }
  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }
}
