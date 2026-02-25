# Observability

This directory contains Grafana dashboards, alert rules, and OpenTelemetry configuration.

## Structure

```
observability/
├── dashboards/           # Grafana dashboard JSON exports
│   ├── platform-overview.json
│   ├── service-health.json
│   └── logs-traces.json
├── otel/                 # OpenTelemetry collector config
│   └── collector-config.yaml
├── alerts.yaml           # Prometheus alert rules
└── SLI_SLO.md           # Service Level Indicators & Objectives
```

## Dashboards

### 1. Platform Overview (`platform-overview.json`)
- Total request rate
- Pod restarts
- CPU/Memory usage by pod

### 2. Service Health (`service-health.json`)
- Service uptime status
- Error rate percentage
- P95 latency
- Requests by service

### 3. Logs & Traces (`logs-traces.json`)
- Live log viewer
- Distributed traces
- Log/trace correlation

## Importing Dashboards

1. Port-forward Grafana:
   ```bash
   kubectl port-forward -n monitoring svc/grafana 3000:3000
   ```

2. Open http://localhost:3000

3. Go to Dashboards → Import → Paste JSON content

## Alert Rules

The `alerts.yaml` contains Prometheus alert definitions:

| Alert | Condition | Severity |
|-------|-----------|----------|
| HighErrorRate | > 5% errors for 5m | critical |
| HighLatency | P95 > 1s for 5m | warning |
| PodNotReady | Pod not ready for 3m | warning |
| HighMemoryUsage | Memory > 90% for 5m | warning |

## OpenTelemetry Collector

The collector config (`otel/collector-config.yaml`) configures:
- **Receivers**: OTLP, Prometheus
- **Processors**: Batch, Memory Limiter
- **Exporters**: Prometheus, Loki (logs), Tempo (traces)

## SLIs & SLOs

See `SLI_SLO.md` for detailed definitions of:
- Availability (target: > 99.5%)
- Latency (target: P95 < 500ms)
- Error Rate (target: < 1%)
