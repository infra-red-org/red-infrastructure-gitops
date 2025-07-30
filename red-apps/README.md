# Red Apps - Application Definitions for ArgoCD

This directory contains all application definitions that ArgoCD will deploy and manage in the cluster.

## 🎯 Purpose

This `red-apps` directory contains:
1. **ArgoCD Application Definitions** - What applications to deploy
2. **Helm Chart Configurations** - How to configure each application
3. **Environment-Specific Values** - Different settings for dev/staging/prod
4. **Kubernetes Manifests** - Additional resources like ingress routes

## 🏗️ How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                    Application Flow                             │
├─────────────────────────────────────────────────────────────────┤
│  1. You modify files in this directory                         │
│  2. ArgoCD detects changes (within 3 minutes)                  │
│  3. ArgoCD compares desired state (Git) vs actual (cluster)    │
│  4. ArgoCD automatically syncs the differences                 │
│  5. Applications are updated in the cluster                    │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Directory Structure

```
red-apps/
├── applications/                 # ArgoCD Application definitions
│   ├── traefik.yaml             # Traefik load balancer
│   ├── vault.yaml               # HashiCorp Vault for secrets
│   ├── kube-prometheus-stack.yaml # Monitoring stack
│   └── keda.yaml                # Event-driven autoscaling
├── helm-charts/                 # Helm chart configurations
│   ├── traefik/                 # Traefik configuration
│   │   ├── Chart.yaml           # Chart metadata and dependencies
│   │   └── values.yaml          # Base configuration values
│   ├── vault/                   # Vault configuration
│   ├── kube-prometheus-stack/   # Monitoring configuration
│   └── keda/                    # KEDA configuration
├── environments/                # Environment-specific overrides
│   ├── dev/                     # Development environment values
│   ├── staging/                 # Staging environment values
│   └── prod/                    # Production environment values
├── k8s-manifests/              # Additional Kubernetes resources
│   ├── ingress-routes.yaml     # Traefik ingress routes
│   └── network-policies.yaml   # Network security policies
└── README.md                   # This file
```

## 🚀 How to Use

### Making Changes
```bash
# 1. Edit application configuration
vim helm-charts/traefik/values.yaml

# 2. Commit and push (if using Git)
git add .
git commit -m "Update Traefik configuration"
git push

# 3. ArgoCD automatically detects and applies changes!
# No manual deployment needed!
```

### Environment-Specific Changes
```bash
# Update production-specific settings
vim environments/prod/traefik-values.yaml

# ArgoCD will apply these overrides to production
```

## 📋 File Explanations

### Application Definitions (`applications/`)
These files tell ArgoCD **what** to deploy:

- **`traefik.yaml`** - Defines how to deploy Traefik load balancer
- **`vault.yaml`** - Defines how to deploy HashiCorp Vault
- **`kube-prometheus-stack.yaml`** - Defines monitoring stack deployment
- **`keda.yaml`** - Defines KEDA autoscaling deployment

Each application points to:
- A Helm chart configuration in `helm-charts/`
- Environment-specific values in `environments/`

### Helm Charts (`helm-charts/`)
These directories contain **how** to configure each application:

- **`Chart.yaml`** - Defines which official Helm chart to use and its version
- **`values.yaml`** - Base configuration that applies to all environments

### Environment Overrides (`environments/`)
These files contain environment-specific settings:

- **`dev/`** - Development environment (smaller resources, debug enabled)
- **`staging/`** - Staging environment (production-like but smaller)
- **`prod/`** - Production environment (full resources, security hardened)

### Additional Resources (`k8s-manifests/`)
Raw Kubernetes YAML files for resources not managed by Helm:

- **`ingress-routes.yaml`** - Traefik ingress routes for accessing services
- **`network-policies.yaml`** - Network security policies

## 🔄 Workflow Examples

### Example 1: Update Traefik Resources
```bash
# Edit the base configuration
vim helm-charts/traefik/values.yaml

# Change resource limits
resources:
  requests:
    cpu: 200m      # Changed from 100m
    memory: 128Mi  # Changed from 64Mi

# ArgoCD will detect this change and update Traefik automatically
```

### Example 2: Production-Only Change
```bash
# Edit production overrides
vim environments/prod/traefik-values.yaml

# Add production-specific settings
traefik:
  replicas: 3  # High availability for production
  resources:
    requests:
      cpu: 500m
      memory: 256Mi

# This only affects production environment
```

### Example 3: Add New Application
```bash
# 1. Create application definition
cat > applications/my-app.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  source:
    repoURL: https://github.com/infra-red-org/red-infrastructure-gitops
    path: red-apps/helm-charts/my-app
  destination:
    namespace: my-app
EOF

# 2. Create Helm chart configuration
mkdir helm-charts/my-app
# Add Chart.yaml and values.yaml

# 3. ArgoCD will automatically deploy the new application
```

## 🎛️ Application Dependencies

Applications are deployed in this order:
1. **Vault** - Secrets management (deployed first)
2. **Traefik** - Load balancer and ingress
3. **Kube-Prometheus-Stack** - Monitoring (Prometheus, Grafana, Alertmanager)
4. **KEDA** - Event-driven autoscaling

## 🔐 Security Features

- **No Secrets in Git** - All secrets managed by Vault
- **Vault Integration** - Applications use Vault for secret injection
- **Network Policies** - Pod-to-pod communication restrictions
- **RBAC** - Role-based access control

## 📊 Monitoring

### ArgoCD UI
- Real-time application status
- Deployment history
- Health monitoring
- Easy rollback capabilities

### Application Health
ArgoCD continuously monitors:
- Pod status and readiness
- Service availability
- Configuration drift
- Resource health

## 🆘 Troubleshooting

### Application Stuck in "OutOfSync"
```bash
# Check application status
kubectl get applications -n argocd

# Get detailed information
kubectl describe application <app-name> -n argocd

# Force sync if needed
kubectl patch application <app-name> -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

### Check Application Logs
```bash
# ArgoCD application controller logs
kubectl logs -n argocd deployment/argocd-application-controller

# Specific application pod logs
kubectl logs -n <namespace> <pod-name>
```

### Validate Configuration
```bash
# Check Helm chart syntax
helm template helm-charts/traefik

# Validate Kubernetes manifests
kubectl apply --dry-run=client -f k8s-manifests/
```

## 🎯 Best Practices

1. **Small, Frequent Changes** - Make small changes and let ArgoCD sync them
2. **Environment Parity** - Keep environments as similar as possible
3. **Version Pinning** - Pin Helm chart versions in Chart.yaml
4. **Resource Limits** - Always set resource requests and limits
5. **Health Checks** - Configure proper readiness and liveness probes

## 🔗 Integration with red-infra

This directory is watched by ArgoCD, which was installed by the `../red-infra/` setup:

- **ArgoCD Root App** points to `red-apps/applications/`
- **Changes here** trigger automatic deployments
- **No CI/CD pipeline** needed for applications
- **GitOps principles** - Git is the source of truth

---

**Remember:** Every change you make here will be automatically deployed by ArgoCD!