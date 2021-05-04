resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_aks
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "agentpool"
    availability_zones  = ["1", "2", "3"]
    vnet_subnet_id      = azurerm_subnet.k8s.id
    enable_auto_scaling = true
    min_count           = 3
    max_count           = var.max_agent_count
    vm_size             = var.agent_vm_size
  }

  service_principal {
    client_id     = azuread_service_principal.k8s.application_id
    client_secret = azuread_service_principal_password.k8s.value
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id
    }
    azure_policy {
      enabled = false
    }
    http_application_routing {
      enabled = false
    }
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "azure"
    network_policy    = "azure"
  }

  role_based_access_control {
    enabled = true
  }

  provisioner "local-exec" {
    command = <<-EOT
      az aks get-credentials -g ${azurerm_resource_group.rg.name} -n ${azurerm_kubernetes_cluster.k8s.name} --overwrite-existing
      dapr init -k --enable-ha=true
      kubectl apply -f components/.
    EOT
  }
}
