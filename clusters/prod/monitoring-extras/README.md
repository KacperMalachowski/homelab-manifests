# Monitoring Extras

This directory contains monitoring resources that depend on the core monitoring infrastructure being fully deployed.

## Purpose

Resources in this directory require Custom Resource Definitions (CRDs) that are created by both the Prometheus Operator and Traefik. These include:

- `ServiceMonitor` resources for additional service monitoring (requires Prometheus Operator CRDs)
- `PrometheusRule` resources for custom alerting rules (requires Prometheus Operator CRDs)
- `PodMonitor` resources for pod-level monitoring (requires Prometheus Operator CRDs)
- `IngressRoute` resources for web access to monitoring services (requires Traefik CRDs)

## Dependency Chain

1. **Infrastructure** (`clusters/prod/infrastructure/`) deploys first:
   - Traefik (ingress controller)
   - Prometheus Operator (creates CRDs)
   - Core monitoring stack (Prometheus, Grafana, AlertManager, Loki)

2. **Monitoring Extras** (`clusters/prod/monitoring-extras/`) deploys after:
   - Waits for infrastructure to be healthy
   - Waits for ServiceMonitor CRD to exist (from Prometheus Operator)
   - Waits for IngressRoute CRD to exist (from Traefik)
   - Deploys additional monitoring configurations

## Current Resources

- `traefik-servicemonitor.yaml` - Configures Prometheus to scrape Traefik metrics
- `ingress-routes.yaml` - Provides web access to Grafana, Prometheus, and AlertManager

## Adding New Resources

When adding new monitoring resources that depend on Prometheus Operator or Traefik CRDs:

1. Add the resource YAML file to this directory
2. Update `kustomization.yaml` to include the new resource
3. The Flux `monitoring-extras` Kustomization will automatically deploy it after dependencies are ready
