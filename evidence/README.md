# Evidence

This directory contains artifacts and evidence from deployments, tests, and demonstrations.

## Contents

### Required Screenshots (Capture These)

| File | How to Capture |
|------|----------------|
| `deployment-pods.png` | `kubectl get pods -n shopmicro` |
| `deployment-services.png` | `kubectl get svc -n shopmicro` |
| `tls-certificate.png` | `kubectl get certificate -n shopmicro` |
| `frontend-screenshot.png` | Visit https://shopmicro.example.dns in browser |
| `api-response.png` | `curl https://shopmicro.example.dns/api/products` |
| `github-actions-pipeline.png` | GitHub → Actions → Latest run |
| `grafana-dashboard.png` | Access Grafana via port-forward |

### Commands to Run

```bash
# 1. Get pod status
kubectl get pods -n shopmicro -o wide

# 2. Get services
kubectl get svc -n shopmicro

# 3. Get TLS certificate
kubectl get certificate -n shopmicro

# 4. Test API
curl https://shopmicro.example.dns/api/products

# 5. Test ML service  
curl https://shopmicro.example.dns/ml/recommendations/42

# 6. Access Grafana (monitoring)
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Then open http://localhost:3000 (admin/admin123)
```

### Rollback Evidence

```bash
# Show deployment history
kubectl rollout history deployment/backend -n shopmicro

# Rollback to previous version
kubectl rollout undo deployment/backend -n shopmicro

# Verify rollback
kubectl rollout status deployment/backend -n shopmicro --timeout=120s
```

### Test Results

```bash
# Run linting
npm run lint

# Run tests
npm test

# Save output
npm test > evidence/test-results.txt
```
