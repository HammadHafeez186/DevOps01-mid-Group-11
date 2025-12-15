#!/bin/bash

# Monitoring Stack Setup Script for DevOps Articles
# This script automates the deployment of Prometheus and Grafana monitoring

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="monitoring"
PROMETHEUS_VERSION="v2.45.0"
GRAFANA_VERSION="10.0.3"
RETENTION_DAYS="30d"
STORAGE_SIZE="20Gi"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   DevOps Articles - Monitoring Stack Setup    ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    if ! command -v helm &> /dev/null; then
        print_info "Helm not found. Will use kubectl for deployment."
        USE_HELM=false
    else
        print_status "Helm is installed"
        USE_HELM=true
    fi
    
    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    print_status "Prerequisites check completed"
}

# Create namespace
create_namespace() {
    print_info "Creating namespace: $NAMESPACE"
    
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        print_info "Namespace $NAMESPACE already exists"
    else
        kubectl create namespace $NAMESPACE
        print_status "Namespace $NAMESPACE created"
    fi
    
    # Label namespace for monitoring
    kubectl label namespace $NAMESPACE monitoring=enabled --overwrite
}

# Deploy Prometheus
deploy_prometheus() {
    print_info "Deploying Prometheus..."
    
    cd "$(dirname "$0")"
    
    # Apply Prometheus configurations
    kubectl apply -f 00-namespace.yaml
    kubectl apply -f 01-prometheus-config.yaml
    
    if [ -f "prometheus-rules.yaml" ]; then
        kubectl apply -f prometheus-rules.yaml
        print_status "Prometheus rules applied"
    fi
    
    kubectl apply -f 02-prometheus-deployment.yaml
    
    # Wait for Prometheus to be ready
    print_info "Waiting for Prometheus to be ready..."
    kubectl wait --for=condition=ready pod -l app=prometheus -n $NAMESPACE --timeout=300s
    
    print_status "Prometheus deployed successfully"
}

# Deploy Grafana
deploy_grafana() {
    print_info "Deploying Grafana..."
    
    kubectl apply -f 03-grafana-deployment.yaml
    
    # Wait for Grafana to be ready
    print_info "Waiting for Grafana to be ready..."
    kubectl wait --for=condition=ready pod -l app=grafana -n $NAMESPACE --timeout=300s
    
    print_status "Grafana deployed successfully"
}

# Import Grafana dashboards
import_dashboards() {
    print_info "Importing Grafana dashboards..."
    
    # Get Grafana pod name
    GRAFANA_POD=$(kubectl get pods -n $NAMESPACE -l app=grafana -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$GRAFANA_POD" ]; then
        print_error "Grafana pod not found"
        return 1
    fi
    
    # Copy dashboard files to Grafana pod
    if [ -f "grafana-app-dashboard.json" ]; then
        kubectl cp grafana-app-dashboard.json $NAMESPACE/$GRAFANA_POD:/tmp/app-dashboard.json
        print_status "Application dashboard imported"
    fi
    
    if [ -f "grafana-infra-dashboard.json" ]; then
        kubectl cp grafana-infra-dashboard.json $NAMESPACE/$GRAFANA_POD:/tmp/infra-dashboard.json
        print_status "Infrastructure dashboard imported"
    fi
}

# Configure ServiceMonitor for application
configure_service_monitors() {
    print_info "Configuring ServiceMonitors..."
    
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: app-metrics
  namespace: devops-articles
  labels:
    app: devops-articles
spec:
  selector:
    app: devops-articles
    component: app
  ports:
  - name: metrics
    port: 3000
    targetPort: 3000
EOF
    
    print_status "ServiceMonitor configured"
}

# Display access information
display_access_info() {
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}           Access Information                   ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    # Get Prometheus service
    PROM_SERVICE=$(kubectl get svc prometheus -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    if [ -z "$PROM_SERVICE" ]; then
        PROM_SERVICE=$(kubectl get svc prometheus -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    fi
    
    if [ -z "$PROM_SERVICE" ]; then
        print_info "Prometheus: Use port-forward to access"
        echo "  kubectl port-forward -n $NAMESPACE svc/prometheus 9090:9090"
        echo "  Then access: http://localhost:9090"
    else
        print_status "Prometheus: http://$PROM_SERVICE:9090"
    fi
    
    echo ""
    
    # Get Grafana service
    GRAFANA_SERVICE=$(kubectl get svc grafana -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    if [ -z "$GRAFANA_SERVICE" ]; then
        GRAFANA_SERVICE=$(kubectl get svc grafana -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    fi
    
    if [ -z "$GRAFANA_SERVICE" ]; then
        print_info "Grafana: Use port-forward to access"
        echo "  kubectl port-forward -n $NAMESPACE svc/grafana 3000:3000"
        echo "  Then access: http://localhost:3000"
    else
        print_status "Grafana: http://$GRAFANA_SERVICE:3000"
    fi
    
    echo ""
    print_info "Grafana Default Credentials:"
    echo "  Username: admin"
    echo "  Password: admin123"
    echo ""
    
    print_status "Monitoring stack setup completed!"
}

# Verify deployment
verify_deployment() {
    print_info "Verifying deployment..."
    
    echo ""
    echo "Prometheus Pods:"
    kubectl get pods -n $NAMESPACE -l app=prometheus
    
    echo ""
    echo "Grafana Pods:"
    kubectl get pods -n $NAMESPACE -l app=grafana
    
    echo ""
    echo "Services:"
    kubectl get svc -n $NAMESPACE
    
    echo ""
}

# Main execution
main() {
    check_prerequisites
    create_namespace
    deploy_prometheus
    deploy_grafana
    import_dashboards
    configure_service_monitors
    verify_deployment
    display_access_info
}

# Run main function
main
