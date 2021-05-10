output "cluster_endpoint" {
  description = "GKE cluster endpoint."
  value       = "https://${google_container_cluster.primary.endpoint}"
}
