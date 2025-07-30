# ArgoCD Installation Module
# This module installs ArgoCD automatically after the GKE cluster is created

# Data source to get cluster credentials
data "google_client_config" "default" {}

# Configure Kubernetes provider to connect to the cluster
provider "kubernetes" {
  host                   = "https://${var.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${var.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "7.6.12"  # Pin to specific version

  # Custom values for ArgoCD
  values = [
    yamlencode({
      # Server configuration
      server = {
        # Enable insecure mode for easier access (change in production)
        insecure = true
        
        # Service configuration
        service = {
          type = "ClusterIP"
        }
        
        # Ingress configuration (disabled by default)
        ingress = {
          enabled = false
        }
        
        # Additional configuration
        config = {
          # Repository configuration
          repositories = yamlencode([
            {
              type = "git"
              url  = var.git_repository_url
              name = "red-infrastructure-gitops"
            }
          ])
          
          # Helm repositories
          "helm.repositories" = yamlencode([
            {
              name = "traefik"
              url  = "https://traefik.github.io/charts"
            },
            {
              name = "prometheus-community"
              url  = "https://prometheus-community.github.io/helm-charts"
            },
            {
              name = "kedacore"
              url  = "https://kedacore.github.io/charts"
            },
            {
              name = "hashicorp"
              url  = "https://helm.releases.hashicorp.com"
            }
          ])
        }
      }
      
      # Application controller configuration
      controller = {
        resources = {
          requests = {
            cpu    = "250m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "1Gi"
          }
        }
      }
      
      # Repository server configuration
      repoServer = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "512Mi"
          }
        }
      }
      
      # Dex server configuration
      dex = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }
      
      # Redis configuration
      redis = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Create RBAC configuration
resource "kubernetes_config_map" "argocd_rbac" {
  metadata {
    name      = "argocd-rbac-cm"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "app.kubernetes.io/name"    = "argocd-rbac-cm"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    "policy.default" = "role:readonly"
    "policy.csv" = <<-EOT
      # Admin role - full access to everything
      p, role:admin, applications, *, */*, allow
      p, role:admin, clusters, *, *, allow
      p, role:admin, repositories, *, *, allow
      p, role:admin, certificates, *, *, allow
      p, role:admin, projects, *, *, allow
      p, role:admin, accounts, *, *, allow
      p, role:admin, gpgkeys, *, *, allow
      p, role:admin, logs, *, *, allow
      p, role:admin, exec, *, *, allow
      
      # Developer role - limited access to applications
      p, role:developer, applications, get, */*, allow
      p, role:developer, applications, sync, */*, allow
      p, role:developer, applications, action/*, */*, allow
      p, role:developer, logs, get, */*, allow
      p, role:developer, repositories, get, *, allow
      p, role:developer, clusters, get, *, allow
      
      # ReadOnly role - view only access
      p, role:readonly, applications, get, */*, allow
      p, role:readonly, logs, get, */*, allow
      p, role:readonly, repositories, get, *, allow
      p, role:readonly, clusters, get, *, allow
      
      # Assign admin role to admin user
      g, admin, role:admin
    EOT
    "scopes" = "[groups, email]"
  }

  depends_on = [helm_release.argocd]
}

# Create ArgoCD projects
resource "kubernetes_manifest" "argocd_project_infrastructure" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "infrastructure"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      description = "Infrastructure components managed by platform team"
      sourceRepos = [
        var.git_repository_url,
        "https://traefik.github.io/charts",
        "https://prometheus-community.github.io/helm-charts",
        "https://kedacore.github.io/charts",
        "https://helm.releases.hashicorp.com"
      ]
      destinations = [
        {
          namespace = "*"
          server    = "https://kubernetes.default.svc"
        }
      ]
      clusterResourceWhitelist = [
        { group = "", kind = "Namespace" },
        { group = "rbac.authorization.k8s.io", kind = "ClusterRole" },
        { group = "rbac.authorization.k8s.io", kind = "ClusterRoleBinding" },
        { group = "apiextensions.k8s.io", kind = "CustomResourceDefinition" },
        { group = "admissionregistration.k8s.io", kind = "MutatingWebhookConfiguration" },
        { group = "admissionregistration.k8s.io", kind = "ValidatingWebhookConfiguration" },
        { group = "monitoring.coreos.com", kind = "*" },
        { group = "keda.sh", kind = "*" },
        { group = "traefik.containo.us", kind = "*" }
      ]
      namespaceResourceWhitelist = [
        { group = "", kind = "*" },
        { group = "apps", kind = "*" },
        { group = "extensions", kind = "*" },
        { group = "networking.k8s.io", kind = "*" },
        { group = "policy", kind = "*" },
        { group = "monitoring.coreos.com", kind = "*" },
        { group = "keda.sh", kind = "*" },
        { group = "traefik.containo.us", kind = "*" }
      ]
    }
  }

  depends_on = [helm_release.argocd]
}

# Create the root application (App of Apps)
resource "kubernetes_manifest" "argocd_root_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "root-app"
      namespace = kubernetes_namespace.argocd.metadata[0].name
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "infrastructure"
      source = {
        repoURL        = var.git_repository_url
        targetRevision = "HEAD"
        path           = "red-apps/applications"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = kubernetes_namespace.argocd.metadata[0].name
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_manifest.argocd_project_infrastructure
  ]
}