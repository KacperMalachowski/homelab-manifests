#!/bin/bash

# Script to fix and restart failed Helm releases
echo "🔧 Fixing failed Helm releases..."

echo "📝 Current Helm release status:"
kubectl get helmreleases -A

echo ""
echo "� Checking for storage issues..."
kubectl get pvc -A

echo ""
echo "🗄️ Checking storage classes..."
kubectl get storageclass

STORAGE_CLASSES=$(kubectl get storageclass --no-headers | wc -l)
if [ "$STORAGE_CLASSES" -eq 0 ]; then
    echo "⚠️  No storage classes found!"
    echo "💡 Options:"
    echo "   1. Run: chmod +x install-storage.sh && ./install-storage.sh"
    echo "   2. Or the configurations have been updated to disable persistent storage for testing"
fi

echo ""
echo "�🚀 Suspending and resuming Flux kustomizations to trigger redeployment..."

# Suspend the infrastructure kustomization
kubectl patch kustomization infrastructure -n flux-system -p '{"spec":{"suspend":true}}' --type=merge

# Wait a moment
sleep 5

# Resume the infrastructure kustomization
kubectl patch kustomization infrastructure -n flux-system -p '{"spec":{"suspend":false}}' --type=merge

echo "✅ Kustomization restarted"
echo ""
echo "⏳ Waiting for reconciliation..."
sleep 10

echo "📊 Updated Helm release status:"
kubectl get helmreleases -A

echo ""
echo "🔍 To monitor progress, run:"
echo "  flux get helmreleases -A"
echo "  watch kubectl get pods -A"
