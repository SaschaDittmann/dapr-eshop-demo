resource "random_password" "mysql_admin" {
  length  = 12
  special = false
}

locals {
  mysql_admin_password = var.mysql_admin_password != "" ? var.mysql_admin_password : random_password.mysql_admin.result
}

resource "kubernetes_secret" "mysql" {
  metadata {
    name = "mysql-pass"
  }
  data = {
    password = local.mysql_admin_password
  }
  type = "Opaque"
}

resource "kubernetes_persistent_volume_claim" "mysql" {
  metadata {
    name = "mysql-pvc"
    labels = {
      "app" = "mysql"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      "app" = "mysql"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        name = "mysql"
        labels = {
          "app" = "mysql"
        }
      }
      spec {
        container {
          image = "mysql:5.7"
          name  = "mysql"
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql.metadata.0.name
                key  = "password"
              }
            }
          }
          port {
            container_port = 3306
            name           = "mysql"
          }
          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql"
  }
  spec {
    selector = {
      app = kubernetes_deployment.mysql.metadata.0.labels.app
    }
    port {
      port        = 3306
      target_port = 3306
    }
  }
}

resource "null_resource" "setup_database" {
  provisioner "local-exec" {
    command = <<-EOT
      mysql_pod=$(kubectl get pods | grep mysql | awk '{print $1}')
      kubectl exec $mysql_pod -- mysql -u root --password='${local.mysql_admin_password}' -e "create database catalog;"
    EOT
  }

  depends_on = [
    kubernetes_deployment.mysql
  ]
}
