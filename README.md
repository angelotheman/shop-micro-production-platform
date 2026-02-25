# ShopMicro Production Platform

A production-ready microservices e-commerce platform. Clone this repo and run it locally or deploy to the cloud.

## Quick Start (Local Development)

```bash
# 1. Clone the repo
git clone <this-repo-url>
cd shop-micro-production-platform

# 2. Start everything with Docker Compose
docker-compose up -d

# 3. Access the application
# Frontend:    http://localhost:3000
# Backend API: http://localhost:8080
# ML Service:  http://localhost:5000

# 4. Stop everything
docker-compose down
```

## Prerequisites

### For Local Development
- Docker 24.0+
- Docker Compose v2+

### For Kubernetes Deployment
- Azure CLI (`az`)
- Terraform 1.7.0+
- kubectl 1.28.0+
- Helm 3.13.0+
- An Azure subscription

---

## Running Locally (Docker Compose)

### Step 1: Start All Services

```bash
docker-compose up -d
```

This starts:
- **Frontend** on port 3000
- **Backend** on port 8080  
- **ML Service** on port 5000
- **PostgreSQL** on port 5432
- **Redis** on port 6379

### Step 2: Verify Services

```bash
# Check containers are running
docker-compose ps

# Check logs
docker-compose logs -f backend
```

### Step 3: Test the Application

```bash
# Frontend (browser)
open http://localhost:3000

# Backend health
curl http://localhost:8080/health

# Backend products
curl http://localhost:8080/products

# ML recommendations
curl http://localhost:5000/recommendations/42
```

### Step 4: Stop

```bash
docker-compose down        # Stop containers
docker-compose down -v    # Stop and remove volumes (resets database)
```

---

## Deploying to Kubernetes (Azure)

### Phase 1: Prerequisites & Infrastructure

#### 1.1 Login to Azure

```bash
az login
az account set --subscription "<your-subscription-id>"
```

#### 1.2 Configure Terraform Variables

```bash
cd infrastructure/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
subscription_id     = "your-azure-subscription-id"
project_name        = "shopmicro"
location            = "eastus"
resource_group_name = "shopmicro-rg"
acr_name            = "shopmicrocr"        # Must be globally unique!
aks_name            = "shopmicro-aks"
dns_prefix          = "shopmicro"
node_count          = 2
node_size           = "Standard_B2s_v2"
node_pool           = "default"
environment_name    = "prod"
keyvault_name       = "shopmicro-kv"       # Must be globally unique!
```

#### 1.3 Deploy Infrastructure

```bash
cd infrastructure/terraform
terraform init
terraform plan        # Review the plan
terraform apply       # Type "yes" to confirm
```

This creates:
- Resource Group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS)
- Azure Key Vault

**Save the outputs!** You'll need:
- `acr_login_server` (e.g., `shopmicrocr.azurecr.io`)
- `aks_name` (e.g., `shopmicro-aks`)
- `rg_name` (e.g., `shopmicro-rg`)

#### 1.4 Get Kubernetes Credentials

```bash
az aks get-credentials \
  --resource-group <rg-name> \
  --name <aks-name> \
  --overwrite-existing
```

#### 1.5 Enable Key Vault CSI Provider

```bash
az aks enable-addons \
  --addons azure-keyvault-secrets-provider \
  --name <aks-name> \
  --resource-group <rg-name>
```

---

### Phase 2: Build & Push Images

#### 2.1 Login to ACR

```bash
az acr login --name <acr-name>
```

#### 2.2 Build and Push Images

```bash
# Backend
docker build -t <acr-login-server>/shopmicro-backend:latest ./backend
docker push <acr-login-server>/shopmicro-backend:latest

# Frontend
docker build -t <acr-login-server>/shopmicro-frontend:latest ./frontend
docker push <acr-login-server>/shopmicro-frontend:latest

# ML Service
docker build -t <acr-login-server>/shopmicro-ml:latest ./ml-service
docker push <acr-login-server>/shopmicro-ml:latest
```

---

### Phase 3: Deploy to Kubernetes

#### 3.1 Update Image References

Edit the image URLs in `k8s/` manifests to point to your ACR:

```bash
# Update in k8s/backend/deployment.yaml
sed -i 's|shopmicroregistry.azurecr.io|<acr-login-server>|g' k8s/backend/deployment.yaml

# Update in k8s/frontend/deployment.yaml
sed -i 's|shopmicroregistry.azurecr.io|<acr-login-server>|g' k8s/frontend/deployment.yaml

# Update in k8s/ml-service/deployment.yaml
sed -i 's|shopmicroregistry.azurecr.io|<acr-login-server>|g' k8s/ml-service/deployment.yaml
```

