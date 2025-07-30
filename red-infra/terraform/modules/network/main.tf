# VPC Network and Subnet Configuration

# Create custom VPC network
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  description             = "VPC network for ${var.vpc_name}"
}

# Create subnet with secondary ranges for pods and services
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr
  description   = "Subnet for GKE cluster"

  # Enable private Google access for nodes without external IPs
  private_ip_google_access = true
  
  # Secondary IP ranges for GKE pods and services
  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = var.pod_cidr
  }

  secondary_ip_range {
    range_name    = "service-ranges"
    ip_cidr_range = var.service_cidr
  }
}

# Optional: Cloud Router and NAT for outbound internet access
# Uncomment if your applications need to access external services
# resource "google_compute_router" "router" {
#   name    = "${var.vpc_name}-router"
#   region  = var.region
#   network = google_compute_network.vpc.id
# }

# resource "google_compute_router_nat" "nat" {
#   name                               = "${var.vpc_name}-nat"
#   router                            = google_compute_router.router.name
#   region                            = var.region
#   nat_ip_allocate_option            = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
# }