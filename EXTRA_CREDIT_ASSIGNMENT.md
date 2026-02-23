# Extra Credit Assignment: Zero-Downtime Multi-Environment Delivery Challenge (Self-Contained)

## 1. Objective
Extend your capstone into an advanced platform engineering challenge focused on reliability, governance, and operational excellence.

## 2. Scenario
You must support **dev, staging, and prod** with safe releases, automatic verification, and policy enforcement. A failed deployment must self-detect and recover with minimal user impact.

## 3. Required Work

### A. Progressive Delivery
1. Implement **blue/green** or **canary** deployment for backend service.
2. Add automated promotion/rollback gates based on SLO signals (error rate, latency, availability).
3. Document blast-radius reduction strategy.

### B. Advanced Reliability Engineering
1. Define and run at least **2 chaos experiments** (example: pod kill, dependency latency, DB failover simulation).
2. Capture MTTD and MTTR from telemetry.
3. Provide a post-incident report with timeline and corrective actions.

### C. Platform Security Hardening
1. Add Kubernetes network policies for service-to-service restrictions.
2. Add admission/policy controls (OPA Gatekeeper/Kyverno/Conftest policy gates).
3. Add image/security scanning in CI.
4. Add secret-rotation workflow and verification evidence.

### D. Cost and Capacity Engineering
1. Provide environment-level cost estimate and optimization plan.
2. Implement autoscaling tuning using observed traffic profiles.
3. Show before/after resource utilization and cost impact.

### E. Developer Experience Automation
Build an internal developer command surface (`make`, Go CLI, or task runner) supporting:
- bootstrap
- validate
- deploy
- rollback
- smoke-test
- evidence-pack

## 4. Deliverables
1. `EXTRA_CREDIT_REPORT.md` including architecture deltas, experiment results, and lessons learned.
2. CI/CD workflow updates proving progressive delivery and security gating.
3. Policy files and enforcement outputs.
4. Chaos test scripts/manifests and telemetry screenshots.
5. Cost analysis artifact (`costs.md` or report export).

## 4.1 Required Report Structure (Mandatory)
Your `EXTRA_CREDIT_REPORT.md` must include:
1. Initial state vs improved state architecture
2. Release strategy selected (canary or blue/green) and why
3. Automated promotion/rollback rules
4. Chaos experiment design and expected outcomes
5. Chaos results with metrics (MTTD, MTTR, error budget impact)
6. Security controls added and proof of enforcement
7. Cost/capacity changes and before/after evidence
8. Risks, trade-offs, and future improvements

## 5. Scoring (50 points)
- Progressive delivery correctness and rollback safety: 15
- Chaos engineering rigor and incident analysis: 10
- Security hardening depth: 10
- Cost/capacity optimization quality: 10
- Developer experience automation polish: 5

## 6. Success Criteria
- Production deployment can be promoted with measurable confidence.
- Failure scenarios are detected quickly and recovered automatically or via runbook.
- Security and compliance controls are enforced in pipeline and cluster.
- Platform changes improve both resilience and operational efficiency.

## 7. Submission Format
Submit:
- Updated repository with all code/config changes
- `EXTRA_CREDIT_REPORT.md` (required)
- Optional demo recording (5-8 minutes) showing rollout and rollback behavior

## 8. Recommended Timebox
- **8-12 additional hours** beyond the main capstone.

## 9. Appendix: Minimal Starter Snippets (Optional)
Use these if you need a very small baseline before implementing advanced delivery.

### 9.1 Backend Health Endpoint (`backend/server.js`)
```javascript
const express = require("express");
const app = express();
app.get("/health", (_req, res) => res.json({ status: "ok", service: "backend" }));
app.get("/version", (_req, res) => res.json({ version: process.env.APP_VERSION || "v1" }));
app.listen(8080, () => console.log("backend on 8080"));
```

### 9.2 ML Service Endpoint (`ml-service/app.py`)
```python
from flask import Flask, jsonify
app = Flask(__name__)

@app.get("/health")
def health():
    return jsonify({"status": "ok", "service": "ml-service"})

app.run(host="0.0.0.0", port=5000)
```

### 9.3 Frontend Endpoint Usage (`frontend/src/App.jsx`)
```jsx
export default function App() {
  return <h1>ShopMicro Frontend - Extra Credit Track</h1>;
}
```

### 9.4 Canary-Style Ingress Split Example
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "20"
spec:
  rules:
  - host: shopmicro.local
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-v2
            port:
              number: 8080
```
