resource "kubernetes_deployment" "webshop" {
  metadata {
    name = "webshop"
    labels = {
      app = "webshop"
    }
  }
  spec {
    replicas = var.replicas_webshop
    selector {
      match_labels = {
        app = "webshop"
      }
    }
    template {
      metadata {
        labels = {
          app = "webshop"
        }
        annotations = {
          "dapr.io/enabled"  = "true"
          "dapr.io/app-id"   = "webshop"
          "dapr.io/app-port" = "80"
        }
      }
      spec {
        container {
          image             = var.image_webshop
          name              = "aspnet"
          image_pull_policy = var.image_pull_policy_webshop
          port {
            container_port = 80
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "webshop" {
  metadata {
    name = "webshop"
    labels = {
      app = "webshop"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.webshop.metadata.0.labels.app
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
