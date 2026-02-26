# Evidence

This directory contains artifacts and evidence from deployments, tests, and demonstrations.

## Required Screenshots (Capture These)

| File | How to Capture |
|------|----------------|
| `deployment-pods.png` | `kubectl get pods -n shopmicro` |
| `deployment-services.png` | `kubectl get svc -n shopmicro` |
| `tls-certificate.png` | `kubectl get certificate -n shopmicro` |
| `frontend-screenshot.png` | Visit https://your-domain in browser |
| `api-response.png` | `curl https://your-domain/api/products` |
| `github-actions-pipeline.png` | GitHub → Actions → Latest run |
| `grafana-dashboard.png` | Visit https://your-domain/monitor |

## Commands to Run

```bash
# 1. Get pod status
kubectl get pods -n shopmicro -o wide

# 2. Get services
kubectl get svc -n shopmicro

# 3. Get TLS certificate
kubectl get certificate -n shopmicro

# 4. Test API
curl https://your-domain/api/products

# 5. Test ML service  
curl https://your-domain/ml/recommendations/42

# 6. Access Grafana (monitoring)
# URL: https://your-domain/monitor
# Login: admin / changeme-secure-password
```

## Rollback Evidence

To demonstrate rollback capability:

```bash
# 1. Show deployment history
kubectl rollout history deployment/backend -n shopmicro

# 2. Take screenshot of history output - save as rollback-history.png

# 3. Rollback to previous version
kubectl rollout undo deployment/backend -n shopmicro

# 4. Take screenshot of rollback command - save as rollback-executed.png

# 5. Verify rollback
kubectl rollout status deployment/backend -n shopmicro --timeout=120s

# 6. Take screenshot of verified status - save as rollback-verified.png
```

## Testing

```bash
# Run linting
npm run lint

# Run tests
npm test
```
