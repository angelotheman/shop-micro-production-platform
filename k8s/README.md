# Kubernetes Manifests

This directory contains all Kubernetes resource definitions for deploying ShopMicro to a Kubernetes cluster.

## Structure

```
k8s/
├── namespace.yaml              # ShopMicro namespace
├── csi-driver.yaml             # Azure Key Vault CSI driver install notes
├── backend/
│   ├── deployment.yaml        # Backend deployment with anti-affinity
│   ├── service.yaml            # ClusterIP service
│   ├── configmap.yaml         # Environment config
│   ├── secret.yaml            # User credentials
│   ├── secret-provider-class.yaml  # Key Vault integration
│   └── hpa.yaml               # Horizontal Pod Autoscaler
├── frontend/
│   ├── deployment.yaml        # Frontend deployment
│   ├── service.yaml           # ClusterIP service
│   └── ingress.yaml           # NGINX ingress
├── ml-service/
│   ├── deployment.yaml        # ML service deployment
│   └── service.yaml           # ClusterIP service
├── postgres/
│   ├── statefulset.yaml       # PostgreSQL statefulset
│   ├── service.yaml           # Database service
│   └── pvc.yaml               # Persistent volume claim
└── redis/
    ├── deployment.yaml        # Redis deployment
    └── service.yaml           # Cache service
```

## Quick Deploy

```bash
# Deploy everything
kubectl apply -f k8s/

# Check status
kubectl get pods -n shopmicro
```

## Key Features

- **Secrets**: Using Azure Key Vault via CSI Provider
- **Anti-affinity**: Backend pods spread across nodes
- **HPA**: Auto-scaling based on CPU/memory
- **Ingress**: Routes /, /api, /ml to appropriate services

## Updating Images

After building new images:
```bash
sed -i 's|shopmicroregistry.azurecr.io|<your-acr>.azurecr.io|g' k8s/*/deployment.yaml
kubectl apply -f k8s/
```
