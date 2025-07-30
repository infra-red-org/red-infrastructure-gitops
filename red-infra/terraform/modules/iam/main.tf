# Workload Identity Pool for GitHub Actions authentication
resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name             = var.workload_identity_pool_display_name
  description              = var.workload_identity_pool_description
}

# Workload Identity Pool Provider for GitHub OIDC
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name                       = var.workload_identity_provider_display_name
  
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  
  # Only allow specified GitHub repositories
  attribute_condition = join(" || ", [for repo in var.github_repositories : "assertion.repository=='${repo}'"])
  
  oidc {
    issuer_uri        = "https://token.actions.githubusercontent.com"
    allowed_audiences = ["sts.googleapis.com"]
  }
}

# Service Account for Workload Identity
resource "google_service_account" "workload_identity_sa" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = var.service_account_description
  project      = var.project_id
}

# IAM roles for the service account
resource "google_project_iam_member" "workload_identity_roles" {
  for_each = toset([
    "roles/container.admin",        # For managing GKE clusters
    "roles/compute.networkAdmin",   # For managing VPC networks
    "roles/iam.serviceAccountUser", # For using service accounts
    "roles/storage.admin",          # For managing storage buckets
  ])
  
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.workload_identity_sa.email}"
}

# Workload Identity Federation binding
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.workload_identity_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    # Allow access from specified GitHub repositories
    for repo in var.github_repositories : "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${repo}"
  ]
}