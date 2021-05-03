terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.57"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.1"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}
