# Monitoring Stack - Prometheus & Grafana

This directory contains Kubernetes manifests for deploying Prometheus and Grafana monitoring stack.

## Components

1. **Prometheus** - Metrics collection and storage
2. **Grafana** - Visualization and dashboards

## Quick Deploy

```bash
# Deploy all monitoring components
kubectl apply -f k8s/monitoring/

# Check deployment status
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

## Access URLs

### Get Prometheus URL:
```bash
kubectl get svc prometheus -n monitoring
# Access via LoadBalancer external IP on port 9090
```

### Get Grafana URL:
```bash
kubectl get svc grafana -n monitoring
# Access via LoadBalancer external IP on port 3000
```

### Default Grafana Credentials:
- Username: `admin`
- Password: `admin123`

## What's Being Monitored

- Kubernetes cluster metrics
- Node metrics
- Pod metrics
- DevOps Articles application pods
- PostgreSQL database (if metrics exposed)

## Grafana Dashboards

### Recommended Dashboards to Import:

1. **Kubernetes Cluster Monitoring** (ID: 7249)
2. **Kubernetes Pod Monitoring** (ID: 6417)
3. **Node Exporter Full** (ID: 1860)
4. **PostgreSQL Database** (ID: 9628)

### Import Dashboard:
1. Login to Grafana
2. Click "+" → "Import"
3. Enter dashboard ID
4. Select Prometheus datasource
5. Click "Import"

## Custom Metrics

To expose custom metrics from your application:

1. Install prom-client in your app:
   ```bash
   npm install prom-client
   ```

2. Add metrics endpoint in your app (example):
   ```javascript
   const promClient = require('prom-client');
   const register = new promClient.Registry();
   promClient.collectDefaultMetrics({ register });
   
   app.get('/metrics', async (req, res) => {
     res.set('Content-Type', register.contentType);
     res.end(await register.metrics());
   });
   ```

3. Add annotation to pod to enable scraping:
   ```yaml
   annotations:
     prometheus.io/scrape: "true"
     prometheus.io/port: "3000"
     prometheus.io/path: "/metrics"
   ```

## Cleanup

```bash
kubectl delete -f k8s/monitoring/
```

## Troubleshooting

### Prometheus not scraping targets:
```bash
# Check Prometheus logs
kubectl logs -n monitoring deployment/prometheus

# Check service accounts and RBAC
kubectl get sa -n monitoring
kubectl get clusterrole prometheus
kubectl get clusterrolebinding prometheus
```

### Grafana can't connect to Prometheus:
```bash
# Verify Prometheus service
kubectl get svc prometheus -n monitoring

# Test connection from Grafana pod
kubectl exec -n monitoring deployment/grafana -- curl http://prometheus:9090/-/healthy
```

### Check metrics availability:
```bash
# Port-forward Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Visit http://localhost:9090/targets to see all targets
```

## Production Recommendations

For production use, consider:
- Using persistent volumes for Prometheus and Grafana
- Setting up alerting rules
- Configuring retention policies
- Implementing high availability
- Securing with authentication
- Using Ingress instead of LoadBalancer
