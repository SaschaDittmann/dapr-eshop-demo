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

resource "kubernetes_secret" "eventhub" {
  metadata {
    name = "azure-eventhub"
  }
  data = {
    connectionString = azurerm_eventhub_authorization_rule.pubsub.primary_connection_string
  }
  type = "Opaque"
}

resource "kubernetes_secret" "storage_account" {
  metadata {
    name = "azure-storageaccount"
  }
  data = {
    storageaccountname = azurerm_storage_account.main.name
    storageaccountkey = azurerm_storage_account.main.primary_access_key
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
    kubernetes_secret.email,
    kubernetes_secret.eventhub,
    kubernetes_secret.storage_account
  ]
}
