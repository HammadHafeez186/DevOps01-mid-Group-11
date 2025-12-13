# AWS EKS Deployment Script for DevOps Articles Application
# This script automates the deployment process to AWS EKS

param(
    [string]$Region = "us-east-1",
    [string]$ClusterName = "devops-articles-eks-cluster",
    [string]$ECRRepository = "devops-articles",
    [string]$ImageTag = "latest"
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "AWS EKS Deployment Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Get AWS Account ID
Write-Host "[1/8] Getting AWS Account ID..." -ForegroundColor Yellow
$AccountId = (aws sts get-caller-identity --query Account --output text)
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to get AWS Account ID. Please check AWS CLI configuration." -ForegroundColor Red
    exit 1
}
Write-Host "AWS Account ID: $AccountId" -ForegroundColor Green
Write-Host ""

# Create ECR Repository if it doesn't exist
Write-Host "[2/8] Creating ECR Repository..." -ForegroundColor Yellow
$ECRUri = "$AccountId.dkr.ecr.$Region.amazonaws.com/$ECRRepository"
aws ecr describe-repositories --repository-names $ECRRepository --region $Region 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating new ECR repository: $ECRRepository" -ForegroundColor Cyan
    aws ecr create-repository --repository-name $ECRRepository --region $Region
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to create ECR repository" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ECR repository already exists: $ECRRepository" -ForegroundColor Green
}
Write-Host "ECR URI: $ECRUri" -ForegroundColor Green
Write-Host ""

# Login to ECR
Write-Host "[3/8] Logging in to ECR..." -ForegroundColor Yellow
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin "$AccountId.dkr.ecr.$Region.amazonaws.com"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to login to ECR" -ForegroundColor Red
    exit 1
}
Write-Host "Successfully logged in to ECR" -ForegroundColor Green
Write-Host ""

# Build Docker Image
Write-Host "[4/8] Building Docker image..." -ForegroundColor Yellow
docker build -t $ECRRepository`:$ImageTag .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build Docker image" -ForegroundColor Red
    exit 1
}
Write-Host "Docker image built successfully" -ForegroundColor Green
Write-Host ""

# Tag Docker Image for ECR
Write-Host "[5/8] Tagging Docker image for ECR..." -ForegroundColor Yellow
docker tag $ECRRepository`:$ImageTag $ECRUri`:$ImageTag
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to tag Docker image" -ForegroundColor Red
    exit 1
}
Write-Host "Docker image tagged for ECR" -ForegroundColor Green
Write-Host ""

# Push Docker Image to ECR
Write-Host "[6/8] Pushing Docker image to ECR..." -ForegroundColor Yellow
docker push $ECRUri`:$ImageTag
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to push Docker image to ECR" -ForegroundColor Red
    exit 1
}
Write-Host "Docker image pushed to ECR successfully" -ForegroundColor Green
Write-Host ""

# Configure kubectl for EKS
Write-Host "[7/8] Configuring kubectl for EKS cluster..." -ForegroundColor Yellow
aws eks update-kubeconfig --region $Region --name $ClusterName
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to configure kubectl for EKS" -ForegroundColor Red
    exit 1
}
Write-Host "kubectl configured for EKS cluster" -ForegroundColor Green
Write-Host ""

# Get RDS Endpoint from Terraform Output
Write-Host "[8/8] Getting RDS endpoint from Terraform..." -ForegroundColor Yellow
Push-Location infra
$RDSEndpoint = terraform output -raw rds_endpoint
Pop-Location
Write-Host "RDS Endpoint: $RDSEndpoint" -ForegroundColor Green
Write-Host ""

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update k8s/01-configmap.yaml with RDS endpoint: $RDSEndpoint" -ForegroundColor White
Write-Host "2. Update k8s/06-app-deployment.yaml with ECR image: $ECRUri`:$ImageTag" -ForegroundColor White
Write-Host "3. Deploy to Kubernetes: kubectl apply -f k8s/" -ForegroundColor White
Write-Host ""
Write-Host "Full ECR Image URI: $ECRUri`:$ImageTag" -ForegroundColor Cyan
