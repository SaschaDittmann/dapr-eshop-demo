resource "google_service_account" "gke" {
  account_id   = "${var.prefix}-gke"
  display_name = "GKE Service Account"
}

resource "google_service_account_key" "gke" {
  service_account_id = google_service_account.gke.name
}

locals {
  gke_private_key = jsondecode(base64decode(google_service_account_key.gke.private_key))
}

resource "google_project_iam_member" "gke_pull_images_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

resource "google_project_iam_member" "gke_firestore_access" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

resource "google_project_iam_member" "gke_pubsub_access" {
  project = var.project_id
  role    = "roles/pubsub.admin"
  member  = "serviceAccount:${google_service_account.gke.email}"
}
