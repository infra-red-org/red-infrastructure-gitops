variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# GitHub repositories for Workload Identity Federation
variable "github_repositories" {
  description = "List of GitHub repositories that should have access to deploy this infrastructure"
  type        = list(string)
}

# Workload Identity Pool Configuration
variable "workload_identity_pool_id" {
  description = "ID for the Workload Identity Pool"
  type        = string
}

variable "workload_identity_pool_display_name" {
  description = "Display name for the Workload Identity Pool"
  type        = string
  default     = "GitOps GitHub Actions Pool"
}

variable "workload_identity_pool_description" {
  description = "Description for the Workload Identity Pool"
  type        = string
  default     = "Workload Identity Pool for GitOps GitHub Actions"
}

# Workload Identity Pool Provider Configuration
variable "workload_identity_provider_id" {
  description = "ID for the Workload Identity Pool Provider"
  type        = string
  default     = "github-provider"
}

variable "workload_identity_provider_display_name" {
  description = "Display name for the Workload Identity Pool Provider"
  type        = string
  default     = "GitHub Actions Provider"
}

# Service Account Configuration
variable "service_account_id" {
  description = "ID for the service account used with Workload Identity"
  type        = string
}

variable "service_account_display_name" {
  description = "Display name for the service account"
  type        = string
  default     = "GitOps Workload Identity Service Account"
}

variable "service_account_description" {
  description = "Description for the service account"
  type        = string
  default     = "Service account for GitOps GitHub Actions and Kubernetes workloads"
}