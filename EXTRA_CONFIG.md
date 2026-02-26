# Extra Credit Configuration Guide

This document tracks the implementation of the EXTRA_CREDIT_ASSIGNMENT requirements.

---

## Status Overview

| Section | Requirement | Status |
|---------|-------------|--------|
| A | Progressive Delivery | [ ] |
| B | Chaos Engineering | [ ] |
| C | Security Hardening | [ ] |
| D | Cost & Capacity | [ ] |
| E | Developer Experience | [ ] |

---

## A. Progressive Delivery

### Requirements
1. Implement **blue/green** or **canary** deployment for backend service
2. Add automated promotion/rollback gates based on SLO signals
3. Document blast-radius reduction strategy

### Implementation Notes
- 

---

## B. Chaos Engineering

### Requirements
1. Run at least **2 chaos experiments** (pod kill, latency, DB failover)
2. Capture MTTD and MTTR from telemetry
3. Provide post-incident report

### Implementation Notes
- 

---

## C. Platform Security Hardening

### Requirements
1. Add Kubernetes network policies for service-to-service restrictions
2. Add admission/policy controls (OPA Gatekeeper/Kyverno/Conftest)
3. Add image/security scanning in CI
4. Add secret-rotation workflow

### Implementation Notes
- NetworkPolicy already exists for backend
- Policy checking exists in CI/CD

---

## D. Cost and Capacity Engineering

### Requirements
1. Environment-level cost estimate and optimization plan
2. Autoscaling tuning using observed traffic profiles
3. Show before/after resource utilization and cost impact

### Implementation Notes
- HPA already configured

---

## E. Developer Experience Automation

### Requirements
Build CLI supporting:
- [ ] bootstrap
- [ ] validate
- [ ] deploy
- [ ] rollback
- [ ] smoke-test
- [ ] evidence-pack

### Implementation Notes
- 

---

## Deliverables Checklist

- [ ] EXTRA_CREDIT_REPORT.md (final report)
- [ ] CI/CD workflow updates
- [ ] Policy files
- [ ] Chaos test scripts
- [ ] Cost analysis

---

## Getting Started

To start implementing extra credit:

```bash
# 1. Create environments (dev, staging, prod) in Kubernetes
# 2. Set up canary deployment
# 3. Add chaos experiments
# 4. Implement developer CLI
```
