# ShopMicro Production Platform - Technical Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Component Details](#component-details)
4. [Infrastructure](#infrastructure)
5. [Kubernetes Deployment](#kubernetes-deployment)
6. [Observability Stack](#observability-stack)
7. [Security](#security)
8. [CI/CD Pipeline](#cicd-pipeline)
9. [Running the Platform](#running-the-platform)

---

## Overview

ShopMicro is a microservices-based e-commerce platform designed to demonstrate production-grade DevOps practices. It consists of:

- **Frontend**: React SPA served via Nginx
- **Backend**: Node.js/Express REST API
- **ML Service**: Python Flask recommendation engine
- **Data Layer**: PostgreSQL + Redis

This platform showcases:
- Containerization with Docker
- Kubernetes orchestration
- Infrastructure as Code (Terraform)
- Configuration as Code (Ansible)
- Full observability (metrics, logs, traces)
- CI/CD with quality gates
- Security best practices

---

## Live Deployment

The platform is deployed on Azure Kubernetes Service (AKS) with the following endpoints:

| Service | Endpoint |
|---------|----------|
| Frontend | `https://shopmicro.<your-domain>.com` |
| Backend API | `https://shopmicro.<your-domain>.com/api/products` |
| ML Service | `https://shopmicro.<your-domain>.com/ml/recommendations/42` |

### Infrastructure Details

- **Cloud Provider**: Microsoft Azure
- **Kubernetes**: AKS (Azure Kubernetes Service)
- **Container Registry**: Azure Container Registry (ACR)
- **Ingress**: NGINX Ingress Controller with Azure Load Balancer
- **External IP**: Assigned automatically by Azure

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INTERNET                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         NGINX INGRESS CONTROLLER                            │
│                    (Layer 7 Load Balancer / Router)                         │
│                                                                             │
│   • Routes: /     → Frontend                                                │
│   • Routes: /api  → Backend API                                             │
│   • Routes: /ml   → ML Service                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
            ┌───────────┐     ┌───────────┐     ┌───────────┐
            │ Frontend  │     │  Backend  │     │ ML Service│
            │  (React)  │     │ (Express) │     │  (Flask)  │
            │  :8080    │     │  :8080    │     │  :5000    │
            └───────────┘     └───────────┘     └───────────┘
                    │                 │                 │
                    └─────────────────┼─────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    ▼                                   ▼
            ┌───────────┐                     ┌───────────┐
            │PostgreSQL │                     │   Redis   │
            │  :5432    │                     │  :6379    │
            │(Stateful) │                     │  (Cache)  │
            └───────────┘                     └───────────┘
```

### Service Communication Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USER                                            │
│                         (Browser/Mobile)                                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTPS Request
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          INGRESS                                             │
│                    (TLS Termination + Routing)                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
              ▼                     ▼                     ▼
      ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
      │  Frontend   │       │   Backend   │       │ ML Service  │
      │             │       │             │       │             │
      │  Static    │◄─────►│  REST API   │◄─────►│ Recommends  │
      │  Content   │       │             │       │             │
      └─────────────┘       └─────────────┘       └─────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              ▼                                       ▼
      ┌─────────────┐                         ┌─────────────┐
      │ PostgreSQL  │                         │   Redis     │
      │             │                         │             │
      │  Products  │                         │   Cache     │
      │  Orders     │                         │   Sessions  │
      └─────────────┘                         └─────────────┘
```

---

## Component Details

### 1. Frontend (React + Nginx)

**Technology Stack:**
- React 18
- Vite (build tool)
- Nginx (web server)

**Purpose:** 
- Serves the user interface
- Makes API calls to backend
- Displays products and recommendations

**Key Files:**
- `frontend/src/App.jsx` - Main React component
- `frontend/vite.config.js` - Vite configuration
- `frontend/Dockerfile` - Multi-stage build
- `frontend/nginx.conf` - Nginx configuration

**Dockerfile Breakdown:**
```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Serve
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Why Multi-Stage?**
- Reduces final image size (no Node.js runtime needed)
- Separates build from runtime concerns
- Security: Attack surface minimized

### 2. Backend (Node.js/Express)

**Technology Stack:**
- Node.js 20
- Express.js
- pg (PostgreSQL driver)
- redis (Redis client)

**Purpose:**
- RESTful API for products, orders
- Database operations
- Caching layer integration
- Business logic

**Key Endpoints:**
- `GET /health` - Health check
- `GET /products` - List products (cached)
- `GET /products/:id` - Get single product

**Caching Strategy:**
```
Request → Check Redis → Cache Hit → Return Cached Data
                    → Cache Miss → Query DB → Store in Redis → Return
```

**Environment Variables:**
| Variable | Description | Source |
|----------|-------------|--------|
| DB_HOST | PostgreSQL hostname | ConfigMap |
| DB_USER | Database user | ConfigMap |
| DB_PASSWORD | Database password | Key Vault (CSI) |
| DB_NAME | Database name | ConfigMap |
| REDIS_URL | Redis connection | ConfigMap |

### 3. ML Service (Python/Flask)

**Technology Stack:**
- Python 3.12
- Flask 3.0

**Purpose:**
- Product recommendations
- Simple algorithm for demo

**Key Endpoints:**
- `GET /health` - Health check
- `GET /metrics` - Prometheus metrics
- `GET /recommendations/<user_id>` - Get recommendations

**Why Separate Service?**
- Independent scaling
- Different runtime requirements
- Microservices pattern
- ML models can be updated independently

### 4. Data Layer

#### PostgreSQL (Stateful)
- **Image:** postgres:16
- **Storage:** PersistentVolumeClaim
- **Initialization:** init.sql script
- **Tables:** products (seed data)

#### Redis (Stateless)
- **Image:** redis:7-alpine
- **Purpose:** Caching, session storage
- **Strategy:** TTL-based expiration

---

## Infrastructure

### Terraform Architecture (Azure)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          RESOURCE GROUP                                      │
│                         "shopmicro-rg"                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
    ┌───────────────┼───────────────┐
    ▼               ▼               ▼
┌────────┐    ┌─────────┐    ┌──────────────┐
│   ACR  │    │   AKS   │    │  Key Vault   │
│        │    │         │    │              │
│ Images │    │ Cluster │    │  Secrets     │
└────────┘    └─────────┘    └──────────────┘
```

### Module Structure

```
infrastructure/terraform/
├── main.tf              # Root module - orchestrates everything
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── providers.tf        # Provider configuration
├── terraform.tfvars    # Variable values
└── modules/
    ├── acr/            # Azure Container Registry
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── aks/             # Azure Kubernetes Service
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── keyvault/        # Azure Key Vault
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Azure Components

| Component | Purpose | Configuration |
|-----------|---------|---------------|
| **ACR** | Container registry for images | Admin disabled, RBAC enabled |
| **AKS** | Kubernetes cluster | SystemAssigned identity, OIDC enabled |
| **Key Vault** | Secret storage | RBAC authorization, soft-delete enabled |

### Ansible Roles

```
infrastructure/ansible/
├── site.yaml                    # Main playbook
└── roles/
    ├── docker/                  # Install Docker
    ├── kubectl/                 # Install kubectl
    ├── helm/                    # Install Helm
    └── tls/                     # Generate TLS certs
```

---

## Kubernetes Deployment

### Namespace Structure

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: shopmicro
```

All resources live in the `shopmicro` namespace for isolation.

### Deployments

#### Backend Deployment
- **Replicas:** 2 (configurable)
- **Anti-Affinity:** Pods spread across nodes
- **Resources:** 
  - Requests: 100m CPU, 128Mi memory
  - Limits: 300m CPU, 256Mi memory
- **Health Checks:**
  - Liveness: HTTP /health every 10s
  - Readiness: HTTP /health every 5s

#### Frontend Deployment
- **Replicas:** 2
- **Resources:** Same as backend

#### ML Service
- **Replicas:** 1
- **Resources:** Smaller footprint (50m CPU, 64Mi memory)

### Services

| Service | Type | Ports | Purpose |
|---------|------|-------|---------|
| frontend | ClusterIP | 80 | Internal frontend access |
| backend | ClusterIP | 8080 | Internal API access |
| ml-service | ClusterIP | 5000 | Internal ML access |
| postgres | ClusterIP | 5432 | Database |
| redis | ClusterIP | 6379 | Cache |

### Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shopmicro-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  ingressClassName: nginx
  rules:
  - host: shopmicro.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 8080
      - path: /ml
        pathType: Prefix
        backend:
          service:
            name: ml-service
            port:
              number: 5000
```

### Secrets Management

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AZURE KEY VAULT                                     │
│                                                                             │
│   Secrets:                                                                  │
│   ├── db-password       → PostgreSQL password                              │
│   └── redis-password   → Redis password                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ CSI Driver
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    KUBERNETES POD                                          │
│                                                                             │
│   Volume Mount: /mnt/secrets-store/                                         │
│   Environment Variables: DB_PASSWORD (from secret)                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

---

## Observability Stack

### Architecture (LGTM Stack)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         OBSERVABILITY FLOW                                  │
└─────────────────────────────────────────────────────────────────────────────┘

   ┌─────────┐    ┌──────────┐    ┌──────────┐    ┌────────────────────────┐
   │ Service │───►│  OTel    │───►│  Tempo   │───►│  Grafana (Traces)      │
   │ Traces  │    │ Collector│    │ (Trace   │    │                        │
   └─────────┘    └──────────┘    │ Store)   │    └────────────────────────┘
                                  └──────────┘
   ┌─────────┐    ┌──────────┐    ┌──────────┐    ┌────────────────────────┐
   │ Service │───►│  OTel    │───►│   Loki   │───│  Grafana (Logs)       │
   │ Logs    │    │ Collector│    │ (Log     │    │                        │
   └─────────┘    └──────────┘    │ Store)   │    └────────────────────────┘
                                  └──────────┘
   ┌─────────┐    ┌──────────┐    ┌──────────┐    ┌────────────────────────┐
   │ Service │───►│ Prometheus│───│ Mimir    │───►│  Grafana (Metrics)    │
   │ Metrics │    │          │    │ (Metric  │    │                        │
   └─────────┘    └──────────┘    │ Store)   │    └────────────────────────┘
                                  └──────────┘
```

### Dashboards

1. **Platform Overview** - Cluster-wide metrics
   - Total request rate
   - Pod restarts count
   - CPU/Memory by pod
   
2. **Service Health** - Application metrics
   - Service uptime status
   - Error rate percentage
   - P95 latency
   - Requests by service
   
3. **Logs & Traces** - Debugging
   - Live log viewer
   - Distributed trace view
   - Log/trace correlation

### SLIs & SLOs

| SLI | Definition | Target |
|-----|------------|--------|
| **Availability** | % of successful requests | > 99.5% |
| **Latency** | P95 response time | < 500ms |
| **Error Rate** | % of 5xx responses | < 1% |

### Alert Definitions

| Alert | Condition | Severity |
|-------|-----------|----------|
| HighErrorRate | > 5% errors for 5m | Critical |
| HighLatency | P95 > 1s for 5m | Warning |
| PodNotReady | Pod not ready for 3m | Warning |
| HighMemoryUsage | Memory > 90% for 5m | Warning |

---

## Security

### Network Security

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         NETWORK SEGMENTATION                                │
└─────────────────────────────────────────────────────────────────────────────┘

   INTERNET
       │
       ▼
   ┌─────────┐     ┌─────────────────────────────────────────────┐
   │ Ingress │────►│         Virtual Network (VNet)              │
   │  (80/443)    │                                             │
   └─────────┘     │  ┌──────────────────────────────────────┐  │
                  │  │        AKS Subnet                      │  │
                  │  │                                        │  │
                  │  │  ┌────────┐ ┌────────┐ ┌─────────────┐  │  │
                  │  │  │Frontend│ │ Backend│ │  ML Service │  │  │
                  │  │  └────────┘ └────────┘ └─────────────┘  │  │
                  │  │                                        │  │
                  │  │  ┌─────────────┐  ┌────────────────┐   │  │
                  │  │  │  PostgreSQL │  │     Redis     │   │  │
                  │  │  └─────────────┘  └────────────────┘   │  │
                  │  └────────────────────────────────────────┘  │
                  └────────────────────────────────────────────┘
```

### Secrets Management

1. **No Hardcoded Secrets** - All secrets from Key Vault
2. **CSI Provider** - Secrets mounted as volumes
3. **RBAC** - Fine-grained access control
4. **Encryption at Rest** - Azure-managed keys

### Security Best Practices Applied

| Practice | Implementation |
|----------|----------------|
| Least Privilege | RBAC, no cluster-admin |
| Network Isolation | Internal services, Ingress only |
| Secrets Management | Azure Key Vault + CSI |
| TLS | HTTPS everywhere |
| Image Scanning | Trivy in CI (optional) |
| Pod Security | Non-root users, read-only filesystem |

---

## CI/CD Pipeline

### Pipeline Stages

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CI/CD PIPELINE FLOW                                 │
└─────────────────────────────────────────────────────────────────────────────┘

   PUSH TO MAIN
         │
         ▼
   ┌─────────────┐
   │    LINT     │ ──► Syntax checks, Terraform validate, YAML validation
   └─────────────┘
         │
         ▼
   ┌─────────────┐
   │    TEST     │ ──► Unit tests (backend + ML service)
   └─────────────┘
         │
         ▼
   ┌─────────────┐
   │   BUILD     │ ──► Docker build + push to ACR
   └─────────────┘
         │
         ▼
   ┌─────────────┐
   │  POLICIES   │ ──► OPA/Conftest validation
   └─────────────┘
         │
         ▼
   ┌─────────────┐
   │   DEPLOY    │ ──► Update K8s manifests + kubectl apply
   └─────────────┘
         │
         ▼
   ┌─────────────┐
   │   VERIFY    │ ──► Rollout status, health checks
   └─────────────┘
```

### GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| ci-cd.yaml | Push/PR to main | Main pipeline |
| terraform-drift.yaml | Daily schedule | Detect IaC drift |
| policy-check.yaml | Push/PR | Security policies |

---

## Running the Platform

### Option 1: Docker Compose (Local Development)

```bash
# Clone and run
git clone <repo>
cd shop-micro-production-platform
docker-compose up -d

# Access
# Frontend: http://localhost:3000
# Backend: http://localhost:8080
# ML Service: http://localhost:5000
```

### Option 2: Kubernetes (Production/Cloud)

```bash
# 1. Deploy infrastructure
cd infrastructure/terraform
terraform init && terraform apply

# 2. Get AKS credentials
az aks get-credentials -g <rg-name> -n <aks-name>

# 3. Deploy application
kubectl apply -f ../k8s/

# 4. Configure ingress IP
# Point your domain to ingress external IP
```

### Health Check

```bash
# Using the CLI tool
./scripts/healthcheck.sh -n shopmicro -v
./scripts/healthcheck.sh -n shopmicro -u  # Check URLs
```

---

## File Structure Summary

```
shop-micro-production-platform/
├── README.md                    # Quick start guide
├── Documentation.md             # This file
├── docker-compose.yaml          # Local development
├── k8s/                        # Kubernetes manifests
│   ├── namespace.yaml
│   ├── backend/
│   ├── frontend/
│   ├── ml-service/
│   ├── postgres/
│   ├── redis/
│   └── observability/           # Monitoring stack
├── infrastructure/
│   ├── terraform/               # IaC
│   └── ansible/                # CaC
├── observability/              # Dashboards, alerts
│   ├── dashboards/
│   ├── otel/
│   └── alerts.yaml
├── scripts/                    # Utility scripts
├── runbooks/                   # Incident runbooks
├── evidence/                   # Deployment evidence
└── .github/workflows/          # CI/CD pipelines
```

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Pods not starting | Check events: `kubectl describe pod <name> -n shopmicro` |
| Image pull errors | Verify ACR credentials in Kubernetes |
| Ingress 404 | Check ingress class and path configuration |
| Database connection | Verify secrets and ConfigMap values |
| High memory | Increase HPA limits or pod memory |

### Useful Commands

```bash
# View logs
kubectl logs -l app=backend -n shopmicro -f

# Describe resource
kubectl describe deployment backend -n shopmicro

# Exec into pod
kubectl exec -it <pod-name> -n shopmicro -- /bin/sh

# Port forward for testing
kubectl port-forward svc/backend 8080:8080 -n shopmicro
```

---

*Last Updated: 2026-02-25*
