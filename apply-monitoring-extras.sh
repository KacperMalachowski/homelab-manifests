#!/bin/bash

# Script to fix and restart failed Helm releases
echo "🔧 Fixing failed Helm releases..."

echo "📝 Current Helm release status:"
kubectl get helmreleases -A

echo ""
echo "🚀 Suspending and resuming Flux kustomizations to trigger redeployment..."

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
