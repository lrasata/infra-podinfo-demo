output "kubeconfig" {
  value = google_container_cluster.podinfo_cluster.endpoint
}
