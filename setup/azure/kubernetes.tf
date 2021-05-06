resource "kubernetes_secret" "cosmosdb" {
  metadata {
    name = "azure-cosmosdb"
  }
  data = {
    url       = "${azurerm_cosmosdb_account.cosmosdb.endpoint}"
    masterKey = "${azurerm_cosmosdb_account.cosmosdb.primary_key}"
  }
  type = "Opaque"
}

resource "kubernetes_secret" "catalog_mysql" {
  metadata {
    name = "catalog-mysql"
  }
  data = {
    url = "${var.mysql_admin_username}@${azurerm_mysql_server.mysql.name}:${var.mysql_admin_password}@tcp(${azurerm_mysql_server.mysql.fqdn}:3306)/catalog?allowNativePasswords=true"
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

  image_webshop             = "${azurerm_container_registry.acr.login_server}/webshop:latest"
  image_catalog             = "${azurerm_container_registry.acr.login_server}/catalog:latest"
  image_orderservice        = "${azurerm_container_registry.acr.login_server}/orderservice:latest"
  enable_aspnet_development = var.enable_aspnet_development

  depends_on = [
    azurerm_kubernetes_cluster.k8s,
    kubernetes_secret.catalog_mysql,
    kubernetes_secret.email
  ]
}
