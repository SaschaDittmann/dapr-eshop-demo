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

module "kubernetes" {
  source = "../kubernetes"

  image_webshop = "${azurerm_container_registry.acr.login_server}/webshop:latest"
  image_catalog = "${azurerm_container_registry.acr.login_server}/catalog:latest"

  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}
