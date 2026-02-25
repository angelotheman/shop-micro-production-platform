#!/bin/bash

NAMESPACE="${NAMESPACE:-shopmicro}"
VERBOSE="${VERBOSE:-false}"
KUBCONFIG="${KUBCONFIG:-}"

check_prereqs() {
    local missing=0
    
    if ! command -v kubectl &> /dev/null; then
        echo "ERROR: kubectl is not installed"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        echo "Please install missing prerequisites"
        exit 1
    fi
}

get_kubeconfig() {
    if [ -n "$KUBCONFIG" ]; then
        echo "--kubeconfig=$KUBCONFIG"
    elif [ -n "$KUBECONFIG" ]; then
        echo "--kubeconfig=$KUBECONFIG"
    fi
}

check_pods() {
    echo "=== Pod Status in namespace '$NAMESPACE' ==="
    
    local pods
 get pods -n    pods=$(kubectl "$NAMESPACE" $(get_kubeconfig) -o json 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Cannot connect to cluster. Check kubeconfig."
        return 1
    fi
    
    echo "$pods" | jq -r '.items[] | "\(.metadata.name) - \(.status.phase)"' 2>/dev/null || \
        kubectl get pods -n "$NAMESPACE" $(get_kubeconfig)
    
    echo ""
    echo "=== Deployment Status ==="
    kubectl get deployments -n "$NAMESPACE" $(get_kubeconfig)
}

check_services() {
    echo "=== Services in namespace '$NAMESPACE' ==="
    kubectl get svc -n "$NAMESPACE" $(get_kubeconfig)
}

check_health() {
    local url="$1"
    if [ -z "$url" ]; then
        echo "ERROR: URL required"
        return 1
    fi
    
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$status_code" -lt 500 ]; then
        echo "$url: HEALTHY (HTTP $status_code)"
    else
        echo "$url: UNHEALTHY (HTTP $status_code)"
    fi
}

check_urls() {
    echo "=== URL Health Checks ==="
    
    local urls=(
        "http://frontend.shopmicro.svc.cluster.local:80/health"
        "http://backend.shopmicro.svc.cluster.local:8080/health"
        "http://ml-service.shopmicro.svc.cluster.local:5000/health"
    )
    
    for url in "${urls[@]}"; do
        if [ "$VERBOSE" = "true" ]; then
            echo "Checking $url..."
        fi
        check_health "$url" 2>/dev/null || echo "$url: UNREACHABLE"
    done
}

check_events() {
    echo "=== Recent Events in namespace '$NAMESPACE' ==="
    kubectl get events -n "$NAMESPACE" $(get_kubeconfig) --sort-by='.lastTimestamp' | tail -20
}

show_usage() {
    cat << EOF
ShopMicro Health Check CLI

Usage: $0 [OPTIONS]

OPTIONS:
    -n, --namespace NAMESPACE    Kubernetes namespace (default: shopmicro)
    -v, --verbose               Verbose output
    -k, --kubeconfig PATH       Path to kubeconfig file
    -u, --urls                  Check service URLs
    -e, --events                Show recent events
    -h, --help                  Show this help message

EXAMPLES:
    $0                          Check pods and services
    $0 -n shopmicro -v          Verbose check
    $0 -u                       Check service URLs
    $0 -e                       Show events
    $0 -k ~/.kube/config        Use specific kubeconfig

ENVIRONMENT VARIABLES:
    NAMESPACE       Kubernetes namespace
    VERBOSE         Set to 'true' for verbose output
    KUBCONFIG       Path to kubeconfig file
EOF
}

main() {
    check_prereqs
    
    local check_urls_flag=false
    local check_events_flag=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE="true"
                shift
                ;;
            -k|--kubeconfig)
                KUBCONFIG="$2"
                shift 2
                ;;
            -u|--urls)
                check_urls_flag=true
                shift
                ;;
            -e|--events)
                check_events_flag=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    echo "============================================"
    echo "  ShopMicro Platform Health Check"
    echo "============================================"
    echo "Namespace: $NAMESPACE"
    echo "Time: $(date)"
    echo ""
    
    check_pods
    echo ""
    check_services
    
    if [ "$check_urls_flag" = true ]; then
        check_urls
    fi
    
    if [ "$check_events_flag" = true ]; then
        check_events
    fi
    
    echo ""
    echo "=== Health Check Complete ==="
}

main "$@"
