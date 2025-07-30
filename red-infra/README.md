# Red Infrastructure - Cluster & ArgoCD Setup

This directory contains everything needed to provision a GKE cluster and install ArgoCD, which will then manage applications from the `../red-apps/` directory.

## 🎯 Purpose

This `red-infra` directory is responsible for:
1. **GKE Cluster Provisioning** - Creates the Kubernetes cluster using Terraform
2. **ArgoCD Installation** - Installs and configures ArgoCD in the cluster
3. **GitOps Bootstrap** - Configures ArgoCD to watch the `red-apps` directory

## 🏗️ How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                    Infrastructure Flow                          │
├─────────────────────────────────────────────────────────────────┤
│  1. Terraform → Creates GKE cluster                            │
│  2. ArgoCD Bootstrap → Installs ArgoCD in cluster              │
│  3. Root App → Points ArgoCD to ../red-apps/ directory         │
│  4. ArgoCD → Watches red-apps and deploys applications         │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Directory Structure

```
red-infra/
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output values
│   ├── terraform.tfvars.example # Example variables file
│   └── modules/                 # Terraform modules
│       ├── network/             # VPC and networking
│       ├── iam/                 # IAM and Workload Identity
│       ├── gke/                 # GKE cluster configuration
│       └── argocd/              # ArgoCD installation (NEW!)
└── README.md                    # This file
```

## 🚀 Quick Start

### 1. Configure Terraform
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Deploy Everything (Infrastructure + ArgoCD)
```bash
# Initialize and apply Terraform (this installs everything!)
terraform init
terraform plan
terraform apply
```

### 3. Access ArgoCD
```bash
# Configure kubectl
gcloud container clusters get-credentials <cluster-name> --region <region>

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080
```

### 4. Verify Setup
```bash
# Check ArgoCD is running
kubectl get pods -n argocd

# Check applications are being managed
kubectl get applications -n argocd
```

## 🔄 Workflow

### Infrastructure Changes (This Directory)
1. Modify Terraform files in `terraform/`
2. Run `terraform plan` and `terraform apply`
3. ArgoCD configuration is automatically updated!

### Application Changes (../red-apps/ Directory)
1. Modify application files in `../red-apps/`
2. ArgoCD automatically detects and syncs changes
3. No manual intervention needed!

## 📋 File Explanations

### Terraform Files
- **`terraform/main.tf`** - Orchestrates all infrastructure modules including ArgoCD
- **`terraform/variables.tf`** - Defines all configurable parameters
- **`terraform/outputs.tf`** - Exports important values after deployment
- **`terraform/modules/network/`** - Creates VPC, subnets, and networking
- **`terraform/modules/iam/`** - Sets up IAM roles and Workload Identity
- **`terraform/modules/gke/`** - Provisions the GKE Autopilot cluster
- **`terraform/modules/argocd/`** - Installs and configures ArgoCD automatically

## 🔗 Integration with red-apps

The `argocd-bootstrap/root-app.yaml` file configures ArgoCD to watch the `../red-apps/` directory:

```yaml
spec:
  source:
    repoURL: https://github.com/your-org/red-infrastructure-gitops
    path: red-apps  # Points to the red-apps directory
```

This means:
- Changes in `red-apps/` trigger automatic deployments
- No CI/CD pipeline needed for applications
- ArgoCD handles all application lifecycle management

## 🛡️ Security Features

- **Private GKE Cluster** - Nodes have no public IP addresses
- **Workload Identity** - Secure authentication without service account keys
- **RBAC** - Fine-grained access control for ArgoCD
- **Network Policies** - Pod-to-pod communication restrictions

## 🆘 Troubleshooting

### Common Issues
1. **Terraform state lock** - Use `terraform force-unlock <lock-id>`
2. **ArgoCD not accessible** - Check port-forward: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
3. **Applications not syncing** - Check ArgoCD logs: `kubectl logs -n argocd deployment/argocd-application-controller`

---

**Next Step:** Configure applications in the `../red-apps/` directory