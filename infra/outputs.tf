output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# EKS Outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = var.use_eks ? aws_eks_cluster.main[0].id : "N/A - Using EC2 with k3s"
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = var.use_eks ? aws_eks_cluster.main[0].endpoint : "N/A - Using EC2 with k3s"
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = var.use_eks ? aws_eks_cluster.main[0].name : "N/A - Using EC2 with k3s"
}

# EC2 Outputs (when not using EKS)
output "k3s_server_public_ip" {
  description = "Public IP of k3s server"
  value       = var.use_eks ? "N/A - Using EKS" : (length(aws_eip.k3s_server) > 0 ? aws_eip.k3s_server[0].public_ip : aws_instance.k3s_server[0].public_ip)
}

output "k3s_server_id" {
  description = "EC2 instance ID of k3s server"
  value       = var.use_eks ? "N/A - Using EKS" : aws_instance.k3s_server[0].id
}

output "ssh_command" {
  description = "SSH command to connect to k3s server"
  value       = var.use_eks ? "N/A - Using EKS" : "ssh -i ~/.ssh/${var.ec2_key_name}.pem ubuntu@${length(aws_eip.k3s_server) > 0 ? aws_eip.k3s_server[0].public_ip : aws_instance.k3s_server[0].public_ip}"
}

output "kubernetes_api_url" {
  description = "Kubernetes API URL"
  value       = var.use_eks ? "Use kubectl with EKS" : "https://${length(aws_eip.k3s_server) > 0 ? aws_eip.k3s_server[0].public_ip : aws_instance.k3s_server[0].public_ip}:6443"
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = var.use_eks ? aws_eks_cluster.main[0].vpc_config[0].cluster_security_group_id : "N/A - Using EC2 with k3s"
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster certificate authority data"
  value       = var.use_eks ? aws_eks_cluster.main[0].certificate_authority[0].data : "N/A - Using EC2 with k3s"
  sensitive   = true
}

output "eks_node_group_id" {
  description = "EKS node group ID"
  value       = var.use_eks ? aws_eks_node_group.main[0].id : "N/A - Using EC2 with k3s"
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  description = "RDS instance address"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.postgres.db_name
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.postgres.username
  sensitive   = true
}

# Security Group Outputs
output "eks_security_group_id" {
  description = "EKS control plane security group ID"
  value       = aws_security_group.eks_cluster.id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

# Configuration command for kubectl
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = var.use_eks ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main[0].name}" : "scp -i ~/.ssh/${var.ec2_key_name}.pem ubuntu@${length(aws_eip.k3s_server) > 0 ? aws_eip.k3s_server[0].public_ip : aws_instance.k3s_server[0].public_ip}:/etc/rancher/k3s/k3s.yaml ~/.kube/config"
}

# Cost Estimation
output "estimated_monthly_cost" {
  description = "Estimated monthly AWS cost"
  value       = var.use_eks ? "~$200-250 (EKS + EC2 + RDS + NAT)" : (var.use_nat_gateway ? "~$50-60 (EC2 + RDS + NAT)" : "~$15-20 (EC2 + RDS, Free Tier Eligible)")
}
