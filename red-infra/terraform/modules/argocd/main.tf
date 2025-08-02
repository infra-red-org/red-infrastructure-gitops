# ArgoCD Installation Module - Minimal Approach
# This module ONLY installs ArgoCD using Helm
# All ArgoCD configurations (projects, apps) are managed via GitOps in red-apps/

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_version

  # Configuration following official ArgoCD documentation
  values = [
    yamlencode({
      # Global configuration
      global = {
        domain = var.domain
      }
      
      # ArgoCD Server configuration
      server = {
        # Service configuration
        service = {
          type = "ClusterIP"
        }
        
        # Ingress configuration (disabled for port-forward access)
        ingress = {
          enabled = false
        }
        
        # Server configuration parameters
        extraArgs = [
          "--insecure"  # Allow HTTP access for port-forward
        ]
        
        # Server metrics
        metrics = {
          enabled = true
        }
      }
      
      # ArgoCD Application Controller configuration
      controller = {
        replicas = 1  # Single replica for cost efficiency
        
        # Controller metrics
        metrics = {
          enabled = true
        }
      }
      
      # ArgoCD Repository Server configuration
      repoServer = {
        replicas = 1  # Single replica for cost efficiency
        
        # Repo server metrics
        metrics = {
          enabled = true
        }
      }
      
      # ArgoCD ApplicationSet Controller
      applicationSet = {
        enabled = true
        
        # ApplicationSet metrics
        metrics = {
          enabled = true
        }
      }
      
      # ArgoCD Notifications Controller
      notifications = {
        enabled = true
        
        # Notifications metrics
        metrics = {
          enabled = true
        }
      }
      
      # ArgoCD Dex Server (for SSO - disabled for simplicity)
      dex = {
        enabled = false
      }
      
      # Redis configuration
      redis = {
        enabled = true
        
        # Redis metrics
        metrics = {
          enabled = true
        }
      }
      
      # Configuration management
      configs = {
        # Server configuration
        params = {
          "server.insecure" = "true"
          "server.disable.auth" = "false"
          "server.enable.proxy.extension" = "true"
        }
        
        # ArgoCD configuration
        cm = {
          # Server configuration
          "server.insecure" = "true"
          
          # Application configuration
          "application.instanceLabelKey" = "argocd.argoproj.io/instance"
          
          # Timeout configurations
          "timeout.hard.reconciliation" = "0"
          "timeout.reconciliation" = "180s"
        }
        
        # RBAC configuration (basic setup)
        rbac = {
          "policy.default" = "role:readonly"
          "policy.csv" = <<-EOT
            p, role:admin, applications, *, */*, allow
            p, role:admin, clusters, *, *, allow
            p, role:admin, repositories, *, *, allow
            g, admin, role:admin
          EOT
        }
      }
    })
  ]

  depends_on = [var.cluster_endpoint]
}