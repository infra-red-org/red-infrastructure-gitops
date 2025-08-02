output "argocd_namespace" {
  description = "The namespace where ArgoCD is installed"
  value       = "argocd"
}

output "argocd_admin_password_command" {
  description = "Command to get the ArgoCD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_port_forward_command" {
  description = "Command to port-forward to ArgoCD UI"
  value       = "kubectl port-forward svc/argocd-server -n argocd 8080:443"
}

output "argocd_ui_url" {
  description = "ArgoCD UI URL (after port-forward)"
  value       = "https://localhost:8080"
}