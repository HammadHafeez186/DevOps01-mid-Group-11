# Infrastructure Cleanup Guide

This guide helps you clean up AWS resources to avoid ongoing costs.

## Quick Cleanup

### 1. Kubernetes Resources
```bash
# Delete all application resources
kubectl delete namespace devops-articles

# Delete EBS CSI driver addon
aws eks delete-addon --cluster-name devops-articles-eks-cluster --addon-name aws-ebs-csi-driver --region us-east-1
```

### 2. Terraform Resources
```bash
cd infra
terraform destroy -auto-approve
```

### 3. IAM Cleanup
```bash
# Detach policy from role
aws iam detach-role-policy \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AmazonEKS_EBS_CSI_Driver_Policy

# Delete IAM role
aws iam delete-role --role-name AmazonEKS_EBS_CSI_DriverRole

# Delete IAM policy
aws iam delete-policy --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AmazonEKS_EBS_CSI_Driver_Policy
```

### 4. EBS Volumes
```bash
# List any orphaned EBS volumes
aws ec2 describe-volumes --region us-east-1 --filters "Name=status,Values=available" --query "Volumes[*].[VolumeId,Size,State]" --output table

# Delete orphaned volumes (be careful!)
# aws ec2 delete-volume --volume-id <volume-id> --region us-east-1
```

### 5. ECR Images (Optional)
```bash
# List repositories
aws ecr describe-repositories --region us-east-1

# Delete repository and images
aws ecr delete-repository --repository-name devops-articles --force --region us-east-1
```

## Cost Considerations

### Free Tier Resources
- EC2 t2.micro: 750 hours/month
- RDS db.t3.micro: 750 hours/month (first 12 months)
- 30GB EBS storage

### Paid Resources to Monitor
- EKS Control Plane: ~$73/month ($0.10/hour)
- NAT Gateway: ~$32/month ($0.045/hour + data transfer)
- EBS volumes beyond free tier
- Data transfer costs
- Load Balancer costs

## Alternative: Low-Cost Development Setup

Use the EC2 + k3s option instead of EKS:

```bash
cd infra
# Edit terraform.tfvars
# Set: use_eks = false
terraform apply
```

This uses:
- Single t2.micro EC2 instance (free tier)
- k3s (lightweight Kubernetes)
- No NAT Gateway required
- Significantly lower costs
