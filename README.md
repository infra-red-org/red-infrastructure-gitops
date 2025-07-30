# Red Infrastructure GitOps with ArgoCD

This is a comprehensive GitOps implementation for deploying the red-infrastructure components (Traefik, Kube-Prometheus-Stack, and KEDA) using ArgoCD following industry best practices.

## 🚀 Quick Start

**Get running in 15 minutes!** → [Quick Start Guide](docs/quick-start.md)

## 📋 What This Provides

- **GitOps Workflow**: Declarative infrastructure management through Git
- **ArgoCD**: Automated deployment and synchronization
- **Multi-Environment Support**: Dev, staging, and production configurations
- **Security Best Practices**: RBAC, secrets management, and secure defaults
- **Monitoring**: Built-in observability for the GitOps pipeline
- **Production Ready**: Comprehensive documentation and operational procedures

## 🏗️ Architecture Overview

```
red-infrastructure-gitops/
├── red-infra/                     # Infrastructure & ArgoCD Setup
│   ├── terraform/                # Infrastructure as Code
│   │   ├── main.tf               # Main Terraform configuration
│   │   ├── variables.tf          # Variable definitions
│   │   ├── outputs.tf            # Output values
│   │   └── modules/              # Terraform modules
│   │       ├── network/          # VPC and networking
│   │       ├── iam/              # IAM and Workload Identity
│   │       └── gke/              # GKE cluster configuration
│   ├── argocd-bootstrap/         # ArgoCD installation and config
│   │   ├── install.yaml          # ArgoCD installation manifests
│   │   ├── rbac.yaml             # RBAC configuration
│   │   ├── projects.yaml         # ArgoCD projects
│   │   └── root-app.yaml         # Root app pointing to red-apps
│   └── scripts/                  # Automation scripts
│       └── bootstrap-argocd.sh   # ArgoCD bootstrap script
├── red-apps/                     # Applications managed by ArgoCD
│   ├── applications/             # ArgoCD Application definitions
│   │   ├── traefik.yaml          # Traefik load balancer
│   │   ├── vault.yaml            # HashiCorp Vault
│   │   ├── kube-prometheus-stack.yaml # Monitoring stack
│   │   └── keda.yaml             # Event-driven autoscaling
│   ├── helm-charts/              # Helm chart configurations
│   │   ├── traefik/              # Traefik configuration
│   │   ├── vault/                # Vault configuration
│   │   ├── kube-prometheus-stack/ # Monitoring configuration
│   │   └── keda/                 # KEDA configuration
│   ├── environments/             # Environment-specific overrides
│   │   └── prod/                 # Production values
│   └── k8s-manifests/           # Additional Kubernetes resources
│       └── ingress-routes.yaml   # Traefik ingress routes
└── COMPLETE-SETUP-GUIDE.md      # Comprehensive setup guide
```

## 🎯 GitOps Workflow

1. **Infrastructure Foundation**: GKE cluster provisioned via Terraform
2. **ArgoCD Bootstrap**: ArgoCD installed and configured on cluster
3. **Application Deployment**: ArgoCD manages all application deployments
4. **Configuration Management**: Environment-specific values through Git
5. **Continuous Sync**: Automatic synchronization of desired state

## 🛠️ Components Managed

| Component | Purpose | Namespace |
|-----------|---------|-----------|
| **ArgoCD** | GitOps controller and UI | `argocd` |
| **Vault** | Secrets management and encryption | `vault` |
| **Traefik** | Load balancer, ingress controller, SSL termination | `traefik-v2` |
| **Kube-Prometheus-Stack** | Monitoring (Prometheus, Grafana, Alertmanager) | `monitoring` |
| **KEDA** | Event-driven autoscaling | `keda` |

## 📚 Documentation

- **[Complete Setup Guide](COMPLETE-SETUP-GUIDE.md)** - Comprehensive guide explaining every file and process
- **[red-infra README](red-infra/README.md)** - Infrastructure and ArgoCD setup
- **[red-apps README](red-apps/README.md)** - Application management guide

## 🔧 Prerequisites

- GKE cluster running (from red-infrastructure Terraform)
- `kubectl` configured and connected to cluster
- `helm` 3.x installed
- Git repository access
- Domain name (optional, for ingress)

## ⚡ Quick Commands

```bash
# Deploy everything (infrastructure + ArgoCD) in one command!
cd red-infra/terraform
terraform init && terraform apply

# Check status
kubectl get applications -n argocd
kubectl get pods -A

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080

# Make application changes (ArgoCD auto-syncs)
vim red-apps/helm-charts/traefik/values.yaml
git add . && git commit -m "Update config" && git push
```

## 🔐 Security Features

- **RBAC**: Role-based access control for ArgoCD
- **Workload Identity**: Secure GCP service account integration
- **SSL/TLS**: Automatic certificate management via Let's Encrypt
- **Network Policies**: Pod-to-pod communication restrictions
- **Secret Management**: Kubernetes secrets integration
- **Security Contexts**: Non-root containers with minimal privileges

## 🎛️ Key Benefits Over Direct Terraform

| Aspect | Terraform Approach | GitOps Approach |
|--------|-------------------|-----------------|
| **Deployment** | Manual `terraform apply` | Automatic sync from Git |
| **Rollbacks** | Manual state management | One-click rollback in UI |
| **Visibility** | CLI/logs only | Rich UI with status/health |
| **Multi-Environment** | Multiple tfvars files | Environment-specific overlays |
| **Team Collaboration** | Shared state file | Git-based collaboration |
| **Drift Detection** | Manual `terraform plan` | Automatic drift detection |
| **Application Updates** | Terraform + Helm complexity | Simple Git commit |

## 🚦 Getting Started

Choose your path:

### 🏃‍♂️ I want to get started quickly
→ Follow the [Quick Start Guide](docs/quick-start.md)

### 📖 I want to understand everything first
→ Read the [Detailed Setup Guide](docs/setup-guide.md)

### 🏭 I'm setting up for production
→ Review [GitOps Best Practices](docs/gitops-best-practices.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

- **Issues**: Create GitHub issues for bugs or feature requests
- **Discussions**: Use GitHub discussions for questions
- **Documentation**: Check the docs/ directory for detailed guides

## 🎉 What's Next?

After successful deployment:

1. **Configure DNS**: Point domains to LoadBalancer IP
2. **Customize Values**: Update environment-specific configurations
3. **Add Applications**: Extend the GitOps pattern to your applications
4. **Set Up Monitoring**: Configure alerts and dashboards
5. **Implement CI/CD**: Integrate with your development workflow

---

**Ready to embrace GitOps?** Start with the [Quick Start Guide](docs/quick-start.md)! 🚀