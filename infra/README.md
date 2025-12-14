# Terraform Infrastructure for DevOps Articles

This directory contains Terraform configurations to provision AWS infrastructure for the DevOps Articles application.

## Infrastructure Components

- **VPC**: Custom VPC with public and private subnets across 2 availability zones
- **EKS Cluster**: Managed Kubernetes cluster with auto-scaling node groups
- **RDS PostgreSQL**: Managed PostgreSQL database with encryption and backups
- **Security Groups**: Fine-grained network security rules
- **NAT Gateways**: For private subnet internet access
- **IAM Roles**: Service roles for EKS and RDS

## Prerequisites

1. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```

2. **Terraform** (>= 1.0)
   ```bash
   terraform version
   ```

3. **kubectl** for Kubernetes management
   ```bash
   kubectl version --client
   ```

## Quick Start

### 1. Configure Variables

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
aws_region = "us-east-1"
project_name = "devops-articles"
environment = "dev"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Infrastructure

```bash
terraform plan
```

### 4. Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to create resources.

### 5. Configure kubectl

After EKS cluster is created:
```bash
aws eks update-kubeconfig --region us-east-1 --name devops-articles-eks-cluster
```

Verify connection:
```bash
kubectl get nodes
```

### 6. Get Outputs

View important resource information:
```bash
terraform output
```

Get RDS connection details:
```bash
terraform output rds_endpoint
terraform output rds_database_name
```

## Resource Costs (Estimated Monthly)

- **EKS Cluster**: ~$73/month (control plane)
- **EC2 Instances** (2x t3.medium): ~$60/month
- **RDS t3.micro**: ~$15/month
- **NAT Gateway**: ~$32/month (per gateway)
- **Total**: ~$180-250/month

**Note**: These are estimates. Actual costs vary by usage and region.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted. **This will delete all infrastructure!**

## File Structure

```
infra/
├── provider.tf           # AWS provider configuration
├── variables.tf          # Input variables
├── outputs.tf            # Output values
├── vpc.tf                # VPC, subnets, NAT gateways
├── security-groups.tf    # Security group rules
├── eks.tf                # EKS cluster and node groups
├── rds.tf                # PostgreSQL RDS instance
├── user-data.sh          # EKS node bootstrap script
├── terraform.tfvars      # Your variable values (gitignored)
└── README.md             # This file
```

## Security Best Practices

1. **Never commit** `terraform.tfvars` or `.tfstate` files to Git
2. Enable **deletion protection** for RDS in production
3. Use **private subnets** for database and application nodes
4. Restrict **allowed_cidr_blocks** to your IP/VPN range
5. Enable **MFA** for AWS root account
6. Use **AWS Secrets Manager** for database passwords (already configured)

## Troubleshooting

### EKS nodes not joining cluster
```bash
kubectl get nodes
# If empty, check:
aws eks describe-nodegroup --cluster-name devops-articles-eks-cluster --nodegroup-name devops-articles-node-group
```

### Cannot connect to RDS
```bash
# Verify security group allows EKS nodes
aws ec2 describe-security-groups --group-ids <rds-sg-id>
```

### High costs
```bash
# Scale down nodes when not in use
terraform apply -var="eks_desired_capacity=1"
```

## Next Steps

After infrastructure is provisioned:

1. Deploy Kubernetes manifests from `../k8s/` directory
2. Configure application to use RDS endpoint
3. Set up monitoring with Prometheus/Grafana
4. Configure CI/CD pipeline

## Support

For issues or questions, refer to:
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [RDS PostgreSQL Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/)
