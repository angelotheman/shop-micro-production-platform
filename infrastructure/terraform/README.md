# Infrastructure as Code (Terraform)

This directory contains Terraform configurations to provision the cloud infrastructure on Azure.

## Structure

```
infrastructure/terraform/
├── main.tf              # Root module - orchestrates all resources
├── variables.tf         # Input variables
├── outputs.tf           # Output values after apply
├── providers.tf         # Azure provider config
├── terraform.tfvars     # Variable values (copy from example)
├── terraform.tfvars.example  # Template for tfvars
├── .terraform/          # Terraform working directory (auto-created)
└── modules/
    ├── acr/             # Azure Container Registry
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

## What Gets Created

| Resource | Description |
|----------|-------------|
| Resource Group | Container for all resources |
| ACR | Docker image registry |
| AKS | Managed Kubernetes cluster |
| Key Vault | Secret storage |

## Usage

```bash
cd infrastructure/terraform

# 1. Copy example vars
cp terraform.tfvars.example terraform.tfvars

# 2. Edit with your values
vim terraform.tfvars

# 3. Initialize
terraform init

# 4. Plan (preview)
terraform plan

# 5. Apply (creates resources)
terraform apply

# 6. Output (show results)
terraform output
```

## Required Variables

```hcl
subscription_id     = "your-subscription-id"
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

## Outputs

After `terraform apply`, you'll get:
- `rg_name` - Resource group name
- `acr_name` - Container registry name
- `acr_login_server` - Full ACR login server URL
- `aks_name` - Kubernetes cluster name
- `aks_get_credentials_command` - Command to get kubeconfig
- `key_vault_name` - Key Vault name
- `key_vault_uri` - Key Vault URI

## Cleanup

```bash
terraform destroy
```

**Warning:** This will delete all resources including any data in databases!
