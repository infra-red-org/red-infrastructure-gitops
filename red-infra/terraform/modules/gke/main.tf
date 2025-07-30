resource "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.region
  
  # Enable Autopilot for fully managed nodes
  enable_autopilot = true

  # Network configuration
  network    = var.network
  subnetwork = var.subnetwork

  # IP allocation for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "service-ranges"
  }

  # Release channel for automatic updates
  release_channel {
    channel = "REGULAR"
  }
  
  # Disable deletion protection for easier cleanup during development
  deletion_protection = false

  # Enable Workload Identity for secure service account authentication
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Private cluster configuration (optional, uncomment for production)
  # private_cluster_config {
  #   enable_private_nodes    = true
  #   enable_private_endpoint = false
  #   master_ipv4_cidr_block  = "172.16.0.0/28"
  # }

  # Master authorized networks (optional, for additional security)
  # master_authorized_networks_config {
  #   cidr_blocks {
  #     cidr_block   = "0.0.0.0/0"
  #     display_name = "All networks"
  #   }
  # }
}