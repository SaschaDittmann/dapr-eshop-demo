resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "random_password" "spn" {
  length  = 32
  special = true
}

resource "azurerm_log_analytics_workspace" "k8s" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.prefix}-${random_id.log_analytics_workspace_name_suffix.dec}-loganalytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_log_analytics_solution" "k8s" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.k8s.id
  workspace_name        = azurerm_log_analytics_workspace.k8s.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azuread_application" "k8s" {
  display_name = "${var.prefix}-spn"
}

resource "azuread_service_principal" "k8s" {
  application_id               = azuread_application.k8s.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "k8s" {
  service_principal_id = azuread_service_principal.k8s.id
  value                = random_password.spn.result
  end_date_relative    = "240h"
}

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

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "${var.prefix}-cosmosdb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "statestore" {
  name                = "statestore"
  resource_group_name = azurerm_cosmosdb_account.cosmosdb.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

resource "azurerm_cosmosdb_sql_container" "states" {
  name                  = "states"
  resource_group_name   = azurerm_cosmosdb_account.cosmosdb.resource_group_name
  account_name          = azurerm_cosmosdb_account.cosmosdb.name
  database_name         = azurerm_cosmosdb_sql_database.statestore.name
  partition_key_path    = "/id"
  partition_key_version = 1
  throughput            = 400
}

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

resource "kubernetes_deployment" "webapp" {
  metadata {
    name = "webapp"
    labels = {
      app = "webapp"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "webapp"
      }
    }
    template {
      metadata {
        labels = {
          app = "webapp"
        }
        annotations = {
          "dapr.io/enabled"  = "true"
          "dapr.io/app-id"   = "eshop"
          "dapr.io/app-port" = "80"
        }
      }
      spec {
        container {
          image             = "${azurerm_container_registry.acr.login_server}/webapp:latest"
          name              = "aspnet"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "webapp" {
  metadata {
    name = "webapp"
    labels = {
      app = "webapp"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.webapp.metadata.0.labels.app
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
