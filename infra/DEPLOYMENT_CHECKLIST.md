# ✅ Infrastructure Verification & Setup Guide

## Infrastructure Status: **READY** ✅

All Terraform files have been created and configured for production deployment.

---

## 📋 What You Have

### Terraform Files Created:
- ✅ `provider.tf` - AWS provider configuration
- ✅ `variables.tf` - All configuration variables
- ✅ `terraform.tfvars` - Your actual configuration values
- ✅ `vpc.tf` - VPC, subnets, NAT gateways, routing
- ✅ `security-groups.tf` - Security rules for EKS, RDS, ALB
- ✅ `eks.tf` - EKS cluster with auto-scaling node groups
- ✅ `ec2.tf` - Alternative EC2/k3s setup (not used when use_eks=true)
- ✅ `rds.tf` - PostgreSQL database with encryption
- ✅ `outputs.tf` - Important resource information
- ✅ `user-data.sh` - EKS node bootstrap script
- ✅ `k3s-install.sh` - Alternative k3s installation
- ✅ `README.md` - Deployment documentation
- ✅ `.gitignore` - Protection for sensitive files

---

## 🔧 What You Need to Install/Configure

### 1. **Install Terraform** ⚠️ REQUIRED
```powershell
# Download from: https://www.terraform.io/downloads
# Or use Chocolatey (Run PowerShell as Administrator):
choco install terraform -y

# Verify installation:
terraform version
```

### 2. **Install AWS CLI** ⚠️ REQUIRED
```powershell
# Download from: https://aws.amazon.com/cli/
# Or use Chocolatey:
choco install awscli -y

# Verify installation:
aws --version
```

### 3. **Configure AWS Credentials** ⚠️ REQUIRED
```powershell
aws configure
# You'll need:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json
```

**Where to get AWS credentials:**
1. Log into AWS Console
2. Go to IAM → Users → Your User
3. Security credentials tab
4. Create access key → CLI
5. Save the Access Key ID and Secret Access Key

### 4. **Create EC2 Key Pair** ⚠️ REQUIRED
```
1. Go to AWS Console → EC2 → Key Pairs
2. Click "Create key pair"
3. Name: devops-key
4. Key pair type: RSA
5. Private key format: .pem
6. Download and save the .pem file
```

Then update `terraform.tfvars`:
```hcl
ec2_key_name = "devops-key"  # Match the name you created
```

### 5. **Update terraform.tfvars** ⚠️ REQUIRED

Edit the file and set:
```hcl
owner = "your-name-or-team"  # Change this
ec2_key_name = "devops-key"  # Must match AWS key pair name
```

Optionally restrict access to your IP:
```hcl
allowed_cidr_blocks = ["YOUR_IP/32"]  # More secure
```

---

## 🚀 Deployment Steps

### Step 1: Initialize Terraform
```powershell
cd C:\Users\hamma\OneDrive\Desktop\devOpsProject01\infra
terraform init
```
**Expected output:** Downloads AWS provider, creates `.terraform` directory

### Step 2: Validate Configuration
```powershell
terraform validate
```
**Expected output:** "Success! The configuration is valid."

### Step 3: Format Files (Optional)
```powershell
terraform fmt
```
**Expected output:** Lists any files that were reformatted

### Step 4: Preview Changes (Dry Run)
```powershell
terraform plan
```
**Expected output:** Shows ~40-50 resources to be created
**Screenshot this for your exam!** 📸

### Step 5: Deploy Infrastructure
```powershell
terraform apply
# Type: yes
```
**Duration:** 15-20 minutes
**Screenshot the final output!** 📸

### Step 6: Save Outputs
```powershell
terraform output > terraform-outputs.txt
```

---

## 📊 What Gets Created

### AWS Resources:
1. **VPC** (1)
   - CIDR: 10.0.0.0/16
   - 2 Public Subnets
   - 2 Private Subnets
   - Internet Gateway
   
2. **NAT Gateways** (2)
   - One per AZ for private subnet internet access
   
3. **EKS Cluster** (1)
   - Kubernetes 1.28
   - Control plane in 2 AZs
   - CloudWatch logging enabled
   
4. **EKS Node Group** (1)
   - 2 t3.medium instances
   - Auto-scaling: 1-4 nodes
   - In private subnets
   
