# ArgoCD module variables

variable "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The CA certificate of the GKE cluster"
  type        = string
}

variable "git_repository_url" {
  description = "The Git repository URL that ArgoCD should watch"
  type        = string
}