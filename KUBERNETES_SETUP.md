# Kubernetes Setup Guide for DevOps Articles

## Prerequisites

### Install kubectl
- **Windows:** https://kubernetes.io/docs/tasks/tools/install-kubectl-on-windows/
- **Mac:** `brew install kubectl`
- **Linux:** `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`

### Install minikube (Local Testing)
```bash
# Windows
choco install minikube

# Mac
brew install minikube

# Linux
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Build Docker Image for K8s
```powershell
# Ensure you're in the project root
docker build -t devopsproject01-app:latest .

# For cloud registry (e.g., DockerHub):
# docker tag devopsproject01-app:latest yourusername/devopsproject01-app:latest
# docker push yourusername/devopsproject01-app:latest
# Then update image in k8s/06-app-deployment.yaml
```

---

## 1. Local K8s Testing with Minikube

### Start Minikube
```bash
# Start with sufficient resources
minikube start --cpus 4 --memory 4096

# Enable metrics-server (for HPA)
minikube addons enable metrics-server

# Get minikube status
minikube status

# Access dashboard
minikube dashboard
```

### Deploy to Local Cluster
```powershell
# Set kubectl context to minikube
kubectl config use-context minikube

# Apply all manifests in order
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-configmap.yaml
kubectl apply -f k8s/02-secret.yaml
kubectl apply -f k8s/03-postgres-storage.yaml
kubectl apply -f k8s/04-postgres-statefulset.yaml
kubectl apply -f k8s/05-postgres-service.yaml
kubectl apply -f k8s/06-app-deployment.yaml
kubectl apply -f k8s/07-app-service.yaml
kubectl apply -f k8s/08-hpa.yaml

# Or apply all at once
kubectl apply -f k8s/

# Tip: replace CHANGEME_* in k8s/02-secret.yaml or create the secret manually:
# kubectl create secret generic app-secret -n devops-articles \
#   --from-literal=DB_PASSWORD='<db-password>' \
#   --from-literal=SESSION_SECRET='<random-long-secret>' \
#   --from-literal=RESEND_API_KEY='<resend-api-key>' \
#   --from-literal=DATABASE_URL='postgresql://postgres:<db-password>@postgres-service:5432/devops_db'
```

### Verify Deployment
```bash
# Check namespace
kubectl get ns

# Check all resources in namespace
kubectl get all -n devops-articles

# Check pods
kubectl get pods -n devops-articles -w

# Check services
kubectl get svc -n devops-articles

# Check PVC
kubectl get pvc -n devops-articles
```

### Access the App Locally
```bash
# Get service info
kubectl get svc app-service -n devops-articles

# For minikube, get the external IP
minikube service app-service -n devops-articles

# Or manually
kubectl port-forward svc/app-service 8080:80 -n devops-articles
# Visit http://localhost:8080
```

### Check Logs
```bash
# App logs
kubectl logs -f deployment/app -n devops-articles

# Postgres logs
kubectl logs -f statefulset/postgres -n devops-articles

# Specific pod
kubectl logs pod/app-xxxxx -n devops-articles
```

### Debug Deployment
```bash
# Describe pod (events, conditions)
kubectl describe pod app-xxxxx -n devops-articles

# Enter pod shell
kubectl exec -it pod/app-xxxxx -n devops-articles -- /bin/sh

# Run debug container
kubectl debug pod/app-xxxxx -n devops-articles -it
```

---

## 2. Cloud Deployment (AWS EKS / GCP GKE / Azure AKS)

### AWS EKS Example

```bash
# Install eksctl
brew install eksctl  # or choco install eksctl

# Create cluster
eksctl create cluster --name devops-articles --region us-east-1 --nodes 2

# Update kubectl context
aws eks update-kubeconfig --region us-east-1 --name devops-articles

# Apply manifests
kubectl apply -f k8s/

# Check status
kubectl get nodes
kubectl get pods -n devops-articles
```

### GCP GKE Example

```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash

# Authenticate
gcloud auth login

# Create cluster
gcloud container clusters create devops-articles \
  --zone us-central1-a \
  --num-nodes 2 \
  --machine-type n1-standard-1

# Update kubectl context
gcloud container clusters get-credentials devops-articles --zone us-central1-a

# Apply manifests
kubectl apply -f k8s/
```

### Important for Cloud

1. **Update image in k8s/06-app-deployment.yaml**
   ```yaml
   image: yourusername/devopsproject01-app:latest
   imagePullPolicy: Always
   ```

2. **Create StorageClass** (cloud provider specific)
   ```yaml
   # For AWS EBS
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: ebs
   provisioner: ebs.csi.aws.com
   ```

3. **Update PersistentVolume** to use cloud storage
   - Remove `hostPath` from `k8s/03-postgres-storage.yaml`
   - Use cloud-native storage (AWS EBS, GCP PD, Azure Disks)

4. **DB SSL toggle**: `k8s/01-configmap.yaml` sets `DB_SSL=false` for in-cluster Postgres. Set to `"true"` (and update `DATABASE_URL`) when using a managed DB that enforces TLS.

5. **Setup Ingress** (instead of LoadBalancer)
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: app-ingress
     namespace: devops-articles
   spec:
     rules:
     - host: yourdomain.com
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: app-service
               port:
                 number: 80
   ```

---

## 3. Managing Secrets Securely

### Current Setup (NOT for production)
```bash
# Secrets are in plain-text YAML
# Only use for local/testing
```

### Production: Use External Secret Management

