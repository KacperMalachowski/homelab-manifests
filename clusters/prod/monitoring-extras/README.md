# Monitoring Extras

This directory contains monitoring resources that depend on the core monitoring infrastructure being fully deployed.

## Purpose

Resources in this directory require Custom Resource Definitions (CRDs) that are created by the Prometheus Operator. These include:

- `ServiceMonitor` resources for additional service monitoring
- `PrometheusRule` resources for custom alerting rules
- `PodMonitor` resources for pod-level monitoring

## Dependency Chain

1. **Infrastructure** (`clusters/prod/infrastructure/`) deploys first:
   - Traefik (ingress controller)
   - Prometheus Operator (creates CRDs)
   - Core monitoring stack (Prometheus, Grafana, AlertManager, Loki)

2. **Monitoring Extras** (`clusters/prod/monitoring-extras/`) deploys after:
   - Waits for infrastructure to be healthy
   - Waits for ServiceMonitor CRD to exist
   - Deploys additional monitoring configurations

## Current Resources

- `traefik-servicemonitor.yaml` - Configures Prometheus to scrape Traefik metrics

## Adding New Resources

When adding new monitoring resources that depend on Prometheus Operator CRDs:

1. Add the resource YAML file to this directory
2. Update `kustomization.yaml` to include the new resource
3. The Flux `monitoring-extras` Kustomization will automatically deploy it after dependencies are ready
