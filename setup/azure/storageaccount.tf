resource "random_id" "storage_account_suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "main" {
  name                     = "${var.prefix_nospecialchars}${random_id.storage_account_suffix.dec}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
