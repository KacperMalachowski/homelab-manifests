# Homelab Kubernetes Cluster Configuration

This repository contains the Kubernetes manifests for the homelab cluster managed by FluxCD.

## Components

### Infrastructure

#### Traefik (Ingress Controller)
- **Namespace**: `traefik-system`
- **Purpose**: Load balancer and reverse proxy
- **Access**: `https://traefik.local` (dashboard)
- **Features**:
  - Automatic HTTPS redirect
  - Prometheus metrics enabled
  - Load balancer service type

#### Monitoring Stack (Grafana Stack)
- **Namespace**: `monitoring`
- **Components**:
  - **Prometheus**: Metrics collection and storage
  - **Grafana**: Visualization and dashboards
  - **AlertManager**: Alert handling and routing
  - **Loki**: Log aggregation
  - **Promtail**: Log shipping agent

##### Access URLs
- **Grafana**: `https://grafana.malachowski.me`
  - Username: `admin`
  - Password: `admin`
- **Prometheus**: `https://prometheus.malachowski.me`
- **AlertManager**: `https://alertmanager.malachowski.me`
- **Traefik Dashboard**: `https://traefik.malachowski.me`

##### Pre-configured Dashboards
- Kubernetes Cluster Monitoring (GrafanaNet ID: 7249)
- Node Exporter Dashboard (GrafanaNet ID: 1860)
- Traefik Dashboard (GrafanaNet ID: 4475)

## Deployment

The cluster is managed by FluxCD and automatically syncs from this repository.

### Deployment Order

Flux deploys resources in the following order to handle dependencies:

1. **Infrastructure** (`infrastructure/`):
   - Traefik (ingress controller)
   - Prometheus Operator (creates CRDs)
   - Core monitoring stack (Prometheus, Grafana, AlertManager, Loki)

2. **Monitoring Extras** (`monitoring-extras/`):
   - ServiceMonitor resources (requires Prometheus Operator CRDs)
   - Additional monitoring configurations
   - Waits for infrastructure to be healthy before deploying

### Directory Structure
```
clusters/prod/
├── flux-system/           # Flux configuration
├── infrastructure/        # Core infrastructure components
│   ├── traefik/          # Ingress controller
│   └── monitoring/       # Core observability stack
└── monitoring-extras/     # Additional monitoring (depends on infrastructure)
```

### Local Access

DNS records should point the following subdomains to your cluster's external IP:

```
traefik.malachowski.me     -> <YOUR_CLUSTER_IP>
grafana.malachowski.me     -> <YOUR_CLUSTER_IP>
prometheus.malachowski.me  -> <YOUR_CLUSTER_IP>
alertmanager.malachowski.me -> <YOUR_CLUSTER_IP>
```

Replace `<YOUR_CLUSTER_IP>` with the external IP of your Traefik LoadBalancer service.

## Storage

The configuration assumes a storage class named `local-path` is available for persistent volumes. This is commonly provided by:
- Rancher Local Path Provisioner
- K3s built-in local-path-provisioner

## Monitoring

### Metrics Collection
- **Node metrics**: via node-exporter
- **Kubernetes metrics**: via kube-state-metrics
- **Traefik metrics**: via Prometheus metrics endpoint
- **Application metrics**: automatically discovered via ServiceMonitor CRDs

### Log Collection
- **Container logs**: collected by Promtail
- **System logs**: collected by Promtail from `/var/log`
- **Storage**: Loki with filesystem storage

### Alerting
- **Default rules**: Comprehensive set of alerting rules for Kubernetes
- **AlertManager**: Routes alerts (currently configured for development)
- **Notification**: Configure webhook or other integrations in AlertManager

## Security Notes

- Default Grafana credentials should be changed in production
- **TLS Certificates**: The current configuration uses Traefik's default TLS setup. For production, consider:
  - Setting up Let's Encrypt with Traefik for automatic SSL certificates
  - Configuring cert-manager for certificate management
  - Adding proper certificate resolvers in Traefik configuration
- Review and customize AlertManager configuration for your notification preferences
- Traefik dashboard access should be restricted in production environments

## Customization

### Adding New Dashboards
Add dashboard configurations to the Grafana Helm values in `monitoring/prometheus-stack.yaml`.

### Custom Alerts
Create additional PrometheusRule resources in the monitoring namespace.

### Traefik Configuration
Modify ingress routes or add middleware configurations as needed.
