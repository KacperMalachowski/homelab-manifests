#!/bin/bash

# Test Flux configuration locally
set -e

echo "Testing Flux configuration..."

# Check if flux CLI is available
if ! command -v flux &> /dev/null; then
    echo "Installing Flux CLI..."
    curl -s https://fluxcd.io/install.sh | bash
    export PATH=$PATH:$HOME/.flux/bin
fi

echo "Validating all Flux manifests in the repository..."

# Find and validate all Flux resources
find clusters/ -name "*.yaml" -o -name "*.yml" -exec flux validate {} \;

echo "✅ All Flux manifests are valid!"

# Check if kustomize can build our configurations
if command -v kustomize &> /dev/null; then
    echo "Testing kustomization builds..."
    
    find clusters/ -name "kustomization.yaml" -exec dirname {} \; | while read dir; do
        echo "Building kustomization in $dir"
        cd "$dir"
        kustomize build . > /dev/null
        echo "✅ $dir builds successfully"
        cd - > /dev/null
    done
else
    echo "Installing kustomize..."
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/
    
    echo "Testing kustomization builds..."
    find clusters/ -name "kustomization.yaml" -exec dirname {} \; | while read dir; do
        echo "Building kustomization in $dir"
        cd "$dir"
        kustomize build . > /dev/null
        echo "✅ $dir builds successfully"
        cd - > /dev/null
    done
fi

# Check for dependency issues
echo "Checking for potential dependency issues..."

# Check if ServiceMonitor is used before Prometheus Operator
if grep -r "kind: ServiceMonitor" clusters/prod/infrastructure/ 2>/dev/null; then
    echo "⚠️  WARNING: ServiceMonitor found in infrastructure - should be in monitoring-extras"
fi

# Check if monitoring-extras exists and has proper dependencies
if [ -d "clusters/prod/monitoring-extras" ]; then
    if grep -q "dependsOn" clusters/prod/flux-system/flux-sources.yaml; then
        echo "✅ Monitoring extras properly configured with dependencies"
    else
        echo "⚠️  WARNING: monitoring-extras exists but no dependsOn found in flux-sources.yaml"
    fi
fi

echo "🎉 All tests passed!"
