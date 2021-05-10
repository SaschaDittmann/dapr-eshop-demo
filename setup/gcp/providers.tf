terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 3.66"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.1"
    }
  }

  required_version = ">= 0.14.9"
}

provider "google" {
  credentials = file("credentials.json")

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}
