resource "google_compute_network" "main" {
  name = "${var.prefix}-network"
  auto_create_subnetworks         = false
}

resource "google_compute_subnetwork" "cluster" {
  ip_cidr_range            = "10.0.0.0/16"
  name                     = "cluster"
  region                   = var.region
  network                  = google_compute_network.main.self_link
  
  secondary_ip_range {
    ip_cidr_range = "10.1.0.0/16"
    range_name    = "pods"
  }

  secondary_ip_range {
    ip_cidr_range = "10.2.0.0/16"
    range_name    = "services"
  }
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
