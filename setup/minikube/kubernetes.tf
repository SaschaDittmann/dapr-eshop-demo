resource "null_resource" "build_images" {
  provisioner "local-exec" {
    command = <<-EOT
      eval $(minikube docker-env)
      docker build -t dapr-eshop-webshop:latest ../../WebShop
      docker build -t dapr-eshop-catalog:latest ../../CatalogService
      docker build -t dapr-eshop-orderservice:latest ../../OrderService
    EOT
  }
}

resource "null_resource" "install_dapr" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl config use-context 'minikube'
      dapr init -k --wait
      kubectl apply -f components/.
    EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl config use-context 'minikube'
      dapr uninstall -k
      kubectl delete -f components/.
    EOT
  }
}

resource "kubernetes_secret" "catalog" {
  metadata {
    name = "catalog-mysql"
  }
  data = {
    url = "root:${local.mysql_admin_password}@tcp(${kubernetes_service.mysql.metadata.0.name}.default.svc.cluster.local:3306)/catalog?allowNativePasswords=true"
  }
  type = "Opaque"
}

resource "kubernetes_secret" "email" {
  metadata {
    name = "sendgrid"
  }
  data = {
    api-key    = var.sendgrid_api_key
    email-from = var.sendgrid_from
  }
  type = "Opaque"
}

module "kubernetes" {
  source = "../kubernetes"

  image_webshop                  = "dapr-eshop-webshop:latest"
  replicas_webshop               = 1
  image_pull_policy_webshop      = "IfNotPresent"
  image_catalog                  = "dapr-eshop-catalog:latest"
  replicas_catalog               = 1
  image_pull_policy_catalog      = "IfNotPresent"
  image_orderservice             = "dapr-eshop-orderservice:latest"
  replicas_orderservice          = 1
  image_pull_policy_orderservice = "IfNotPresent"
  enable_aspnet_development      = var.enable_aspnet_development

  depends_on = [
    null_resource.build_images,
    null_resource.install_dapr,
    kubernetes_secret.catalog,
    kubernetes_service.mysql,
    null_resource.setup_database,
    kubernetes_service.redis
  ]
}
