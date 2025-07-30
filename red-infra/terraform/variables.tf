# Terraform variable definitions for infrastructure provisioning

variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pod_cidr" {
  description = "The CIDR range for pods"
  type        = string
  default     = "172.16.0.0/14"
}

variable "service_cidr" {
  description = "The CIDR range for services"
  type        = string
  default     = "172.20.0.0/20"
}

# GitHub repositories for Workload Identity Federation
variable "github_repositories" {
  description = "List of GitHub repositories that should have access to deploy this infrastructure"
  type        = list(string)
}

# Workload Identity Configuration
variable "workload_identity_pool_id" {
  description = "ID for the Workload Identity Pool"
  type        = string
}

variable "service_account_id" {
  description = "ID for the service account used with Workload Identity"
  type        = string
}

# Git Repository Configuration
variable "git_repository_url" {
  description = "The Git repository URL that ArgoCD should watch for application definitions"
  type        = string
  default     = "https://github.com/infra-red-org/red-infrastructure-gitops"
}