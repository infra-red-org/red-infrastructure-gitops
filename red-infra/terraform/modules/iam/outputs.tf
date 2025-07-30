output "workload_identity_sa_email" {
  description = "Email address of the Workload Identity service account"
  value       = google_service_account.workload_identity_sa.email
}

output "workload_identity_sa_name" {
  description = "Fully qualified name of the Workload Identity service account"
  value       = google_service_account.workload_identity_sa.name
}

output "workload_identity_sa_id" {
  description = "Unique ID of the Workload Identity service account"
  value       = google_service_account.workload_identity_sa.unique_id
}

output "workload_identity_sa_member" {
  description = "Member string for the Workload Identity service account"
  value       = "serviceAccount:${google_service_account.workload_identity_sa.email}"
}

output "workload_identity_pool_name" {
  description = "The name of the Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "workload_identity_provider_name" {
  description = "The name of the Workload Identity Pool Provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}