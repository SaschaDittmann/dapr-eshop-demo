resource "azurerm_mysql_server" "mysql" {
  name                         = "${var.prefix}-mysqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "5.7"
  administrator_login          = var.mysql_admin_username
  administrator_login_password = var.mysql_admin_password
  sku_name                     = "B_Gen5_1"
  storage_mb                   = 5120
  ssl_enforcement_enabled      = false
}

resource "azurerm_mysql_database" "catalog" {
  name                = "catalog"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "allow_access_to_azure_services" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_firewall_rule" "allow_all" {
  name                = "AllowAll"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
