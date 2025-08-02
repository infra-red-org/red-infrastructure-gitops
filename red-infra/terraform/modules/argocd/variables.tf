variable "cluster_endpoint" {
  description = "GKE cluster endpoint to trigger ArgoCD installation"
  type        = string
}

variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "8.2.5"  # Latest stable version
}

variable "domain" {
  description = "Domain for ArgoCD server (optional)"
  type        = string
  default     = "argocd.local"
}