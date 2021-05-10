resource "null_resource" "deploy_dapr_components" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl config use-context 'gke_${var.project_id}_${google_container_cluster.primary.location}_${google_container_cluster.primary.name}'
      kubectl apply -f components/.
    EOT
  }

  depends_on = [
    google_container_cluster.primary,
    null_resource.install_dapr
  ]
}

resource "kubernetes_secret" "gke_private_key" {
  metadata {
    name = "gcp-sa-access"
  }
  data = {
    type = local.gke_private_key.type
    project-id      = local.gke_private_key.project_id
    private-key-id  = local.gke_private_key.private_key_id
    private-key     = local.gke_private_key.private_key
    client-email    = local.gke_private_key.client_email
    client-id       = local.gke_private_key.client_id
    auth-uri       = local.gke_private_key.auth_uri
    token-uri       = local.gke_private_key.token_uri
    auth-provider-x509-cert-url     = local.gke_private_key.auth_provider_x509_cert_url
    client-x509-cert-url = local.gke_private_key.client_x509_cert_url
  }
  type = "Opaque"
  depends_on = [
    google_service_account_key.gke
  ]
}

resource "kubernetes_secret" "catalog_mysql" {
  metadata {
    name = "catalog-mysql"
  }
  data = {
    url = "${var.mysql_admin_username}:${var.mysql_admin_password}@tcp(${google_sql_database_instance.catalog.private_ip_address}:3306)/catalog?allowNativePasswords=true"
  }
  type = "Opaque"
  depends_on = [
    google_sql_user.catalog
  ]
}

module "kubernetes" {
  source = "../kubernetes"

  image_webshop             = "${var.geography}.gcr.io/${var.project_id}/webshop:latest"
  image_catalog             = "${var.geography}.gcr.io/${var.project_id}/catalogservice:latest"
  image_orderservice        = "${var.geography}.gcr.io/${var.project_id}/orderservice:latest"
  enable_aspnet_development = var.enable_aspnet_development
  sendgrid_api_key          = var.sendgrid_api_key
  sendgrid_from             = var.sendgrid_from
  default_email_to          = var.default_email_to

  depends_on = [
    null_resource.install_dapr,
    null_resource.deploy_dapr_components,
    null_resource.build_images,
    kubernetes_secret.gke_private_key,
    kubernetes_secret.catalog_mysql
  ]
}
