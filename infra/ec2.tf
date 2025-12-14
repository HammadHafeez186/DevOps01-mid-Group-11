# Free Tier Optimized: EC2 Instances for Kubernetes (k3s)
# This replaces the expensive EKS cluster

# EC2 Instance for k3s (Lightweight Kubernetes)
resource "aws_instance" "k3s_server" {
  count         = var.use_eks ? 0 : 1
  ami           = data.aws_ami.ubuntu[0].id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name

  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.ec2_k3s.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = base64encode(templatefile("${path.module}/k3s-install.sh", {
    db_endpoint = aws_db_instance.postgres.endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = random_password.db_password.result
  }))

  tags = {
    Name = "${var.project_name}-k3s-server"
    Role = "kubernetes-master"
  }

  depends_on = [aws_db_instance.postgres]
}

# Data source for latest Ubuntu AMI (only when not using EKS)
data "aws_ami" "ubuntu" {
  count       = var.use_eks ? 0 : 1
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for EC2 k3s instance
resource "aws_security_group" "ec2_k3s" {
  name_prefix = "${var.project_name}-ec2-k3s-sg"
  description = "Security group for EC2 k3s instance"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "SSH access"
  }

  # Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Kubernetes API"
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTP"
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTPS"
  }

  # NodePort range
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Kubernetes NodePort range"
  }

  # App port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Application port"
  }

  # k3s metrics
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "k3s metrics"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-ec2-k3s-sg"
  }
}

# Elastic IP for k3s server (optional, for consistent IP)
resource "aws_eip" "k3s_server" {
  count    = var.use_eks ? 0 : 1
  instance = aws_instance.k3s_server[0].id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-k3s-eip"
  }
}
