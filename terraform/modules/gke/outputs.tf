output "kubeconfig" {
  value = google_container_cluster.primary.endpoint
}
