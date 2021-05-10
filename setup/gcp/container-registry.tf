resource "google_container_registry" "registry" {
  project  = var.project_id
  location = var.geography
}

resource "null_resource" "docker_login" {
  provisioner "local-exec" {
    command = <<-EOT
      docker login -u oauth2accesstoken -p '${data.google_client_config.provider.access_token}' https://${var.geography}.gcr.io
    EOT
  }

  depends_on = [
    google_container_registry.registry
  ]
}

resource "null_resource" "build_images" {
  provisioner "local-exec" {
    command = <<-EOT
      docker build -t ${var.geography}.gcr.io/${var.project_id}/webshop:latest ../../WebShop
      docker build -t ${var.geography}.gcr.io/${var.project_id}/catalogservice:latest ../../CatalogService
      docker build -t ${var.geography}.gcr.io/${var.project_id}/orderservice:latest ../../OrderService

      docker push ${var.geography}.gcr.io/${var.project_id}/webshop:latest
      docker push ${var.geography}.gcr.io/${var.project_id}/catalogservice:latest
      docker push ${var.geography}.gcr.io/${var.project_id}/orderservice:latest
    EOT
  }

  depends_on = [
    null_resource.docker_login
  ]
}
