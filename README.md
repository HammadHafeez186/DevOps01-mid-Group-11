# DevOps Project - Article Management System

[![CI/CD Pipeline](https://github.com/HammadHafeez186/DevOps01-mid-Group-11/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/HammadHafeez186/DevOps01-mid-Group-11/actions/workflows/ci-cd.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/your-dockerhub-username/devops-project-app)](https://hub.docker.com/r/your-dockerhub-username/devops-project-app)

A containerized Node.js application with Express, Sequelize ORM, and PostgreSQL database, featuring a complete DevOps pipeline with CI/CD automation, Kubernetes orchestration, and infrastructure as code with Terraform. The application supports file uploads with persistent storage and includes comprehensive monitoring capabilities.

## ✨ Key Features

- **Full Stack Application**: Node.js/Express backend with EJS templating
- **User Authentication**: Complete auth system with session management
- **File Uploads**: Support for images and documents with persistent EBS storage
- **Admin Panel**: User management and content moderation
- **Complaint System**: User feedback and reporting mechanism
- **Database ORM**: Sequelize with PostgreSQL
- **Containerization**: Docker and Docker Compose
- **Kubernetes Ready**: Complete K8s manifests with StatefulSets and PVCs
- **Infrastructure as Code**: Terraform for AWS resource provisioning
- **Configuration Management**: Ansible playbooks for automated deployment
- **CI/CD Pipeline**: GitHub Actions with automated testing and deployment
- **Production Deployment**: AWS EKS with LoadBalancer and persistent storage
- **Monitoring**: Prometheus and Grafana integration ready

## 🛠️ Technology Stack

### Application
- **Runtime**: Node.js 18
- **Framework**: Express.js
- **Template Engine**: EJS
- **ORM**: Sequelize
- **Database**: PostgreSQL 15
- **File Uploads**: Multer with persistent storage
- **Authentication**: Express-session with bcrypt
- **Email**: Resend API

### DevOps & Infrastructure
- **Containerization**: Docker, Docker Compose
- **Orchestration**: Kubernetes (EKS)
- **Infrastructure as Code**: Terraform
- **Configuration Management**: Ansible
- **CI/CD**: GitHub Actions
- **Cloud Provider**: AWS
  - EKS (Elastic Kubernetes Service)
  - RDS (PostgreSQL)
  - EBS (Elastic Block Store) for persistent volumes
  - VPC with public/private subnets
  - Application Load Balancer
- **Container Registry**: Amazon ECR, Docker Hub
- **Monitoring**: Prometheus, Grafana (configured)

### AWS Services Used
- **EKS**: Managed Kubernetes cluster
- **EBS CSI Driver**: Persistent volume provisioning
- **RDS**: Managed PostgreSQL database
- **VPC**: Network isolation and security
- **IAM**: Role-based access control
- **ECR**: Private container registry
- **CloudWatch**: Logging and metrics

## 🌐 Live Demo (Railway)

- Articles: https://web-production-cf2cb.up.railway.app/articles


## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)
- Git

### Using Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/HammadHafeez186/DevOps01-mid-Group-11.git
   cd DevOps01-mid-Group-11
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your preferred values
   ```

3. **Configure Kubernetes secrets (for K8s deployment)**
   ```bash
   cp k8s/02-secret.yaml.example k8s/02-secret.yaml
   # Edit k8s/02-secret.yaml and replace all REPLACE_WITH_* placeholders:
   # - DB_PASSWORD: Your PostgreSQL password
   # - RESEND_API_KEY: Your Resend API key for email
   # - SESSION_SECRET: Generate with: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   # - DATABASE_URL: Full PostgreSQL connection string
   # NOTE: Never commit k8s/02-secret.yaml - it's in .gitignore
   ```

4. **Start the application**
   ```bash
   docker-compose up --build
   ```

4. **Access the application**
   - Application: http://localhost:3000
   - Health Check: http://localhost:3000/health

### Local Development

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Start PostgreSQL (using Docker)**
   ```bash
   docker run -d --name postgres-dev \
     -e POSTGRES_USER=devops_user \
     -e POSTGRES_PASSWORD=secure_password_123 \
     -e POSTGRES_DB=devops_db \
     -p 5432:5432 postgres:15-alpine
   ```

3. **Run database migrations**
   ```bash
   npx sequelize-cli db:migrate
   npx sequelize-cli db:seed:all
   ```

4. **Start the application**
   ```bash
   npm run dev
   ```

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