#### 3.2 Update Key Vault References

Edit `k8s/backend/secret-provider-class.yaml` with your Azure values:
- `tenantId`: Your Azure tenant ID
- `clientId`: Service principal client ID
- `keyvaultName`: Your key vault name
- `subscriptionId`: Your subscription ID
- `resourceGroup`: Your resource group name

#### 3.3 Deploy

```bash
# Apply all Kubernetes resources
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/

# Check deployment status
kubectl get pods -n shopmicro
kubectl get svc -n shopmicro
```

Wait for pods to be ready:
```bash
kubectl rollout status deployment/backend -n shopmicro
kubectl rollout status deployment/frontend -n shopmicro
kubectl rollout status deployment/ml-service -n shopmicro
```

---

### Phase 4: Access the Application

#### 4.1 Get Ingress IP

```bash
kubectl get ingress -n shopmicro
```

The `ADDRESS` column shows your external IP.

#### 4.2 Configure DNS (Optional)

Add to your hosts file (`/etc/hosts` on Linux/Mac, `C:\Windows\System32\drivers\etc\hosts` on Windows):

```
<ingress-ip> shopmicro.example.com
```

#### 4.3 Access

- **Frontend**: http://shopmicro.example.com
- **Backend API**: http://shopmicro.example.com/api
- **ML Service**: http://shopmicro.example.com/ml

---

## Health Check

### Using the CLI Tool

```bash
# Basic check
./scripts/healthcheck.sh -n shopmicro

# Verbose with pod details
./scripts/healthcheck.sh -n shopmicro -v

# Check service URLs
./scripts/healthcheck.sh -n shopmicro -u

# Show recent events
./scripts/healthcheck.sh -n shopmicro -e
```

### Manual Checks

```bash
# Check pods
kubectl get pods -n shopmicro

# Check services
kubectl get svc -n shopmicro

# Check ingress
kubectl get ingress -n shopmicro

# View logs
kubectl logs -l app=backend -n shopmicro -f

# Port forward for testing
kubectl port-forward svc/backend 8080:8080 -n shopmicro
```

---

## Rollback Procedure

If something goes wrong after a deployment:

```bash
# Check deployment history
kubectl rollout history deployment/backend -n shopmicro

# Rollback to previous version
kubectl rollout undo deployment/backend -n shopmicro

# Verify rollback
kubectl rollout status deployment/backend -n shopmicro --timeout=120s
```

---

## CI/CD (GitHub Actions)

The `.github/workflows/` folder contains:

| Workflow | Purpose |
|----------|---------|
| `ci-cd.yaml` | Main pipeline: lint → test → build → deploy |
| `terraform-drift.yaml` | Daily infrastructure drift detection |
| `policy-check.yaml` | Security policy validation |

### Setup GitHub Secrets

In your GitHub repository settings, add these secrets:

| Secret | Value |
|--------|-------|
| `AZURE_CR_USERNAME` | ACR username |
| `AZURE_CR_PASSWORD` | ACR password |
| `AZURE_SP_CREDENTIALS` | Service principal JSON |
| `TF_API_TOKEN` | Terraform Cloud token |
| `TF_STATE_RG` | Resource group for TF state |
| `TF_STATE_SA` | Storage account for TF state |

---

## Troubleshooting

### Pods Not Starting

```bash
# Check pod events
kubectl describe pod <pod-name> -n shopmicro

# Check logs
kubectl logs <pod-name> -n shopmicro --previous
```

### Image Pull Errors

```bash
# Verify image exists in ACR
az acr repository list --name <acr-name>

# Check image tag
az acr repository show --name <acr-name> --image shopmicro-backend:latest
```

### Database Connection

```bash
# Check if PostgreSQL is running
kubectl get pods -n shopmicro -l app=postgres

# Test connection
kubectl exec -it <postgres-pod> -n shopmicro -- psql -U postgres -c "SELECT 1"
```

### Reset Everything

```bash
# Delete all resources
kubectl delete namespace shopmicro
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
```

---

## What's Next?

- See [Documentation.md](./Documentation.md) for detailed architecture and technical explanations
- Configure a custom domain (see ingress annotations)
- Set up monitoring dashboards in Grafana
- Add more services or features
