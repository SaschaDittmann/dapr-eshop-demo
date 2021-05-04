resource "random_password" "spn" {
  length  = 32
  special = true
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
