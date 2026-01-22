resource "google_container_cluster" "podinfo_cluster" {
  name                     = var.cluster_name
  location                 = var.zone
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false # only for ephemeral envs
}

resource "google_container_node_pool" "podinfo_cluster_nodes" {
  name       = "${var.cluster_name}-node-pool"
  cluster    = google_container_cluster.podinfo_cluster.name
  location   = var.zone
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
