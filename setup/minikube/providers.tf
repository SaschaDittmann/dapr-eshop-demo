terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.1"
    }
  }

  required_version = ">= 0.14.9"
}

provider "kubernetes" {
  config_context_cluster = "minikube"
  config_path            = "~/.kube/config"
}
