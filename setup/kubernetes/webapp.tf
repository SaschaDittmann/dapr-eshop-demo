resource "kubernetes_deployment" "webapp" {
  metadata {
    name = "webapp"
    labels = {
      app = "webapp"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "webapp"
      }
    }
    template {
      metadata {
        labels = {
          app = "webapp"
        }
        annotations = {
          "dapr.io/enabled"  = "true"
          "dapr.io/app-id"   = "eshop"
          "dapr.io/app-port" = "80"
        }
      }
      spec {
        container {
          image             = var.image_webapp
          name              = "aspnet"
          image_pull_policy = "Always"
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

resource "kubernetes_service" "webapp" {
  metadata {
    name = "webapp"
    labels = {
      app = "webapp"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.webapp.metadata.0.labels.app
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
