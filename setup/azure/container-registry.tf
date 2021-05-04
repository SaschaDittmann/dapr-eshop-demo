resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix_nospecialchars}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false

  provisioner "local-exec" {
    command = <<-EOT
      az acr build -t ${self.login_server}/webapp -r ${self.name} --no-logs --no-wait ../.. -f ../../Dockerfile.webapp
    EOT
  }
}

resource "azurerm_role_assignment" "aks_sp_container_registry" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.k8s.object_id
}
