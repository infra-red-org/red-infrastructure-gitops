# Secret Management with Vault and Workload Identity

This document explains how secrets are managed in our GitOps infrastructure using HashiCorp Vault and Google Cloud Workload Identity Federation.

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   KEDA Pods     │    │      Vault       │    │   GCP APIs      │
│                 │    │                  │    │                 │
│ ┌─────────────┐ │    │ ┌──────────────┐ │    │ ┌─────────────┐ │
│ │ Workload    │ │◄──►│ │   Secrets    │ │    │ │   Services  │ │
│ │ Identity    │ │    │ │   Storage    │ │    │ │             │ │
│ └─────────────┘ │    │ └──────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        ▲
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │     Kubernetes API         │
                    │   (Service Accounts)       │
                    └────────────────────────────┘
```

## Components

### 1. Workload Identity Federation (WIF)
- **Purpose**: Allows Kubernetes service accounts to authenticate with GCP without storing service account keys
- **Service Account**: `red-gitops-sa@cdsci-test.iam.gserviceaccount.com`
- **Annotation**: `iam.gke.io/gcp-service-account`

### 2. HashiCorp Vault
- **Purpose**: Centralized secret management and rotation
- **Mode**: Development mode (for demo)
- **Authentication**: Kubernetes auth method
- **Storage**: KV v2 secrets engine

### 3. Vault Agent Injector
- **Purpose**: Automatically inject secrets into pods
- **Method**: Sidecar containers and init containers
- **Templates**: Custom secret formatting

## Secret Management Patterns

### Pattern 1: Workload Identity Only (Recommended for GCP)
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: keda-operator
  namespace: keda
  annotations:
    iam.gke.io/gcp-service-account: "red-gitops-sa@cdsci-test.iam.gserviceaccount.com"
```

**Pros:**
- No secrets in YAML files
- Automatic credential rotation
- Native GCP integration
- No secret storage required

**Use Cases:**
- GCP API calls (Pub/Sub, Cloud Monitoring, etc.)
- GKE-native services

### Pattern 2: Vault Agent Injection
```yaml
metadata:
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "keda"
    vault.hashicorp.com/agent-inject-secret-config: "secret/data/app/config"
```

**Pros:**
- Secrets never stored in Git
- Automatic secret rotation
- Template-based secret formatting
- Audit logging

**Use Cases:**
- Third-party API keys
- Database credentials
- Custom application secrets

### Pattern 3: Vault Secrets Operator
```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: app-config
spec:
  type: kv-v2
  mount: secret
  path: app/config
  destination:
    name: app-config-secret
    create: true
```

**Pros:**
- Kubernetes-native CRDs
- Automatic secret synchronization
- Declarative configuration
- Better error handling

**Use Cases:**
- Complex secret management
- Multiple secret sources
- Advanced secret rotation

## Security Best Practices

### 1. No Secrets in Git
- ✅ Use Workload Identity for GCP services
- ✅ Store secrets in Vault
- ✅ Use environment-specific configurations
- ❌ Never commit API keys, passwords, or certificates

### 2. Principle of Least Privilege
- ✅ Limit service account permissions
- ✅ Use namespace-specific roles
- ✅ Regular permission audits
- ❌ Don't use cluster-admin roles

### 3. Secret Rotation
- ✅ Enable automatic rotation where possible
- ✅ Use short-lived tokens
- ✅ Monitor secret usage
- ❌ Don't use long-lived static credentials

## Usage Examples

### KEDA with GCP Pub/Sub (Workload Identity)
```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: pubsub-scaler
spec:
  triggers:
  - type: gcp-pubsub
    metadata:
      subscriptionName: "my-subscription"
      # No credentials - uses Workload Identity
    authenticationRef:
      name: gcp-auth

---
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: gcp-auth
spec:
  podIdentity:
    provider: gcp  # Uses Workload Identity
```

### Application with Vault Secrets
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "my-app"
        vault.hashicorp.com/agent-inject-secret-db: "secret/data/database"
        vault.hashicorp.com/agent-inject-template-db: |
          {{- with secret "secret/data/database" -}}
          DATABASE_URL="postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@{{ .Data.data.host }}:5432/{{ .Data.data.database }}"
          {{- end -}}
    spec:
      serviceAccountName: my-app-sa
      containers:
      - name: app
        image: my-app:latest
        command: ["/bin/sh"]
        args: ["-c", "source /vault/secrets/db && exec my-app"]
```

## Troubleshooting

### Common Issues

1. **Workload Identity not working**
   - Check service account annotation
   - Verify IAM bindings
   - Ensure Workload Identity is enabled on cluster

2. **Vault injection failing**
   - Check Vault agent injector logs
   - Verify Kubernetes auth configuration
   - Check service account permissions

3. **Secrets not updating**
   - Check Vault Secrets Operator status
   - Verify secret paths and permissions
   - Check network connectivity to Vault

### Debug Commands
```bash
# Check Workload Identity binding
kubectl describe sa keda-operator -n keda

# Check Vault status
kubectl exec -it vault-0 -n vault -- vault status

# Check Vault auth methods
kubectl exec -it vault-0 -n vault -- vault auth list

# Check secret injection
kubectl describe pod <pod-name> -n <namespace>
```

## Migration Guide

### From Kubernetes Secrets to Vault
1. Store existing secrets in Vault
2. Update applications to use Vault injection
3. Remove Kubernetes secrets from Git
4. Test secret rotation

### From Service Account Keys to Workload Identity
1. Create Workload Identity binding
2. Update service account annotations
3. Remove service account key files
4. Test GCP API access

## Monitoring and Alerting

### Metrics to Monitor
- Vault seal status
- Secret injection failures
- Workload Identity authentication errors
- Secret rotation status

### Recommended Alerts
- Vault becomes sealed
- High secret injection failure rate
- Workload Identity authentication failures
- Expired certificates or tokens