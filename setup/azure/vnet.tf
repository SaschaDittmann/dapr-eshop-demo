resource "azurerm_virtual_network" "k8s" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "k8s" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.k8s.name
  address_prefixes     = ["10.240.0.0/16"]
}
