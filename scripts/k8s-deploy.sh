#!/bin/bash
# Quick K8s deployment script

set -e

NAMESPACE="devops-articles"
CONTEXT="${1:-minikube}"

echo "🚀 Deploying DevOps Articles to Kubernetes..."
echo "Context: $CONTEXT"
echo "Namespace: $NAMESPACE"

# Set context
echo "📌 Setting kubectl context to $CONTEXT..."
kubectl config use-context "$CONTEXT"

# Verify cluster is accessible
echo "✅ Verifying cluster access..."
kubectl cluster-info

# Deploy
echo "📦 Deploying manifests..."
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-configmap.yaml
kubectl apply -f k8s/02-secret.yaml
kubectl apply -f k8s/03-postgres-storage.yaml
kubectl apply -f k8s/04-postgres-statefulset.yaml
kubectl apply -f k8s/05-postgres-service.yaml
kubectl apply -f k8s/06-app-deployment.yaml
kubectl apply -f k8s/07-app-service.yaml
kubectl apply -f k8s/08-hpa.yaml

echo ""
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=devops-articles -n $NAMESPACE --timeout=300s || true

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Resources status:"
kubectl get all -n $NAMESPACE

echo ""
echo "🌐 Service Information:"
kubectl get svc app-service -n $NAMESPACE

if [ "$CONTEXT" = "minikube" ]; then
    echo ""
    echo "🔗 To access the app locally:"
    echo "   minikube service app-service -n $NAMESPACE"
    echo ""
    echo "   Or use port-forward:"
    echo "   kubectl port-forward svc/app-service 8080:80 -n $NAMESPACE"
fi

echo ""
echo "📝 View logs:"
echo "   kubectl logs -f deployment/app -n $NAMESPACE"
echo ""
echo "🔍 View pod details:"
echo "   kubectl describe pods -n $NAMESPACE"
