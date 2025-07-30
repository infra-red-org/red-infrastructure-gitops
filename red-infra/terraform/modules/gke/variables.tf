variable "project_id" {
  description = "The project ID where the cluster will be created"
  type        = string
}

variable "region" {
  description = "The region where the cluster will be created"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "network" {
  description = "The VPC network to host the cluster"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster"
  type        = string
}

variable "cluster_ipv4_cidr_block" {
  description = "The IP address range for pods in the cluster"
  type        = string
  default     = "172.16.0.0/14"
}

variable "services_ipv4_cidr_block" {
  description = "The IP address range for services in the cluster"
  type        = string
  default     = "172.20.0.0/20"
}