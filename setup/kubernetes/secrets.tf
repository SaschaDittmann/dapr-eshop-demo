resource "kubernetes_secret" "email" {
  metadata {
    name = "sendgrid"
  }
  data = {
    api-key    = var.sendgrid_api_key
    email-from = var.sendgrid_from
  }
  type = "Opaque"
}

resource "kubernetes_secret" "default_email_to" {
  metadata {
    name = "email-default-settings"
  }
  data = {
    email-to = var.default_email_to
  }
  type = "Opaque"
}
