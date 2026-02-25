# Scripts

This directory contains utility scripts for operating the ShopMicro platform.

## Scripts

### healthcheck.sh

A shell script to check the health of the Kubernetes deployment.

```bash
# Basic check
./scripts/healthcheck.sh -n shopmicro

# Verbose output with pod details
./scripts/healthcheck.sh -n shopmicro -v

# Check service URLs
./scripts/healthcheck.sh -n shopmicro -u

# Show recent events
./scripts/healthcheck.sh -n shopmicro -e

# Use specific kubeconfig
./scripts/healthcheck.sh -n shopmicro -k ~/.kube/config
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| NAMESPACE | Kubernetes namespace | shopmicro |
| VERBOSE | Enable verbose output | false |
| KUBCONFIG | Path to kubeconfig | ~/.kube/config |

### Examples

```bash
# Check specific namespace
NAMESPACE=my-namespace ./scripts/healthcheck.sh

# Combine options
./scripts/healthcheck.sh -n shopmicro -v -u -e

# Cron job example
*/5 * * * * /path/to/healthcheck.sh -n shopmicro >> /var/log/healthcheck.log
```
