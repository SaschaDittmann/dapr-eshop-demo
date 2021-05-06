resource "kubernetes_deployment" "product_catalog" {
  metadata {
    name = "productcatalog"
    labels = {
      app = "productcatalog"
    }
  }
  spec {
    replicas = var.replicas_catalog
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
          image_pull_policy = var.image_pull_policy_catalog
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
