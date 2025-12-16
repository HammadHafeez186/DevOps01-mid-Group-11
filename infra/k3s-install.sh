#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Install k3s (Lightweight Kubernetes)
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# Wait for k3s to be ready
sleep 30

# Install kubectl (already included with k3s)
ln -s /usr/local/bin/k3s /usr/local/bin/kubectl

# Create namespace
kubectl create namespace devops-articles || true

# Create database secret
kubectl create secret generic app-secret \
  --namespace=devops-articles \
  --from-literal=DB_PASSWORD='${db_password}' \
  --from-literal=DATABASE_URL='postgresql://${db_username}:${db_password}@${db_endpoint}/${db_name}' \
  --from-literal=RESEND_API_KEY='your-resend-api-key' \
  --from-literal=SESSION_SECRET='change-me-in-production' \
  --dry-run=client -o yaml | kubectl apply -f - || true

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Save kubeconfig to home directory
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Install metrics-server for monitoring
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Create a marker file to indicate setup is complete
touch /var/log/k3s-setup-complete

echo "k3s installation complete!"
echo "Kubernetes API: https://$(curl -s ifconfig.me):6443"
echo "Access with: kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes"
