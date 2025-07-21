#!/bin/bash

echo "🗄️ Installing Local Path Provisioner for persistent storage..."

# Install Rancher Local Path Provisioner
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.28/deploy/local-path-storage.yaml

echo "⏳ Waiting for local-path-provisioner to be ready..."
kubectl wait --for=condition=Ready pod -l app=local-path-provisioner -n local-path-storage --timeout=300s

echo "✅ Local Path Provisioner installed!"

# Check storage classes
echo "📋 Available storage classes:"
kubectl get storageclass

echo ""
echo "🔍 Setting local-path as default storage class..."
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo ""
echo "✅ Storage provisioner setup complete!"
echo "🚀 Now restart your Helm releases to retry PVC creation..."
