# SLI/SLO Definitions for ShopMicro

## Service Level Indicators (SLIs)

### 1. Availability (SLI-01)
- **Definition**: Percentage of successful HTTP requests
- **Formula**: `(total_requests - 5xx_errors) / total_requests * 100`
- **Target**: > 99.5%

### 2. Latency (SLI-02)
- **Definition**: P95 response time for API requests
- **Formula**: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))`
- **Target**: < 500ms

### 3. Error Rate (SLI-03)
- **Definition**: Percentage of requests that result in errors
- **Formula**: `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])`
- **Target**: < 1%

---

## Service Level Objectives (SLOs)

### SLO-01: API Availability
- **Target**: 99.5% over 30 days
- **Error Budget**: 0.5% = 3.6 hours downtime/month
- **SLI**: SLI-01

### SLO-02: API Latency
- **Target**: P95 < 500ms over 30 days
- **Error Budget**: 5% of requests can exceed threshold
- **SLI**: SLI-02
