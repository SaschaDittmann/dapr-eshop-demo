resource "kubernetes_deployment" "orderservice" {
  metadata {
    name = "orderservice"
    labels = {
      app = "orderservice"
    }
  }
  spec {
    replicas = var.replicas_orderservice
    selector {
      match_labels = {
        app = "orderservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "orderservice"
        }
        annotations = {
          "dapr.io/enabled"  = "true"
          "dapr.io/app-id"   = "orderservice"
          "dapr.io/app-port" = "80"
        }
      }
      spec {
        container {
          image             = var.image_orderservice
          name              = "aspnet"
          image_pull_policy = var.image_pull_policy_orderservice
          env {
            name = "ASPNETCORE_ENVIRONMENT"
            value = "${var.enable_aspnet_development ? "Development" : "Production"}"  
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
