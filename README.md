# DevOps Project - Article Management System

[![CI/CD Pipeline](https://github.com/HammadHafeez186/DevOps01-mid-Group-11/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/HammadHafeez186/DevOps01-mid-Group-11/actions/workflows/ci-cd.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/your-dockerhub-username/devops-project-app)](https://hub.docker.com/r/your-dockerhub-username/devops-project-app)

A containerized Node.js application with Express, Sequelize ORM, and PostgreSQL database, featuring a complete DevOps pipeline with CI/CD automation, Kubernetes orchestration, and infrastructure as code with Terraform. The application supports file uploads with persistent storage and includes comprehensive monitoring capabilities.

## 📚 Table of Contents

- [How to Run the Application](#how-to-run-the-application)
  - [Local Development](#local-development)
  - [Docker Compose](#docker-compose)
  - [Kubernetes Deployment](#kubernetes-deployment)
- [Infrastructure Setup](#infrastructure-setup)
  - [AWS EKS with Terraform](#aws-eks-with-terraform)
  - [EBS CSI Driver Setup](#ebs-csi-driver-setup)
- [Infrastructure Teardown](#infrastructure-teardown)
- [DevOps Report](./devops_report.md)
- [Additional Resources](#additional-resources)

## 🚀 How to Run the Application

### Local Development

Run the application directly on your machine without Docker:

#### Prerequisites
- Node.js 18 or higher
- PostgreSQL 15
- Git

#### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/HammadHafeez186/DevOps01-mid-Group-11.git
   cd DevOps01-mid-Group-11
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up PostgreSQL database**
   
   Option A: Using Docker for database only
   ```bash
   docker run -d --name postgres-dev \
     -e POSTGRES_USER=postgres \
     -e POSTGRES_PASSWORD=Hammad1234 \
     -e POSTGRES_DB=devops_db \
     -p 5432:5432 \
     postgres:15-alpine
   ```

   Option B: Using local PostgreSQL installation
   ```bash
   # Create database
   createdb devops_db
   ```

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` file:
   ```env
   NODE_ENV=development
   PORT=3000
   DB_HOST=localhost
   DB_PORT=5432
   DB_USERNAME=postgres
   DB_PASSWORD=Hammad1234
   DB_NAME=devops_db
   DB_SSL=false
   SESSION_SECRET=your-secret-key-here
   RESEND_API_KEY=your-resend-api-key
   EMAIL_FROM=DevOps Articles <noreply@tabeebemail.me>
   APP_URL=http://localhost:3000
   ```

5. **Run database migrations and seeders**
   ```bash
   npx sequelize-cli db:migrate
   npx sequelize-cli db:seed:all
   ```

6. **Start the application**
   ```bash
   # Development mode (with hot reload)
   npm run dev

   # Production mode
   npm start
   ```

7. **Access the application**
   - Application: http://localhost:3000
   - Health Check: http://localhost:3000/health

---

### Docker Compose

Run the entire stack (app + database) using Docker Compose:

#### Prerequisites
- Docker Desktop or Docker Engine
- Docker Compose (included with Docker Desktop)

#### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/HammadHafeez186/DevOps01-mid-Group-11.git
   cd DevOps01-mid-Group-11
   ```

2. **Configure environment variables (optional)**
   ```bash
   cp .env.example .env
   # Edit .env if you want custom values (otherwise defaults will be used)
   ```

3. **Start all services**
   ```bash
   docker-compose up --build
   ```

   Or run in detached mode:
   ```bash
   docker-compose up -d --build
   ```

4. **Verify services are running**
   ```bash
   docker-compose ps
   ```

5. **View logs**
   ```bash
   # All services
   docker-compose logs -f

   # Specific service
   docker-compose logs -f app
   docker-compose logs -f db
   ```

6. **Access the application**
   - Application: http://localhost:3000
   - Health Check: http://localhost:3000/health

7. **Stop the application**
   ```bash
   # Stop containers
   docker-compose stop

   # Stop and remove containers (data persists in volumes)
   docker-compose down

   # Stop and remove containers AND volumes (deletes all data)
   docker-compose down -v
   ```

#### Docker Compose Services

The `docker-compose.yml` includes:
- **app**: Node.js application container
- **db**: PostgreSQL 15 database container

Features:
- **Persistent storage**: Database data and uploads persist in Docker volumes
- **Health checks**: Automatic health monitoring for both services
- **Auto-restart**: Services restart automatically on failure
- **Internal networking**: Services communicate through Docker's internal network

#### Available Commands
```bash
# Build and start
docker-compose up --build

# Run tests
npm run test:docker

# View logs
docker-compose logs -f

# Execute commands in running container
docker-compose exec app npm run migrate
docker-compose exec db psql -U postgres -d devops_db

# Clean up everything
docker-compose down -v
docker system prune -a
```

---

### Kubernetes Deployment

Deploy the application on Kubernetes (local or cloud):

#### Prerequisites
- Kubernetes cluster (Minikube, Kind, EKS, GKE, AKS, or K3s)
- kubectl configured to access your cluster
- For persistent storage: StorageClass supporting ReadWriteOnce volumes

#### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/HammadHafeez186/DevOps01-mid-Group-11.git
   cd DevOps01-mid-Group-11/k8s
   ```

2. **Verify cluster connectivity**
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

3. **Configure secrets**
   ```bash
   # Copy the example secret file
   cp 02-secret.yaml.example 02-secret.yaml
   ```

   Edit `02-secret.yaml` and replace placeholders with base64-encoded values:
   ```bash
   # Generate base64 encoded values:
   echo -n "your-password" | base64
   echo -n "your-resend-api-key" | base64
   echo -n "$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")" | base64
   echo -n "postgresql://postgres:your-password@postgres-service:5432/devops_db" | base64
   ```

4. **Deploy to Kubernetes**
   ```bash
   # Apply manifests in order
   kubectl apply -f 00-namespace.yaml
   kubectl apply -f 01-configmap.yaml
   kubectl apply -f 02-secret.yaml
   kubectl apply -f 03-postgres-storage.yaml
   kubectl apply -f 04-postgres-statefulset.yaml
   kubectl apply -f 05-postgres-service.yaml
   kubectl apply -f 12-uploads-storage.yaml
   kubectl apply -f 06-app-deployment.yaml
   kubectl apply -f 07-app-service.yaml
   ```

   Or apply all at once:
   ```bash
   kubectl apply -f .
   ```

5. **Verify deployment**
   ```bash
   # Check all resources in namespace
   kubectl get all -n devops-articles

   # Check pods status
   kubectl get pods -n devops-articles

   # Check persistent volumes
   kubectl get pvc -n devops-articles

   # View pod logs
   kubectl logs -n devops-articles -l component=app -f
   ```

6. **Access the application**
   
   For **LoadBalancer** service (cloud environments):
   ```bash
   # Get external IP/hostname
   kubectl get svc app-service -n devops-articles
   
   # Access via: http://<EXTERNAL-IP>:3000
   ```

   For **NodePort** service (local clusters):
   ```bash
   # Get NodePort
   kubectl get svc app-service -n devops-articles
   
   # Access via: http://<NODE-IP>:<NODE-PORT>
   # Or use kubectl proxy
   kubectl port-forward -n devops-articles svc/app-service 3000:3000
   # Then access: http://localhost:3000
   ```

7. **Monitor the application**
   ```bash
   # Watch pod status
   kubectl get pods -n devops-articles -w

   # Describe resources
   kubectl describe pod -n devops-articles <pod-name>
   kubectl describe pvc -n devops-articles

   # Check events
   kubectl get events -n devops-articles --sort-by='.lastTimestamp'
   ```

8. **Scale the application** (if using compatible storage)
   ```bash
   kubectl scale deployment app -n devops-articles --replicas=3
   ```

9. **Update the application**
   ```bash
   # Update image
   kubectl set image deployment/app app=your-registry/app:new-tag -n devops-articles

   # Or edit deployment
   kubectl edit deployment app -n devops-articles

   # Rollback if needed
   kubectl rollout undo deployment/app -n devops-articles
   ```

10. **Clean up**
    ```bash
    # Delete all resources
    kubectl delete -f .

    # Or delete namespace (removes everything)
    kubectl delete namespace devops-articles
    ```

#### For AWS EKS Deployment
See the [Infrastructure Setup](#infrastructure-setup) section below for detailed AWS EKS deployment with Terraform.

---

## 🏗️ Infrastructure Setup

### AWS EKS with Terraform

Complete infrastructure provisioning on AWS using Terraform:

#### Prerequisites
- AWS CLI installed and configured
- Terraform installed (v1.0+)
- kubectl installed
- Valid AWS credentials with appropriate permissions

#### Steps

1. **Navigate to infrastructure directory**
   ```bash
   cd infra
   ```

2. **Configure Terraform variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   Edit `terraform.tfvars`:
   ```hcl
   aws_region          = "us-east-1"
   project_name        = "devops-articles"
   environment         = "production"
   
   # VPC Configuration
   vpc_cidr            = "10.0.0.0/16"
   availability_zones  = ["us-east-1a", "us-east-1b"]
   
   # EKS Configuration
   use_eks             = true
   eks_cluster_version = "1.28"
   
   # RDS Configuration (optional)
   db_instance_class   = "db.t3.micro"
   db_name             = "devops_db"
   db_username         = "postgres"
   db_password         = "your-secure-password"  # Use AWS Secrets Manager in production
   
   # EC2 Configuration (if not using EKS)
   ec2_instance_type   = "t2.medium"
   ec2_key_name        = "your-key-pair-name"
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Review planned changes**
   ```bash
   terraform plan
   ```

5. **Apply infrastructure**
   ```bash
   terraform apply
   ```

   Type `yes` when prompted. This creates:
   - VPC with public and private subnets across 2 AZs
   - Internet Gateway and NAT Gateway
   - Security groups for EKS and RDS
   - EKS cluster with managed node groups
   - RDS PostgreSQL instance (if configured)
   - IAM roles and policies

6. **Configure kubectl for EKS**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name devops-articles-eks-cluster
   ```

7. **Verify cluster access**
   ```bash
   kubectl get nodes
   kubectl get namespaces
   ```

8. **Get infrastructure outputs**
   ```bash
   terraform output
   ```

   Important outputs:
   - `eks_cluster_endpoint`: EKS API server endpoint
   - `eks_cluster_name`: Name of the EKS cluster
   - `rds_endpoint`: PostgreSQL database endpoint (if using RDS)
   - `vpc_id`: VPC identifier

9. **Update Kubernetes ConfigMap with RDS endpoint**
   
   If using RDS, update `k8s/01-configmap.aws.yaml`:
   ```bash
   # Get RDS endpoint
   terraform output rds_endpoint
   
   # Update ConfigMap
   # Replace REPLACE_WITH_RDS_ENDPOINT with the actual endpoint
   ```

---

### EBS CSI Driver Setup

For persistent storage on EKS, install the EBS CSI driver:

#### Prerequisites
- EKS cluster running
- kubectl configured
- AWS CLI configured

#### Steps

1. **Get your AWS Account ID and OIDC Provider**
   ```bash
   export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
   export AWS_REGION=us-east-1
   export CLUSTER_NAME=devops-articles-eks-cluster
   
   # Get OIDC provider
   export OIDC_PROVIDER=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION \
     --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
   
   echo "Account ID: $AWS_ACCOUNT_ID"
   echo "OIDC Provider: $OIDC_PROVIDER"
   ```

2. **Create IAM policy for EBS CSI Driver**
   ```bash
   cd infra
   
   aws iam create-policy \
     --policy-name AmazonEKS_EBS_CSI_Driver_Policy \
     --policy-document file://ebs-csi-policy.json
   ```

3. **Update trust policy with your OIDC provider**
   ```bash
   # Edit ebs-csi-trust-policy.json and replace:
   # - <AWS_ACCOUNT_ID> with your account ID
   # - <OIDC_PROVIDER> with your OIDC provider URL
   
   # Or use sed (on Linux/Mac):
   sed "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/g" ebs-trust.json | \
   sed "s|<OIDC_PROVIDER>|$OIDC_PROVIDER|g" > ebs-csi-trust-policy-updated.json
   ```

4. **Create IAM role for EBS CSI Driver**
   ```bash
   aws iam create-role \
     --role-name AmazonEKS_EBS_CSI_DriverRole \
     --assume-role-policy-document file://ebs-csi-trust-policy-updated.json
   
   # Attach the policy
   aws iam attach-role-policy \
     --role-name AmazonEKS_EBS_CSI_DriverRole \
     --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/AmazonEKS_EBS_CSI_Driver_Policy
   ```

5. **Install EBS CSI Driver as EKS addon**
   ```bash
   aws eks create-addon \
     --cluster-name $CLUSTER_NAME \
     --addon-name aws-ebs-csi-driver \
     --service-account-role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/AmazonEKS_EBS_CSI_DriverRole \
     --region $AWS_REGION
   ```

6. **Verify installation**
   ```bash
   # Check addon status
   aws eks describe-addon \
     --cluster-name $CLUSTER_NAME \
     --addon-name aws-ebs-csi-driver \
     --region $AWS_REGION
   
   # Check driver pods
   kubectl get pods -n kube-system | grep ebs-csi
   
   # Should see:
   # ebs-csi-controller-xxx (2/2 Running)
   # ebs-csi-node-xxx (3/3 Running on each node)
   ```

7. **Verify storage class**
   ```bash
   kubectl get storageclass
   
   # Should see gp2 or gp3 storage class
   ```

Now you can deploy the application with persistent storage support!

---

## 🗑️ Infrastructure Teardown

### Kubernetes Cleanup

Remove all Kubernetes resources:

```bash
# Delete all application resources
cd k8s
kubectl delete -f .

# Or delete namespace (removes everything in it)
kubectl delete namespace devops-articles

# Verify cleanup
kubectl get all -n devops-articles
```

### AWS Infrastructure Cleanup

Destroy all AWS resources created by Terraform:

#### Important: Steps to Avoid Errors

1. **Delete Kubernetes resources first** (to release EBS volumes)
   ```bash
   kubectl delete -f k8s/
   kubectl delete namespace devops-articles
   ```

2. **Wait for LoadBalancers to be deleted** (if any)
   ```bash
   kubectl get svc --all-namespaces
   # Ensure no LoadBalancer services remain
   ```

3. **Remove EBS CSI Driver addon**
   ```bash
   aws eks delete-addon \
     --cluster-name devops-articles-eks-cluster \
     --addon-name aws-ebs-csi-driver \
     --region us-east-1
   ```

4. **Delete IAM roles and policies**
   ```bash
   # Detach policy
   aws iam detach-role-policy \
     --role-name AmazonEKS_EBS_CSI_DriverRole \
     --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/AmazonEKS_EBS_CSI_Driver_Policy
   
   # Delete role
   aws iam delete-role --role-name AmazonEKS_EBS_CSI_DriverRole
   
   # Delete policy
   aws iam delete-policy \
     --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/AmazonEKS_EBS_CSI_Driver_Policy
   ```

5. **Run Terraform destroy**
   ```bash
   cd infra
   terraform destroy
   ```

   Type `yes` when prompted.

6. **Verify all resources are deleted**
   ```bash
   # Check EKS clusters
   aws eks list-clusters --region us-east-1
   
   # Check VPCs
   aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:Name,Values=*devops-articles*"
   
   # Check RDS instances
   aws rds describe-db-instances --region us-east-1
   
   # Check EBS volumes
   aws ec2 describe-volumes --region us-east-1 --filters "Name=tag:kubernetes.io/cluster/*,Values=owned"
   ```

7. **Manual cleanup (if needed)**
   
   If Terraform destroy fails, manually delete:
   - Orphaned EBS volumes
   - Stray load balancers
   - ENIs (Elastic Network Interfaces)
   - Security groups

   ```bash
   # Delete orphaned EBS volumes
   aws ec2 describe-volumes --region us-east-1 --filters "Name=status,Values=available" \
     --query "Volumes[*].VolumeId" --output text | \
     xargs -I {} aws ec2 delete-volume --volume-id {}
   ```

#### Cost Considerations

After teardown, verify no resources are left to avoid charges:
- EKS cluster (most expensive)
- NAT Gateway (~$32/month)
- RDS instances
- EBS volumes
- Elastic IPs (when not attached)

For detailed cleanup guide, see [infra/CLEANUP.md](./infra/CLEANUP.md).

---

## 📚 Additional Resources


### Documentation

- **[DevOps Report](./devops_report.md)** - Comprehensive DevOps analysis
- **[AWS Deployment Guide](./AWS_DEPLOYMENT.md)** - Detailed AWS deployment steps
- **[Railway Setup Guide](./RAILWAY_SETUP.md)** - Railway deployment instructions
- **[Secret Management](./SECRET_MANAGEMENT.md)** - Managing sensitive data
- **[Infrastructure Cleanup](./infra/CLEANUP.md)** - Teardown procedures
- **[Ansible README](./ansible/README.md)** - Automation with Ansible
- **[Monitoring Setup](./k8s/monitoring/README.md)** - Prometheus & Grafana

### External References

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Sequelize ORM](https://sequelize.org/)
- [Express.js](https://expressjs.com/)

---

## 📁 Project Structure

```
.
├── .github/workflows/          # CI/CD pipeline configuration
│   └── ci-cd.yml               # Main GitHub Actions workflow
├── config/                     # Database configuration
│   └── config.js               # Sequelize setup driven by env vars
├── init-db/                    # Database initialization scripts
├── migrations/                 # Sequelize migrations
├── models/                     # Sequelize models
├── routes/                     # Express route handlers
├── middleware/                 # Custom middleware
│   ├── auth.js                 # Authentication middleware
│   ├── admin.js                # Admin authorization
│   └── uploads.js              # File upload handling
├── ansible/                    # Ansible automation
│   ├── playbook.yaml           # Kubernetes deployment playbook
│   └── hosts.ini               # Inventory configuration
├── infra/                      # Terraform infrastructure as code
│   ├── provider.tf             # AWS provider configuration
│   ├── vpc.tf                  # VPC and networking
│   ├── eks.tf                  # EKS cluster configuration
│   ├── rds.tf                  # RDS database setup
│   ├── ec2.tf                  # EC2 instances (k3s alternative)
│   ├── security-groups.tf      # Security group rules
│   ├── variables.tf            # Terraform variables
│   ├── outputs.tf              # Output values
│   └── terraform.tfvars.example # Example variables file
├── k8s/                        # Kubernetes manifests
│   ├── 00-namespace.yaml       # Namespace definition
│   ├── 01-configmap.yaml       # Application configuration
│   ├── 02-secret.yaml.example  # Secrets template
│   ├── 03-postgres-storage.yaml # PostgreSQL PVC
│   ├── 04-postgres-statefulset.yaml # PostgreSQL deployment
│   ├── 05-postgres-service.yaml # PostgreSQL service
│   ├── 06-app-deployment.yaml  # Application deployment
│   ├── 07-app-service.yaml     # Application service
│   ├── 12-uploads-storage.yaml # Persistent uploads storage (EBS)
│   └── monitoring/             # Prometheus & Grafana configs
├── test/                       # Smoke tests
│   └── basic.test.js           # Basic health and redirect checks
├── views/                      # EJS templates
├── app.js                      # Express application
├── server.js                   # Application entry point
├── Dockerfile                  # Application container image
├── docker-compose.yml          # Multi-service container setup
├── docker-compose.test.yml     # Testing container setup
├── .dockerignore               # Build context exclusions
├── package.json                # Node.js dependencies and scripts
└── README.md                   # Project documentation
```

## 🐳 Docker Configuration

### Services

- **app**: Node.js application container
- **postgres**: PostgreSQL database container

### Features

- **Internal networking**: Services communicate through Docker's internal network
- **Persistent storage**: Database data and uploads persist using Docker volumes
  - `postgres_data`: PostgreSQL database files
  - `uploads_data`: User-uploaded images and documents
- **Health checks**: Both services include health monitoring
- **Security**: Non-root user execution, optimized image layers
- **Lean images**: .dockerignore keeps build context focused on runtime assets

### Available Commands

```bash
# Build and start all services
docker-compose up --build

# Run tests in containers
npm run test:docker

# Build Docker image manually
npm run docker:build

# View logs
docker-compose logs -f

# Stop and remove containers
docker-compose down -v
```

## 🔧 CI/CD Pipeline

The project includes a comprehensive 5-stage GitHub Actions pipeline:

### Pipeline Stages

1. **Build & Install**
   - Install Node.js dependencies
   - Cache node_modules for faster builds
   - Validate package integrity

2. **Lint & Security Scan**
   - ESLint code quality checks
   - npm audit for vulnerability scanning
   - Snyk security analysis
   - Generate security reports

3. **Test with Database**
   - Start PostgreSQL service
   - Run database migrations
   - Execute smoke tests
   - Validate application functionality

4. **Build Docker Image**
   - Build optimized Docker image
   - Run container tests
   - Push to Docker Hub (on main branch)
   - Generate metadata and tags

5. **Deploy (Conditional)**
   - Deploy to production (main branch only)
   - Update Render/Railway services
   - Generate deployment reports

### Pipeline Features

- **Conditional deployment**: Only deploys from main branch
- **Parallel execution**: Independent jobs run concurrently
- **Artifact management**: Security reports and build outputs preserved
- **Secrets management**: Secure handling of credentials
- **Status reporting**: Detailed pipeline summaries

## Security & Secrets Management

### GitHub Secrets Required

Set these secrets in your GitHub repository settings:

```bash
# Docker Hub credentials
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password

# Deployment credentials
RENDER_API_KEY=your_render_api_key
RENDER_SERVICE_ID=your_render_service_id

# Optional: Security scanning
SNYK_TOKEN=your_snyk_token
```

### Security Features

- **No hardcoded credentials**: All sensitive data uses environment variables
- **Container security**: Non-root user execution
- **Dependency scanning**: Automated vulnerability checks
- **Image optimization**: Minimal attack surface with Alpine Linux
- **Secret rotation**: Easy credential updates through GitHub Secrets

## Testing

### Test Types

- **Smoke tests**: Basic application functionality
- **Health checks**: Endpoint availability testing
- **Container tests**: Docker image validation
- **Integration tests**: Database connectivity verification

### Running Tests

```bash
# Local testing
npm test

# Docker container testing
npm run test:docker

# Lint checking
npm run lint

# Security audit
npm run security:audit
```

## Monitoring & Health Checks

### Application Health

- **Health endpoint**: `/health` - Returns application status
- **Database connectivity**: Automatic PostgreSQL connection validation
- **Container health**: Docker health check integration

### Monitoring Features

- Container health status monitoring
- Application startup validation
- Database connection verification
- Response time tracking

## Deployment

### AWS EKS Deployment (Production)

#### Prerequisites
- AWS CLI configured with appropriate credentials
- kubectl installed
- Terraform installed
- eksctl (optional, for easier IAM role creation)

#### Infrastructure Setup with Terraform

1. **Initialize Terraform**
   ```bash
   cd infra
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   terraform init
   ```

2. **Deploy Infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

   This creates:
   - VPC with public/private subnets across 2 AZs
   - EKS cluster with managed node groups
   - RDS PostgreSQL instance
   - Security groups and IAM roles
   - NAT Gateway for private subnet internet access

3. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name devops-articles-eks-cluster
   ```

#### EBS CSI Driver Setup (for Persistent Storage)

The application requires persistent storage for uploaded images and documents.

1. **Install EBS CSI Driver IAM Policy**
   ```bash
   cd infra
   aws iam create-policy \
     --policy-name AmazonEKS_EBS_CSI_Driver_Policy \
     --policy-document file://ebs-csi-policy.json
   ```

2. **Create IAM Role for EBS CSI Driver**
   ```bash
   # Get your OIDC provider
   aws eks describe-cluster --name devops-articles-eks-cluster --region us-east-1 \
     --query "cluster.identity.oidc.issuer" --output text
   
   # Create IAM role
   aws iam create-role \
     --role-name AmazonEKS_EBS_CSI_DriverRole \
     --assume-role-policy-document file://ebs-csi-trust-policy.json
   
   # Attach policy to role
   aws iam attach-role-policy \
     --role-name AmazonEKS_EBS_CSI_DriverRole \
     --policy-arn arn:aws:iam::<YOUR-ACCOUNT-ID>:policy/AmazonEKS_EBS_CSI_Driver_Policy
   ```

3. **Install EBS CSI Driver Addon**
   ```bash
   aws eks create-addon \
     --cluster-name devops-articles-eks-cluster \
     --addon-name aws-ebs-csi-driver \
     --service-account-role-arn arn:aws:iam::<YOUR-ACCOUNT-ID>:role/AmazonEKS_EBS_CSI_DriverRole \
     --region us-east-1
   ```

4. **Verify Installation**
   ```bash
   kubectl get pods -n kube-system | grep ebs-csi
   ```

#### Kubernetes Deployment

1. **Configure Secrets**
   ```bash
   cd k8s
   cp 02-secret.yaml.example 02-secret.yaml
   # Edit with your base64-encoded secrets:
   # - DB_PASSWORD
   # - RESEND_API_KEY
   # - SESSION_SECRET
   # - DATABASE_URL
   ```

2. **Deploy Application**
   ```bash
   # Apply all manifests in order
   kubectl apply -f 00-namespace.yaml
   kubectl apply -f 01-configmap.yaml
   kubectl apply -f 02-secret.yaml
   kubectl apply -f 12-uploads-storage.yaml  # Persistent storage for uploads
   kubectl apply -f 06-app-deployment.yaml
   kubectl apply -f 07-app-service.yaml
   ```

3. **Verify Deployment**
   ```bash
   kubectl get pods -n devops-articles
   kubectl get svc -n devops-articles
   kubectl get pvc -n devops-articles  # Verify persistent volume is bound
   ```

4. **Access Application**
   ```bash
   # Get LoadBalancer URL
   kubectl get svc app-service -n devops-articles
   ```

#### Ansible Automation (Optional)

For automated deployment:
```bash
cd ansible
# Update hosts.ini with your configuration
ansible-playbook -i hosts.ini playbook.yaml
```

### Docker Hub

Images are automatically pushed to Docker Hub:
```bash
docker pull your-dockerhub-username/devops-project-app:latest
```

### Render Deployment

The application auto-deploys to Render on main branch updates:
1. Pipeline builds and tests the application
2. Docker image is pushed to registry
3. Render service is triggered for deployment
4. Deployment status is reported

### Environment Configuration

Production environment variables:
```bash
NODE_ENV=production
DATABASE_URL=postgresql://user:password@host:port/database
PORT=3000
```

## 🛠️ Development Workflow

### Branch Strategy

- **main**: Production-ready code, auto-deploys
- **dev**: Development branch for integration
- **feature/***: Feature development branches

### Contribution Guidelines

1. Create feature branch from `dev`
2. Implement changes with tests
3. Submit pull request to `dev`
4. Merge to `main` after review and testing

### Code Quality

- ESLint configuration for code consistency
- Automated security scanning
- Comprehensive test coverage requirements
- Docker image optimization

## API Endpoints

## 📄 Documentation

- DevOps Report: [devops_report.md](./devops_report.md)

### Article Management

- `GET /` - Redirect to articles listing
- `GET /articles` - List all articles
- `GET /articles/create` - Article creation form
- `POST /articles` - Create new article
- `GET /articles/:id` - View specific article
- `PUT /articles/:id` - Update article
- `DELETE /articles/:id` - Delete article

### System Endpoints

- `GET /health` - Application health check

## Troubleshooting

### Common Issues

1. **Database connection errors**
   ```bash
   # Docker Compose
   docker-compose logs postgres
   docker-compose config
   
   # Kubernetes
   kubectl logs -n devops-articles -l component=postgres
   kubectl describe pod -n devops-articles -l component=postgres
   ```

2. **Persistent Volume Issues (Kubernetes)**
   ```bash
   # Check PVC status
   kubectl get pvc -n devops-articles
   
   # Describe PVC for events
   kubectl describe pvc uploads-pvc -n devops-articles
   
   # Verify EBS CSI driver is running
   kubectl get pods -n kube-system | grep ebs-csi
   
   # Check pod volume mounts
   kubectl describe pod -n devops-articles -l component=app
   ```

3. **File Upload Issues**
   ```bash
   # Verify uploads directory permissions
   kubectl exec -n devops-articles <pod-name> -- ls -la /app/uploads
   
   # Check persistent volume mount
   kubectl get pvc uploads-pvc -n devops-articles
   ```

4. **EBS CSI Driver Not Working**
   ```bash
   # Check driver pods
   kubectl get pods -n kube-system | grep ebs
   
   # Check driver logs
   kubectl logs -n kube-system -l app=ebs-csi-controller
   
   # Verify IAM role annotation
   kubectl describe sa ebs-csi-controller-sa -n kube-system
   ```

5. **Port conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep :3000
   
   # Use different ports
   PORT=3001 docker-compose up
   ```

6. **Build failures**
   ```bash
   # Clean Docker cache
   docker system prune -a
   
   # Rebuild without cache
   docker-compose build --no-cache
   ```

### Kubernetes Deployment Issues

1. **Pods not starting**
   ```bash
   kubectl get pods -n devops-articles
   kubectl describe pod <pod-name> -n devops-articles
   kubectl logs <pod-name> -n devops-articles
   ```

2. **LoadBalancer pending**
   ```bash
   # Check service
   kubectl get svc -n devops-articles
   kubectl describe svc app-service -n devops-articles
   ```

3. **Terraform Issues**
   ```bash
   # Re-initialize
   cd infra
   terraform init -upgrade
   
   # Check state
   terraform show
   
   # Destroy and recreate
   terraform destroy
   terraform apply
   ```

2. **Port conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep :3000
   
   # Use different ports
   PORT=3001 docker-compose up
   ```

3. **Build failures**
   ```bash
   # Clean Docker cache
   docker system prune -a
   
   # Rebuild without cache
   docker-compose build --no-cache
   ```

### Support

For issues and questions:
- Check the [GitHub Issues](https://github.com/HammadHafeez186/DevOps01-mid-Group-11/issues)
- Review the CI/CD pipeline logs
- Verify environment configuration

##  Additional Resources

### Architecture

The application follows a microservices-ready architecture:

```
┌─────────────────────────────────────────────────────┐
│                   AWS Cloud                          │
│  ┌────────────────────────────────────────────────┐ │
│  │              EKS Cluster                        │ │
│  │  ┌──────────────────────────────────────────┐  │ │
│  │  │     devops-articles namespace            │  │ │
│  │  │                                          │  │ │
│  │  │  ┌─────────────────┐  ┌──────────────┐  │  │ │
│  │  │  │  App Deployment │  │  PostgreSQL  │  │  │ │
│  │  │  │   (1 replica)   │  │ StatefulSet  │  │  │ │
│  │  │  └────────┬────────┘  └──────┬───────┘  │  │ │
│  │  │           │                   │          │  │ │
│  │  │  ┌────────▼────────┐  ┌──────▼───────┐  │  │ │
│  │  │  │  Uploads PVC    │  │ Postgres PVC │  │  │ │
│  │  │  │  (EBS 10Gi)     │  │  (EBS 10Gi)  │  │  │ │
│  │  │  └─────────────────┘  └──────────────┘  │  │ │
│  │  └──────────────────────────────────────────┘  │ │
│  │                                                 │ │
│  │  ┌──────────────────────────────────────────┐  │ │
│  │  │         kube-system                      │  │ │
│  │  │  ┌────────────────────────────────────┐  │  │ │
│  │  │  │    EBS CSI Driver                  │  │  │ │
│  │  │  │  - Controller (2 replicas)         │  │  │ │
│  │  │  │  - Node DaemonSet                  │  │  │ │
│  │  │  └────────────────────────────────────┘  │  │ │
│  │  └──────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────┘ │
│                                                       │
│  ┌────────────────┐      ┌─────────────────────┐     │
│  │ Application LB │──────│  RDS PostgreSQL     │     │
│  │  (External)    │      │  (Optional)         │     │
│  └────────────────┘      └─────────────────────┘     │
└───────────────────────────────────────────────────────┘
```

### Key Design Decisions

1. **Persistent Storage**: EBS volumes for both database and user uploads ensure data persists across pod restarts
2. **Single Replica**: Due to ReadWriteOnce limitation of EBS, app runs 1 replica (can be scaled with ReadWriteMany storage like EFS)
3. **StatefulSet for Database**: Ensures stable network identity and persistent storage
4. **IAM Roles for Service Accounts (IRSA)**: Secure AWS API access without credentials
5. **Infrastructure as Code**: Complete AWS infrastructure defined in Terraform
6. **GitOps Ready**: All Kubernetes manifests version-controlled and declarative

##  Additional Resources

### Documentation
- [DevOps Report](./devops_report.md)
- [AWS Deployment Guide](./AWS_DEPLOYMENT.md)
- [Railway Setup Guide](./RAILWAY_SETUP.md)
- [Infrastructure Cleanup](./infra/CLEANUP.md)
- [Deployment Checklist](./infra/DEPLOYMENT_CHECKLIST.md)

### External Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Sequelize Documentation](https://sequelize.org/)
- [Express.js Documentation](https://expressjs.com/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

## 📊 Project Metrics

- **Lines of Code**: ~5,000+ (application + infrastructure)
- **Docker Images**: Multi-stage optimized (~150MB)
- **Test Coverage**: Smoke tests + integration tests
- **Deployment Time**: ~2 minutes (Docker) | ~15 minutes (EKS)
- **Infrastructure**: 100% automated with Terraform
- **High Availability**: Multi-AZ deployment ready

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## 📝 License

This project is part of an academic course assignment.

---

**COMSATS University Islamabad, Lahore Campus**  
Course: DevOps for Cloud Computing (CSC418)  
Semester: Fall 2025 | Group 11

**Team Members:**
- Hammad Hafeez
- Abdullah Shahid

---

### Project Status: ✅ Production Ready

- ✅ Containerized application
- ✅ CI/CD pipeline operational
- ✅ Kubernetes manifests complete
- ✅ Terraform infrastructure validated
- ✅ Persistent storage configured
- ✅ AWS EKS deployment successful
- ✅ Monitoring ready
- ✅ Documentation complete
