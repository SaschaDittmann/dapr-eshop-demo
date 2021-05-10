resource "google_container_cluster" "primary" {
  name               = "${var.prefix}-gke"
  location           = var.region
  network            = google_compute_network.main.self_link
  subnetwork         = google_compute_subnetwork.cluster.self_link
  initial_node_count = 1
  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
}

resource "null_resource" "install_dapr" {
  provisioner "local-exec" {
    command = <<-EOT
      gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region}
      dapr init -k --enable-ha=true --wait
    EOT
  }

  depends_on = [
    google_container_cluster.primary
  ]
}