5. **RDS PostgreSQL** (1)
   - db.t3.micro instance
   - 20GB storage
   - Automated backups
   - Encrypted storage
   
6. **Security Groups** (4)
   - EKS cluster SG
   - EKS nodes SG
   - RDS SG
   - ALB SG (optional)
   
7. **IAM Roles** (3)
   - EKS cluster role
   - EKS node role
   - RDS monitoring role
   
8. **Secrets Manager** (1)
   - Database password

---

## 💰 Cost Breakdown (2 Days)

| Resource | Hourly | Daily | 2 Days |
|----------|--------|-------|--------|
| EKS Cluster | $0.10 | $2.40 | **$4.80** |
| EC2 (2x t3.medium) | $0.0416 | $2.00 | **$4.00** |
| NAT Gateway (2x) | $0.045 | $2.16 | **$4.32** |
| RDS (t3.micro) | $0.018 | $0.43 | **$0.86** |
| Data Transfer | - | ~$0.50 | **$1.00** |
| **TOTAL** | - | **~$7.50** | **~$15.00** |

✅ **Very affordable for exam/learning!**

---

## 🔍 After Deployment - Verification

### 1. Configure kubectl
```powershell
aws eks update-kubeconfig --region us-east-1 --name devops-articles-eks-cluster

# Verify:
kubectl get nodes
# Should show 2 nodes in Ready state
```

### 2. Check RDS Endpoint
```powershell
terraform output rds_endpoint
# Save this for your application configuration
```

### 3. Deploy Your Application
```powershell
cd ..\k8s
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-configmap.yaml
kubectl apply -f 02-secret.yaml
# Update secret with RDS endpoint first!
kubectl apply -f .
```

---

## 📸 Screenshots Needed for Exam

1. ✅ `terraform plan` output
2. ✅ `terraform apply` completion message
3. ✅ `terraform output` showing all resources
4. ✅ AWS Console - VPC dashboard
5. ✅ AWS Console - EKS cluster page
6. ✅ AWS Console - RDS instance page
7. ✅ `kubectl get nodes` output
8. ✅ AWS Console - Resource map/Cost explorer

---

## 🧹 Cleanup After Exam

**IMPORTANT:** Run this to avoid ongoing charges!

```powershell
terraform destroy
# Type: yes
```

This will delete ALL resources created by Terraform.

**Duration:** 10-15 minutes

---

## ⚠️ Common Issues & Solutions

### Issue: "Error: No valid credential sources found"
**Solution:** Run `aws configure` and enter your credentials

### Issue: "Error: creating EC2 Key Pair: InvalidKeyPair.Duplicate"
**Solution:** Use a different key name or delete the existing one

### Issue: "Error: creating EKS Cluster: InvalidParameterException"
**Solution:** Check that `use_eks = true` in terraform.tfvars

### Issue: "Error: creating DB Instance: InvalidParameterCombination"
**Solution:** Ensure you have at least 2 subnets in different AZs

### Issue: Terraform commands not found
**Solution:** Install Terraform and restart PowerShell

---

## ✅ Final Checklist Before Running `terraform apply`

- [ ] Terraform installed (`terraform version` works)
- [ ] AWS CLI installed (`aws --version` works)
- [ ] AWS credentials configured (`aws sts get-caller-identity` works)
- [ ] EC2 key pair created in AWS Console
- [ ] `terraform.tfvars` updated with your key pair name
- [ ] In the `/infra` directory
- [ ] `terraform init` completed successfully
- [ ] `terraform validate` shows no errors
- [ ] `terraform plan` shows expected resources
- [ ] Ready to wait 15-20 minutes for deployment
- [ ] Have AWS Console open to monitor progress
- [ ] Ready to take screenshots!

---

## 🎯 Next Steps After Infrastructure is Ready

1. ✅ Step 2: Terraform - **COMPLETE** (you are here)
2. ⏭️ Step 4: Ansible - Configure servers/deployments
3. ⏭️ Step 5: Kubernetes - Deploy app to EKS
4. ⏭️ Step 6: CI/CD - GitHub Actions pipeline
5. ⏭️ Step 7: Monitoring - Prometheus & Grafana
6. ⏭️ Step 8: Documentation - README & report

**Your infrastructure is ready to deploy!** 🚀
