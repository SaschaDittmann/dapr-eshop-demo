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

module "kubernetes" {
  source = "../kubernetes"

  container_registry_endpoint = azurerm_container_registry.acr.login_server

  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}
