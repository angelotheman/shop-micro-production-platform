# Runbooks

This directory contains incident response runbooks for the ShopMicro platform.

## Available Runbooks

### INC-001: Backend Service Outage

**Severity:** Critical

**Symptoms:**
- Frontend returns 502/503 errors
- Backend health endpoint fails
- High error rate in Grafana

**Runbook:** [INC-001-backend-outage.md](./INC-001-backend-outage.md)

#### Quick Commands

```bash
# Check pod status
kubectl get pods -n shopmicro

# View logs
kubectl logs -l app=backend -n shopmicro --tail=100

# Describe problematic pod
kubectl describe pod <pod-name> -n shopmicro

# Rollback deployment
kubectl rollout undo deployment/backend -n shopmicro

# Check events
kubectl get events -n shopmicro --sort-by='.lastTimestamp'
```

## Creating New Runbooks

Use this template:

```markdown
# Incident Runbook: [TITLE]

## Incident Summary
- **ID**: INC-XXX
- **Severity**: [Critical/High/Medium/Low]
- **Duration**: TBD

## Symptoms
- 

## Detection
1. 
2. 

## Investigation Steps
### Step 1: 

## Resolution Procedures
### Scenario A: 

## Rollback Procedure

## Post-Incident Actions
1. 
2. 

## Escalation Contacts
```

## Tips

- Keep runbooks actionable with copy-paste commands
- Include both symptoms and root causes
- Update after each incident
- Test runbooks periodically
