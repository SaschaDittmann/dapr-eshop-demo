terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.57"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}
