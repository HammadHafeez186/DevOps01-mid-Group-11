variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "devops-articles"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner/Team name"
  type        = string
  default     = "devops-team"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"] # Minimum 2 AZs for RDS
}

# EC2 Configuration (Free Tier Alternative to EKS)
variable "ec2_instance_type" {
  description = "EC2 instance type for k3s server"
  type        = string
  default     = "t2.micro" # Free tier eligible: 750 hours/month
}

variable "ec2_key_name" {
  description = "SSH key pair name for EC2 access"
  type        = string
  default     = "" # Must be created in AWS Console first
}

variable "use_eks" {
  description = "Use EKS cluster (expensive) or EC2 with k3s (free tier)"
  type        = bool
  default     = true # Set to true for EKS deployment
}

variable "use_nat_gateway" {
  description = "Use NAT Gateway (costs ~$32/month) or public subnets only"
  type        = bool
  default     = true # Required for EKS private nodes
}

# EKS Configuration
variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.34"
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "eks_min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "eks_max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

# RDS Configuration
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS (GB)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "devops_db"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_multi_az" {
  description = "Enable multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

# Security
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change this to your IP for production
}