**Option A: Kubernetes Sealed Secrets**
```bash
# Install sealed-secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/controller.yaml

# Seal a secret
echo -n Hammad1234 | kubectl create secret generic app-secret \
  --dry-run=client --from-file=db-password=/dev/stdin -o json \
  | kubeseal -f - > sealed-secret.yaml
```

**Option B: AWS Secrets Manager / GCP Secret Manager**
```bash
# Use cloud-native secret management
# Reference via ServiceAccount + IAM roles
```

**Option C: HashiCorp Vault**
```bash
# Enterprise secret management
# Integrate with K8s via external-secrets operator
```

---

## 4. Database Migrations in K8s

### Run migrations on pod startup
Your `scripts/docker-start.sh` already handles this. Ensure it:
```bash
#!/bin/bash
set -e

# Wait for postgres
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 1
done

# Run migrations
npx sequelize-cli db:migrate --env docker

# Start app
node server.js
```

### Manual migration if needed
```bash
# Connect to pod
kubectl exec -it pod/app-xxxxx -n devops-articles -- /bin/sh

# Run migrations
npx sequelize-cli db:migrate --env docker
```

---

## 5. Monitoring & Logging

### Install Prometheus + Grafana
```bash
# Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n devops-articles
```

### Install ELK Stack (Elasticsearch + Kibana + Beats)
```bash
# For log aggregation
helm repo add elastic https://helm.elastic.co
helm repo update

helm install elasticsearch elastic/elasticsearch -n devops-articles
helm install kibana elastic/kibana -n devops-articles
```

---

## 6. Auto-Scaling

### HPA is configured in k8s/08-hpa.yaml
```bash
# Check HPA status
kubectl get hpa -n devops-articles

# Describe HPA
kubectl describe hpa app-hpa -n devops-articles

# Watch autoscaling
kubectl get hpa -n devops-articles -w
```

### Generate load to test scaling
```bash
# Inside cluster
kubectl run -it --rm load-generator --image=busybox:1.28 \
  -n devops-articles -- /bin/sh

# Inside pod, run:
while sleep 0.01; do wget -q -O- http://app-service/; done
```

---

## 7. Troubleshooting

### Pod won't start
```bash
# Check events
kubectl describe pod app-xxxxx -n devops-articles

# Check logs
kubectl logs pod/app-xxxxx -n devops-articles

# Check image exists
docker images | grep devopsproject01-app
```

### Can't connect to database
```bash
# Check postgres service
kubectl get svc postgres-service -n devops-articles

# Test connection from app pod
kubectl exec -it pod/app-xxxxx -n devops-articles -- \
  nc -zv postgres-service 5432
```

### No external IP assigned
```bash
# For minikube, use port-forward
kubectl port-forward svc/app-service 8080:80 -n devops-articles

# For cloud, ensure LoadBalancer controller is running
kubectl get svc app-service -n devops-articles -w
```

### PVC not binding
```bash
# Check PVC status
kubectl get pvc -n devops-articles

# Check PV
kubectl get pv

# Describe for errors
kubectl describe pvc postgres-pvc -n devops-articles
```

---

## 8. Cleanup

### Delete everything
```bash
# Delete namespace (cascades to all resources)
kubectl delete namespace devops-articles

# Or delete specific resources
kubectl delete -f k8s/
```

### Stop minikube
```bash
minikube stop
minikube delete  # Complete cleanup
```

---

## 9. Checklist Before Production

- [ ] Update image to production Docker Hub/ECR image
- [ ] Change DB_PASSWORD to secure value in Secret
- [ ] Update APP_URL to production domain in ConfigMap
- [ ] Setup cloud storage (not hostPath)
- [ ] Enable Ingress with SSL/TLS certificates
- [ ] Setup monitoring (Prometheus/Grafana)
- [ ] Setup log aggregation (ELK/CloudWatch)
- [ ] Configure resource limits properly
- [ ] Setup backup strategy for PostgreSQL
- [ ] Enable RBAC and network policies
- [ ] Use Sealed Secrets or cloud secret manager
- [ ] Setup CI/CD pipeline (GitHub Actions, GitLab CI) to push images
- [ ] Test failover scenarios
- [ ] Document runbooks

---

## Useful Commands Reference

```bash
# General
kubectl cluster-info
kubectl get nodes
kubectl api-resources

# Namespace
kubectl get ns
kubectl create ns devops-articles
kubectl delete ns devops-articles

# Pods
kubectl get pods -n devops-articles
kubectl get pods -n devops-articles -w
kubectl describe pod POD_NAME -n devops-articles
kubectl logs pod/POD_NAME -n devops-articles
kubectl logs -f deployment/app -n devops-articles
kubectl exec -it pod/POD_NAME -n devops-articles -- /bin/sh

# Deployments
kubectl get deployments -n devops-articles
kubectl describe deployment app -n devops-articles
kubectl rollout status deployment/app -n devops-articles
kubectl rollout history deployment/app -n devops-articles
kubectl rollout undo deployment/app -n devops-articles

# Services
kubectl get svc -n devops-articles
kubectl describe svc app-service -n devops-articles
kubectl port-forward svc/app-service 8080:80 -n devops-articles

# ConfigMap & Secret
kubectl get configmap -n devops-articles
kubectl get secret -n devops-articles
kubectl edit configmap app-config -n devops-articles

# Storage
kubectl get pvc -n devops-articles
kubectl get pv

# HPA
kubectl get hpa -n devops-articles
kubectl describe hpa app-hpa -n devops-articles

# Updates
kubectl set image deployment/app app=newimage:tag -n devops-articles
kubectl rollout restart deployment/app -n devops-articles
kubectl scale deployment app --replicas=5 -n devops-articles
```
