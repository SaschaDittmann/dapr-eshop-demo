resource "azurerm_eventhub_namespace" "pubsub" {
  name                = "${var.prefix}-eventhubs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "pubsub" {
  name                = "pubsub"
  namespace_name      = azurerm_eventhub_namespace.pubsub.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "orderservice" {
  name                = "orderservice"
  namespace_name      = azurerm_eventhub_namespace.pubsub.name
  eventhub_name       = azurerm_eventhub.pubsub.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_eventhub_authorization_rule" "pubsub" {
  name                = "dapr"
  namespace_name      = azurerm_eventhub_namespace.pubsub.name
  eventhub_name       = azurerm_eventhub.pubsub.name
  resource_group_name = azurerm_resource_group.rg.name
  listen              = true
  send                = true
  manage              = false
}
