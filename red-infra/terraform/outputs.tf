# Terraform outputs - values that will be available after deployment

output "cluster_name" {
  description = "The name of the created GKE cluster"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the cluster's API server"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The location (region) of the cluster"
  value       = var.region
}

output "network_name" {
  description = "The name of the VPC network"
  value       = module.network.network_name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.network.subnet_name
}

output "workload_identity_service_account" {
  description = "The email of the Workload Identity service account"
  value       = module.iam.workload_identity_sa_email
}

output "kubectl_config_command" {
  description = "Command to configure kubectl to access the cluster"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}

# ArgoCD outputs
output "argocd_namespace" {
  description = "The namespace where ArgoCD is installed"
  value       = module.argocd.argocd_namespace
}

output "argocd_admin_password_command" {
  description = "Command to get the ArgoCD admin password"
  value       = module.argocd.argocd_admin_password_command
}

output "argocd_port_forward_command" {
  description = "Command to port-forward to ArgoCD UI"
  value       = module.argocd.argocd_port_forward_command
}

output "argocd_ui_url" {
  description = "ArgoCD UI URL (after port-forward)"
  value       = module.argocd.argocd_ui_url
}

output "setup_complete_message" {
  description = "Setup completion message with next steps"
  value = <<-EOT
    🎉 Infrastructure and ArgoCD setup complete!
    
    📋 Next steps:
    1. Configure kubectl: ${module.argocd.argocd_port_forward_command}
    2. Get ArgoCD password: ${module.argocd.argocd_admin_password_command}
    3. Access ArgoCD UI: ${module.argocd.argocd_ui_url}
    4. ArgoCD is now watching: ${var.git_repository_url}/red-apps/applications/
    
    🔄 Any changes to red-apps/ will be automatically deployed!
  EOT
}