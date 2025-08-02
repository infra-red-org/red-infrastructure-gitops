# Main Terraform configuration for GKE cluster provisioning and ArgoCD installation


# Create the VPC network and subnets
module "network" {
  source = "./modules/network"
  
  project_id   = var.project_id
  region       = var.region
  vpc_name     = var.vpc_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
  pod_cidr     = var.pod_cidr
  service_cidr = var.service_cidr
}

# Create IAM roles and Workload Identity
module "iam" {
  source = "./modules/iam"
  
  project_id                = var.project_id
  github_repositories       = var.github_repositories
  workload_identity_pool_id = var.workload_identity_pool_id
  service_account_id        = var.service_account_id
}

# Create the GKE Autopilot cluster
module "gke" {
  source = "./modules/gke"
  
  project_id               = var.project_id
  region                   = var.region
  cluster_name             = var.cluster_name
  network                  = module.network.network_name
  subnetwork               = module.network.subnet_name
  cluster_ipv4_cidr_block  = var.pod_cidr
  services_ipv4_cidr_block = var.service_cidr
  
  depends_on = [module.network, module.iam]
}

# Install ArgoCD automatically after cluster is created
module "argocd" {
  source = "./modules/argocd"
  
  cluster_endpoint = module.gke.cluster_endpoint
  
  depends_on = [module.gke]
}