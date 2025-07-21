# SSL/TLS Configuration Guide

## Current Setup
The current Traefik configuration uses Traefik's default TLS certificates. For production with the `malachowski.me` domain, you'll want to set up automatic SSL certificates.

## Option 1: Let's Encrypt with Traefik (Recommended)

Add this to your Traefik Helm values in `infrastructure/traefik/traefik.yaml`:

```yaml
# Add to the additionalArguments section:
additionalArguments:
  # ...existing args...
  - "--certificatesresolvers.letsencrypt.acme.email=your-email@malachowski.me"
  - "--certificatesresolvers.letsencrypt.acme.storage=/data/acme.json"
  - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"

# Add persistence for ACME certificates
persistence:
  enabled: true
  name: data
  accessMode: ReadWriteOnce
  size: 128Mi
  storageClass: "local-path"
  path: /data
  annotations: {}

# Add certificate resolver to ports
ports:
  websecure:
    tls:
      enabled: true
      options: default
    certResolver: letsencrypt
```

Then update your IngressRoutes to use the certificate resolver:

```yaml
spec:
  tls:
    certResolver: letsencrypt
```

## Option 2: cert-manager

Install cert-manager and use ClusterIssuer for Let's Encrypt certificates.

## DNS Requirements

Make sure these DNS A records point to your cluster's external IP:
- `traefik.malachowski.me`
- `grafana.malachowski.me` 
- `prometheus.malachowski.me`
- `alertmanager.malachowski.me`

The certificates will be automatically requested and renewed by Let's Encrypt.
