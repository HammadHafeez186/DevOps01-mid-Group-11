# K8s Quick Reference

## File Structure
```
k8s/
├── 00-namespace.yaml          # Namespace isolation
├── 01-configmap.yaml          # Non-sensitive configuration
├── 02-secret.yaml             # Sensitive data (DB password, API keys)
├── 03-postgres-storage.yaml   # PersistentVolume & PersistentVolumeClaim
├── 04-postgres-statefulset.yaml  # PostgreSQL database
├── 05-postgres-service.yaml   # Database service (headless)
├── 06-app-deployment.yaml     # Node.js app with 2 replicas
├── 07-app-service.yaml        # App service (LoadBalancer)
└── 08-hpa.yaml                # Auto-scaling (HPA)
```

## Quick Start

### 1. Install tools
```powershell
# Windows
choco install minikube kubectl docker-desktop

# Or manually download from:
# - kubectl: https://kubernetes.io/docs/tasks/tools/
# - minikube: https://minikube.sigs.k8s.io/
```

### 2. Start minikube
```bash
minikube start --cpus 4 --memory 4096
minikube addons enable metrics-server
```

### 3. Build Docker image
```powershell
 docker build -t devopsproject01-app:latest .
```

### 4. Create secrets (no hardcoded credentials)
Edit `k8s/02-secret.yaml` to replace `CHANGEME_*` or create the secret ad-hoc:
```bash
kubectl create namespace devops-articles
kubectl delete secret app-secret -n devops-articles --ignore-not-found
kubectl create secret generic app-secret -n devops-articles \
  --from-literal=DB_PASSWORD='<db-password>' \
  --from-literal=SESSION_SECRET='<random-long-secret>' \
  --from-literal=RESEND_API_KEY='<resend-api-key>' \
  --from-literal=DATABASE_URL='postgresql://postgres:<db-password>@postgres-service:5432/devops_db'
```

### 5. Deploy to K8s
```powershell
# Using PowerShell script
.\scripts\k8s-deploy.ps1 -Context minikube

# Or manually
kubectl apply -f k8s/
```

### 6. Access the app
```bash
# Option A: Minikube service
minikube service app-service -n devops-articles

# Option B: Port forward
kubectl port-forward svc/app-service 8080:80 -n devops-articles
# Visit: http://localhost:8080
```

> TLS toggle: `k8s/01-configmap.yaml` sets `DB_SSL=false` for the in-cluster Postgres. Switch to `"true"` (and update `DATABASE_URL`) when using a managed database that enforces SSL.

---

## Common Tasks

### Check deployment status
```bash
kubectl get pods -n devops-articles -w
kubectl describe pod APP_POD_NAME -n devops-articles
```

### View logs
```bash
# App logs
kubectl logs -f deployment/app -n devops-articles

# Database logs
kubectl logs -f statefulset/postgres -n devops-articles
```

### Connect to database
```bash
# Port-forward to localhost
kubectl port-forward svc/postgres-service 5432:5432 -n devops-articles

# Then connect locally
psql -h localhost -U postgres -d devops_db
```

### Restart deployment
```bash
kubectl rollout restart deployment/app -n devops-articles
```

### Scale manually
```bash
kubectl scale deployment app --replicas=5 -n devops-articles
```

### View auto-scaling status
```bash
kubectl get hpa -n devops-articles
kubectl describe hpa app-hpa -n devops-articles
```

### Update image
```bash
# Rebuild and push
docker build -t devopsproject01-app:latest .
docker tag devopsproject01-app:latest yourusername/devopsproject01-app:latest
docker push yourusername/devopsproject01-app:latest

# Update deployment to use new image
kubectl set image deployment/app app=yourusername/devopsproject01-app:latest -n devops-articles
```

### Update configuration
```bash
# Edit ConfigMap
kubectl edit configmap app-config -n devops-articles

# Edit Secret
kubectl edit secret app-secret -n devops-articles

# Apply changes (may need to restart pods)
kubectl rollout restart deployment/app -n devops-articles
```

### Delete everything
```bash
kubectl delete namespace devops-articles
```

---

## Verification Checklist

After deployment, verify:

- [ ] All pods are `Running` and `Ready`
  ```bash
  kubectl get pods -n devops-articles
  ```

- [ ] Services have IPs assigned
  ```bash
  kubectl get svc -n devops-articles
  ```

- [ ] Database is accessible
  ```bash
  kubectl exec -it pod/postgres-0 -n devops-articles -- psql -U postgres -d devops_db -c "SELECT 1;"
  ```

- [ ] App can connect to database
  ```bash
  kubectl logs -f deployment/app -n devops-articles
  # Should see: "Database connection successful" or similar
  ```

- [ ] External IP/Port is accessible
  ```bash
  minikube service app-service -n devops-articles
  # Or check: kubectl get svc app-service -n devops-articles
  ```

---

## Resource Allocation

### Current limits in manifests:
- **App (node.js)**
  - Request: 256Mi memory, 250m CPU
  - Limit: 512Mi memory, 500m CPU
  - Replicas: 2 (auto-scales to 10)

- **Database (PostgreSQL)**
  - Request: 256Mi memory, 250m CPU
  - Limit: 512Mi memory, 500m CPU
  - Storage: 10Gi

### For production, adjust based on:
- Expected traffic
- Data volume
- Cloud provider quotas
- Cost constraints

---

## Next Steps for Production

1. **Update secrets** - Replace hardcoded passwords with secure values
2. **Setup cloud registry** - Push images to ECR/DockerHub/GCR
3. **Cloud deployment** - Deploy to AWS EKS, GCP GKE, or Azure AKS
4. **Setup monitoring** - Install Prometheus + Grafana
5. **Setup logging** - Install ELK stack or use cloud logging
6. **Setup backups** - Database backup strategy
7. **Setup CI/CD** - GitHub Actions to build & push images
8. **Setup Ingress** - Domain name + SSL/TLS certificates
9. **Security** - Network policies, RBAC, Pod Security Policy
10. **Documentation** - Runbooks for operations

---

## Troubleshooting

### Pod fails to start
```bash
# Check events
kubectl describe pod POD_NAME -n devops-articles

# Check logs
kubectl logs pod/POD_NAME -n devops-articles

# Debug
kubectl exec -it pod/POD_NAME -n devops-articles -- /bin/sh
```

### Can't connect to app
```bash
# Check service
kubectl get svc app-service -n devops-articles

# Check endpoints
kubectl get endpoints app-service -n devops-articles

# Test from pod
kubectl exec -it pod/app-xxxxx -n devops-articles -- curl http://localhost:3000
```

### Database connection fails
```bash
# Test DNS resolution
kubectl exec -it pod/app-xxxxx -n devops-articles -- nslookup postgres-service

# Test TCP connectivity
kubectl exec -it pod/app-xxxxx -n devops-articles -- nc -zv postgres-service 5432
```

---

## References

- **Kubernetes Docs**: https://kubernetes.io/docs/
- **Kubectl Cheat Sheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- **Minikube Docs**: https://minikube.sigs.k8s.io/
- **K8s Best Practices**: https://kubernetes.io/docs/concepts/configuration/overview/
