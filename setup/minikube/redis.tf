resource "kubernetes_config_map" "redis" {
  metadata {
    name = "redis-config"
  }

  data = {
    redis-config = <<EOF
      maxmemory 2mb
      maxmemory-policy allkeys-lru
    EOF
  }
}

resource "kubernetes_pod" "redis" {
  metadata {
    name = "redis-pod"
    labels = {
      "app" = "redis"
    }
  }
  spec {
    container {
      image = "redis:5.0.4"
      name  = "redis"
      env {
        name  = "MASTER"
        value = "true"
      }
      port {
        container_port = 6379
      }
      resources {
        limits = {
          "cpu" = "0.1"
        }
      }
      volume_mount {
        mount_path = "/redis-master-data"
        name       = "data"
      }
      volume_mount {
        mount_path = "/redis-master"
        name       = "config"
      }
    }
    volume {
      name = "data"
      empty_dir {
      }
    }
    volume {
      name = "config"
      config_map {
        name = kubernetes_config_map.redis.metadata.0.name
        items {
          key  = "redis-config"
          path = "redis.conf"
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
  }
  spec {
    selector = {
      app = kubernetes_pod.redis.metadata.0.labels.app
    }
    port {
      port        = 6379
      target_port = 6379
    }
  }
}
