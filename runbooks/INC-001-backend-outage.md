# Incident Runbook: Backend Service Outage

## Incident Summary
- **Incident ID**: INC-001
- **Severity**: Critical
- **Duration**: TBD
- **Impact**: Users cannot access the ShopMicro application

## Symptoms
- Frontend returns 502/503 errors
- Backend health endpoint returns failures
- High error rate in Grafana alerts

## Detection
1. **Alert**: HighErrorRate alert fired (>5% errors)
2. **Alert**: PodNotReady alert fired
3. **User Report**: Customer reports site is down

---

## Investigation Steps

### Step 1: Check Pod Status
```bash
kubectl get pods -n shopmicro
kubectl describe pod <backend-pod-name> -n shopmicro
```

### Step 2: Check Logs
```bash
kubectl logs <backend-pod-name> -n shopmicro --previous
kubectl logs -l app=backend -n shopmicro --tail=100
```

### Step 3: Check Events
```bash
kubectl get events -n shopmicro --sort-by='.lastTimestamp'
```

### Step 4: Check Resource Usage
```bash
kubectl top pods -n shopmicro
kubectl top nodes
```

### Step 5: Check Database Connectivity
```bash
kubectl exec -it <backend-pod-name> -n shopmicro -- nc -zv postgres 5432
```

### Step 6: Check Redis Connectivity
```bash
kubectl exec -it <backend-pod-name> -n shopmicro -- nc -zv redis 6379
```

---

## Resolution Procedures

### Scenario A: Pod CrashLoopBackOff
**Cause**: Application crash or resource exhaustion

**Resolution**:
```bash
# Check detailed pod status
kubectl describe pod <pod-name> -n shopmicro

# If OOMKilled, increase memory limit
kubectl patch deployment backend -n shopmicro -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","resources":{"limits":{"memory":"512Mi"}}}]}}}}'

# Restart the deployment
kubectl rollout restart deployment/backend -n shopmicro
```

### Scenario B: Database Connection Failure
**Cause**: PostgreSQL unavailable or credentials invalid

**Resolution**:
```bash
# Check Postgres status
kubectl get pods -n shopmicro -l app=postgres

# Check Secret exists
kubectl get secret backend-secret -n shopmicro

# If secret missing, recreate:
kubectl apply -f k8s/backend/secret.yaml

# Restart backend pods
kubectl rollout restart deployment/backend -n shopmicro
```

### Scenario C: Network Policy Blocked
**Cause**: Service-to-service communication blocked

**Resolution**:
```bash
# Check network policies
kubectl get networkpolicies -n shopmicro

# If blocking, temporarily disable or fix policy
kubectl delete networkpolicy <policy-name> -n shopmicro
```

---

## Rollback Procedure
If the issue is caused by a recent deployment:
```bash
# Check deployment history
kubectl rollout history deployment/backend -n shopmicro

# Rollback to previous version
kubectl rollout undo deployment/backend -n shopmicro

# Verify rollback
kubectl rollout status deployment/backend -n shopmicro --timeout=120s
```

---

## Post-Incident Actions
1. Document root cause in incident report
2. Update this runbook if gaps found
3. Create follow-up tickets for preventive measures
4. Conduct blameless post-mortem meeting

---

## Escalation Contacts
- **Primary On-Call**: [Add your name/contact]
- **Secondary On-Call**: [Add your name/contact]
- **Engineering Lead**: [Add your name/contact]
- **Emergency Contact**: [Add emergency number]
