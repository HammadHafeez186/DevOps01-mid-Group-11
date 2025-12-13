# AWS EKS Deployment Guide

## Overview
This application is deployed on AWS using:
- **EKS (Elastic Kubernetes Service)** - Managed Kubernetes cluster
- **RDS PostgreSQL** - Managed database service
- **VPC** - Custom Virtual Private Cloud with public/private subnets
- **ECR (Elastic Container Registry)** - Docker image repository
- **NAT Gateways** - For private subnet internet access

## Architecture

```
Internet
   |
   v
Application Load Balancer
   |
   v
EKS Cluster (VPC: 10.0.0.0/16)
   ├─ Public Subnets (10.0.0.0/24, 10.0.1.0/24)
   │  └─ NAT Gateways
   └─ Private Subnets (10.0.10.0/24, 10.0.11.0/24)
      ├─ EKS Worker Nodes (t3.medium x2)
      │  └─ Application Pods
      └─ RDS PostgreSQL (db.t3.micro)
```

## Cost Estimate
- **EKS Control Plane**: ~$73/month
- **EC2 Instances** (2x t3.medium): ~$60/month
- **RDS db.t3.micro**: ~$15/month
- **NAT Gateways** (2x): ~$64/month
- **Data Transfer**: Variable
- **Total**: ~$212-250/month

## Prerequisites
1. AWS CLI configured with credentials
2. Terraform >= 1.0
3. kubectl
4. Docker
5. PowerShell (for deployment scripts)

## Deployment Steps

### 1. Deploy Infrastructure with Terraform

```powershell
cd infra
terraform init
terraform plan
terraform apply -auto-approve
```

This creates:
- VPC with public/private subnets
- EKS cluster with node group
- RDS PostgreSQL instance  
- Security groups and IAM roles
- NAT gateways for private subnet internet access

### 2. Get Infrastructure Outputs

```powershell
# Get RDS endpoint
terraform output rds_endpoint

# Get EKS cluster name
terraform output eks_cluster_name

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name devops-articles-eks-cluster
```

### 3. Deploy Application Using Script

The automated deployment script handles:
- ECR repository creation
- Docker image build and push
- kubectl configuration
- Retrieving RDS credentials

```powershell
.\deploy-to-aws.ps1
```

### 4. Manual Deployment Steps

If you prefer manual deployment:

#### a. Create ECR Repository
```powershell
aws ecr create-repository --repository-name devops-articles --region us-east-1
```

#### b. Build and Push Docker Image
```powershell
# Get Account ID
$AccountId = (aws sts get-caller-identity --query Account --output text)

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AccountId.dkr.ecr.us-east-1.amazonaws.com

# Build image
docker build -t devops-articles:latest .

# Tag for ECR
docker tag devops-articles:latest $AccountId.dkr.ecr.us-east-1.amazonaws.com/devops-articles:latest

# Push to ECR
docker push $AccountId.dkr.ecr.us-east-1.amazonaws.com/devops-articles:latest
```

#### c. Update Kubernetes Manifests

Update `k8s/01-configmap.aws.yaml`:
```yaml
DB_HOST: "your-rds-endpoint-here.rds.amazonaws.com"
```

Update `k8s/06-app-deployment.aws.yaml`:
```yaml
image: $AccountId.dkr.ecr.us-east-1.amazonaws.com/devops-articles:latest
```

#### d. Get Database Password from Secrets Manager
```powershell
aws secretsmanager get-secret-value --secret-id devops-articles-db-password --query SecretString --output text
```

Update `k8s/02-secret.yaml` with the password.

#### e. Deploy to Kubernetes
```powershell
# Create namespace
kubectl apply -f k8s/00-namespace.yaml

# Apply all manifests (use AWS versions)
kubectl apply -f k8s/01-configmap.aws.yaml
kubectl apply -f k8s/02-secret.yaml
kubectl apply -f k8s/03-postgres-storage.yaml  # Optional - using RDS
kubectl apply -f k8s/06-app-deployment.aws.yaml
kubectl apply -f k8s/07-app-service.yaml
kubectl apply -f k8s/08-hpa.yaml
```

### 5. Verify Deployment

```powershell
# Check pods
kubectl get pods -n devops-articles

# Check services
kubectl get svc -n devops-articles

# Get LoadBalancer URL
kubectl get svc app-service -n devops-articles -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Check logs
kubectl logs -n devops-articles -l app=devops-articles --tail=50
```

### 6. Access Application

Once the LoadBalancer is provisioned (takes 2-3 minutes):
```powershell
$LB_URL = kubectl get svc app-service -n devops-articles -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo "Application URL: http://$LB_URL"
```

## Monitoring

### View Logs
```powershell
# Application logs
kubectl logs -f -n devops-articles deployment/app

# All pods logs
kubectl logs -n devops-articles -l app=devops-articles --all-containers=true
```

### Check Pod Status
```powershell
kubectl get pods -n devops-articles -o wide
kubectl describe pod <pod-name> -n devops-articles
```

### RDS Monitoring
- CloudWatch Logs: `/aws/rds/instance/devops-articles-postgres/postgresql`
- Performance Insights enabled (7-day retention)

## Scaling

### Manual Scaling
```powershell
kubectl scale deployment app -n devops-articles --replicas=3
```

### Auto-Scaling
HPA (Horizontal Pod Autoscaler) is configured:
- Min: 2 replicas
- Max: 5 replicas
- Target CPU: 70%

## Troubleshooting

### Pods not starting
```powershell
kubectl describe pod <pod-name> -n devops-articles
kubectl logs <pod-name> -n devops-articles
```

### Database connection issues
```powershell
# Test from pod
kubectl exec -it <pod-name> -n devops-articles -- nc -zv $DB_HOST 5432

# Check security groups
aws ec2 describe-security-groups --group-ids sg-xxxxx
```

### Image pull errors
```powershell
# Verify ECR repository
aws ecr describe-repositories --repository-names devops-articles

# Check IAM permissions for EKS nodes
aws iam list-attached-role-policies --role-name devops-articles-eks-node-role
```

## Cleanup

To destroy all AWS resources:

```powershell
# Delete Kubernetes resources
kubectl delete namespace devops-articles

# Destroy Terraform infrastructure
cd infra
terraform destroy -auto-approve
```

**Note**: This will delete all data. Make sure to backup if needed!

## Security Considerations

1. **Database**: Located in private subnets, not publicly accessible
2. **Secrets**: Stored in AWS Secrets Manager and Kubernetes secrets
3. **Network**: NAT Gateways provide outbound internet for private subnets
4. **Encryption**: RDS encryption at rest enabled
5. **SSL**: RDS connections use SSL/TLS

## Maintenance

### Update Application
```powershell
# Build new image
docker build -t devops-articles:v2 .

# Tag and push to ECR
docker tag devops-articles:v2 $AccountId.dkr.ecr.us-east-1.amazonaws.com/devops-articles:v2
docker push $AccountId.dkr.ecr.us-east-1.amazonaws.com/devops-articles:v2

# Update deployment
kubectl set image deployment/app app=$AccountId.dkr.ecr.us-east-1.amazonaws.com/devops-articles:v2 -n devops-articles

# Check rollout status
kubectl rollout status deployment/app -n devops-articles
```

### Database Backup
RDS automated backups are enabled:
- Retention: 7 days
- Backup window: 03:00-04:00 UTC
- Maintenance window: Monday 04:00-05:00 UTC

## Support

For issues or questions:
1. Check CloudWatch Logs
2. Review Kubernetes events: `kubectl get events -n devops-articles`
3. Verify Terraform state: `terraform show`
