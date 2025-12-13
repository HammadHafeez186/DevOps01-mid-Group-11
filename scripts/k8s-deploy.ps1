# Quick K8s deployment script for Windows PowerShell

param(
    [string]$Context = "minikube",
    [string]$Namespace = "devops-articles"
)

$ErrorActionPreference = "Stop"

Write-Host " Deploying DevOps Articles to Kubernetes..." -ForegroundColor Green
Write-Host "Context: $Context" -ForegroundColor Yellow
Write-Host "Namespace: $Namespace" -ForegroundColor Yellow
Write-Host ""

# Set context
Write-Host " Setting kubectl context to $Context..." -ForegroundColor Cyan
kubectl config use-context $Context

# Verify cluster is accessible
Write-Host " Verifying cluster access..." -ForegroundColor Cyan
kubectl cluster-info

# Deploy manifests
Write-Host " Deploying manifests..." -ForegroundColor Cyan
Write-Host "   00-namespace.yaml" -ForegroundColor Gray
kubectl apply -f k8s/00-namespace.yaml

Write-Host "   01-configmap.yaml" -ForegroundColor Gray
kubectl apply -f k8s/01-configmap.yaml

Write-Host "   02-secret.yaml" -ForegroundColor Gray
kubectl apply -f k8s/02-secret.yaml

Write-Host "   03-postgres-storage.yaml" -ForegroundColor Gray
kubectl apply -f k8s/03-postgres-storage.yaml

Write-Host "   04-postgres-statefulset.yaml" -ForegroundColor Gray
kubectl apply -f k8s/04-postgres-statefulset.yaml

Write-Host "   05-postgres-service.yaml" -ForegroundColor Gray
kubectl apply -f k8s/05-postgres-service.yaml

Write-Host "   06-app-deployment.yaml" -ForegroundColor Gray
kubectl apply -f k8s/06-app-deployment.yaml

Write-Host "   07-app-service.yaml" -ForegroundColor Gray
kubectl apply -f k8s/07-app-service.yaml

Write-Host "   08-hpa.yaml" -ForegroundColor Gray
kubectl apply -f k8s/08-hpa.yaml

Write-Host ""
Write-Host " Waiting for pods to be ready (timeout: 5 minutes)..." -ForegroundColor Cyan
kubectl wait --for=condition=ready pod -l app=devops-articles -n $Namespace --timeout=300s | Out-Null 2>&1

Write-Host ""
Write-Host " Deployment complete!" -ForegroundColor Green
Write-Host ""

Write-Host " Resources status:" -ForegroundColor Yellow
kubectl get all -n $Namespace
Write-Host ""

Write-Host " Service Information:" -ForegroundColor Yellow
kubectl get svc app-service -n $Namespace
Write-Host ""

if ($Context -eq "minikube") {
    Write-Host " To access the app locally:" -ForegroundColor Cyan
    Write-Host "   Option 1: minikube service app-service -n $Namespace" -ForegroundColor Gray
    Write-Host "   Option 2: kubectl port-forward svc/app-service 8080:80 -n $Namespace" -ForegroundColor Gray
    Write-Host "            Then visit http://localhost:8080" -ForegroundColor Gray
    Write-Host ""
}

Write-Host " Useful commands:" -ForegroundColor Yellow
Write-Host "   View logs:        kubectl logs -f deployment/app -n $Namespace" -ForegroundColor Gray
Write-Host "   View pod details: kubectl describe pods -n $Namespace" -ForegroundColor Gray
Write-Host "   Watch pods:       kubectl get pods -n $Namespace -w" -ForegroundColor Gray
Write-Host "   Delete all:       kubectl delete namespace $Namespace" -ForegroundColor Gray
