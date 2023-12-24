locals {
  mysql_host      = "rc1a-t9y4p3om97e10rym.mdb.yandexcloud.net"
  mysql_port      = 3306
  phpmyadmin_port = 80
  k8s_namespace   = "netology"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "yc-netology-k8s-cluster"
}

resource "kubernetes_namespace" "netology" {
  metadata {
    name = local.k8s_namespace
  }
}

resource "kubernetes_deployment" "phpmyadmin-01" {
  metadata {
    name = "phpmyadmin"
    labels = {
      app = "phpmyadmin"
    }
    namespace = local.k8s_namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "phpmyadmin"
      }
    }

    template {
      metadata {
        labels = {
          app = "phpmyadmin"
        }
      }

      spec {
        container {
          image = "phpmyadmin/phpmyadmin"
          name  = "phpmyadmin"
          env {
            name = "PMA_HOST"
            value = local.mysql_host
          }
          env {
            name = "PMA_PORT"
            value = local.mysql_port
          }
          port {
            container_port = local.phpmyadmin_port
            name = "phpmyadmin"
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "phpmyadmin" {
  metadata {
    name = "phpmyadmin"
    namespace = local.k8s_namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment.phpmyadmin-01.spec.0.template.0.metadata[0].labels.app
    }
    port {
      port        = 8080
      target_port = local.phpmyadmin_port
    }

    type = "LoadBalancer"
  }
}
