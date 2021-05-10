resource "random_id" "sql_database_instance_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "catalog" {
  name             = "${var.prefix}-${random_id.sql_database_instance_suffix.dec}-mysql"
  project          = var.project_id
  region           = var.region
  database_version = "MYSQL_5_7"
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  settings {
    availability_type = "ZONAL"
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.self_link
    }
  }
  deletion_protection = false
}

resource "google_sql_database" "catalog" {
  name     = "catalog"
  instance = google_sql_database_instance.catalog.name
}

resource "google_sql_user" "catalog" {
  name     = var.mysql_admin_username
  instance = google_sql_database_instance.catalog.name
  host     = "%"
  password = var.mysql_admin_password
}
