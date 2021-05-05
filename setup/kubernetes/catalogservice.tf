resource "kubernetes_deployment" "product_catalog" {
  metadata {
    name = "productcatalog"
    labels = {
      app = "productcatalog"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "productcatalog"
      }
    }
    template {
      metadata {
        labels = {
          app = "productcatalog"
        }
        annotations = {
          "dapr.io/enabled"  = "true"
          "dapr.io/app-id"   = "productcatalog"
          "dapr.io/app-port" = "80"
        }
      }
      spec {
        container {
          image             = var.image_catalog
          name              = "aspnet"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "product_catalog" {
  metadata {
    name = "productcatalog"
    labels = {
      app = "productcatalog"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.product_catalog.metadata.0.labels.app
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
