# Evidence

This directory contains artifacts and evidence from deployments, tests, and demonstrations.

## Contents

This folder should contain:

### Deployment Outputs
- `terraform-apply-output.txt` - Output from `terraform apply`
- `kubectl-apply-output.txt` - Output from `kubectl apply`

### Test Results
- `lint-results.txt` - Linting output
- `test-results.txt` - Test output

### Dashboard Screenshots
- `platform-overview.png` - Platform dashboard screenshot
- `service-health.png` - Service health dashboard screenshot
- `logs-traces.png` - Logs/traces dashboard screenshot

### Rollback Proof
- `rollback-output.txt` - Rollback command output

## Capturing Evidence

### Terraform Output
```bash
terraform apply -auto-approve 2>&1 | tee evidence/terraform-apply-output.txt
```

### Kubernetes Deployment
```bash
kubectl apply -f k8s/ 2>&1 | tee evidence/kubectl-apply-output.txt

# Get rollout status
kubectl rollout status deployment/backend -n shopmicro 2>&1 | tee -a evidence/kubectl-apply-output.txt
```

### Lint Results
```bash
# Terraform
cd infrastructure/terraform && terraform validate > ../evidence/lint-results.txt

# YAML
for f in k8s/*.yaml k8s/*/*.yaml; do python3 -c "import yaml; yaml.safe_load(open('$f'))" 2>>evidence/lint-results.txt; done

# Shellcheck
shellcheck scripts/*.sh >> evidence/lint-results.txt
```

### Rollback
```bash
# Before rollback, note current version
kubectl rollout history deployment/backend -n shopmicro

# Execute rollback
kubectl rollout undo deployment/backend -n shopmicro 2>&1 | tee evidence/rollback-output.txt

# Verify
kubectl rollout status deployment/backend -n shopmicro --timeout=120s 2>&1 | tee -a evidence/rollback-output.txt
```

## Screenshots

Take screenshots of Grafana dashboards:
1. Platform Overview
2. Service Health
3. Logs & Traces

Save as PNG files in this directory.

## Naming Convention

Use descriptive names with dates:
- `dashboard-platform-overview-2026-02-25.png`
- `rollback-backend-2026-02-25.txt`
