#!/bin/bash
# Bootstrap GitOps after infrastructure is provisioned
# This script applies the ArgoCD project and app-of-apps to start GitOps

set -e

echo "🚀 Bootstrapping GitOps with ArgoCD..."

# Check if kubectl is connected to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: kubectl is not connected to a cluster"
    echo "Please connect to your GKE cluster first:"
    echo "gcloud container clusters get-credentials <cluster-name> --region <region>"
    exit 1
fi

# Check if ArgoCD namespace exists
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ Error: ArgoCD namespace not found"
    echo "Please ensure ArgoCD is installed via Terraform first"
    exit 1
fi

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Apply ArgoCD project
echo "📋 Creating ArgoCD infrastructure project..."
kubectl apply -f red-apps/bootstrap/infrastructure-project.yaml

# Apply app-of-apps
echo "🎯 Creating app-of-apps (GitOps bootstrap)..."
kubectl apply -f red-apps/bootstrap/app-of-apps.yaml

echo "✅ GitOps bootstrap complete!"
echo ""
echo "🎉 ArgoCD is now managing your applications from the red-apps directory"
echo ""
echo "📊 Access ArgoCD UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Then visit: https://localhost:8080"
echo ""
echo "🔑 Get admin password:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
echo "📱 Monitor applications:"
echo "   kubectl get applications -n argocd"