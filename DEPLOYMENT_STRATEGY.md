# Deployment Strategy Guide

## Overview
This document outlines the deployment strategies and rollback procedures for the application across different environments.

## Deployment Environments

### Development Environment
- **Target**: Local Kubernetes (k3s/minikube)
- **Deployment Method**: Direct kubectl apply
- **Validation**: Manual testing
- **Database**: Local PostgreSQL container

### Staging Environment
- **Target**: AWS EKS (staging cluster)
- **Deployment Method**: GitHub Actions CD pipeline
- **Validation**: Automated smoke tests + manual QA
- **Database**: AWS RDS (separate staging instance)

### Production Environment
- **Target**: AWS EKS (production cluster)
- **Deployment Method**: GitHub Actions CD with manual approval
- **Validation**: Health checks, smoke tests, gradual rollout
- **Database**: AWS RDS (production instance with multi-AZ)

## Rolling Update Strategy

### Configuration
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

### Process
1. New pod created (maxSurge: 1)
2. Wait for readiness probe to pass
3. Terminate one old pod (maxUnavailable: 0)
4. Repeat until all pods updated

### Benefits
- Zero downtime deployment
- Gradual rollout minimizes risk
- Automatic rollback on failure

## Blue-Green Deployment

### Use Cases
- Major version upgrades
- Database schema changes
- High-risk deployments

### Process
1. Deploy new version (green) alongside current (blue)
2. Run parallel testing on green environment
3. Switch traffic from blue to green via service selector
4. Monitor green for issues
5. Keep blue running for 24h as backup
6. Decommission blue after validation period

### Implementation
```bash
# Deploy green version
kubectl apply -f k8s/app-deployment-green.yaml

# Test green version
kubectl port-forward svc/app-service-green 8080:3000

# Switch traffic
kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'

# Rollback if needed
kubectl patch service app-service -p '{"spec":{"selector":{"version":"blue"}}}'
```

## Canary Deployment

### Configuration
- 10% traffic to canary initially
- Monitor metrics for 30 minutes
- Increase to 50% if healthy
- Full rollout if no issues detected

### Metrics to Monitor
- Error rate (should be <1%)
- Response time (P95 <1s)
- CPU/Memory usage
- Database connection pool
- Request success rate

### Implementation with Istio
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: app-service
spec:
  hosts:
  - app-service
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: app-service
        subset: canary
  - route:
    - destination:
        host: app-service
        subset: stable
      weight: 90
    - destination:
        host: app-service
        subset: canary
      weight: 10
```

## Rollback Procedures

### Automated Rollback
Kubernetes automatically rolls back if:
- New pods fail readiness checks
- Deployment progress deadline exceeded (10 minutes)
- Health check failures

### Manual Rollback
```bash
# View deployment history
kubectl rollout history deployment/app-deployment

# Rollback to previous version
kubectl rollout undo deployment/app-deployment

# Rollback to specific revision
kubectl rollout undo deployment/app-deployment --to-revision=3

# Check rollback status
kubectl rollout status deployment/app-deployment
```

### Database Rollback
1. Restore from automated backup (RDS snapshot)
2. Apply rollback migration scripts
3. Verify data integrity
4. Update application config to point to restored DB

## Pre-Deployment Checklist

- [ ] All tests passing in CI
- [ ] Database migrations tested in staging
- [ ] Secrets updated in AWS Secrets Manager
- [ ] Monitoring dashboards reviewed
- [ ] On-call engineer notified
- [ ] Rollback plan documented
- [ ] Backup verification completed

## Post-Deployment Validation

### Immediate (0-5 minutes)
- All pods in Running state
- Health checks passing
- No 5xx errors in logs
- Database connections stable

### Short-term (5-30 minutes)
- Response times within SLA
- Error rate <1%
- CPU/Memory usage normal
- No increase in alerts

### Long-term (30+ minutes)
- Business metrics stable
- User feedback monitored
- System performance trends normal
- No anomalies in application logs

## Emergency Procedures

### Critical Issue Response
1. Immediately execute rollback
2. Notify incident response team
3. Capture logs and metrics
4. Create incident report
5. Schedule post-mortem

### Communication Plan
- Slack: #incidents channel
- PagerDuty: Alert on-call engineer
- Status page: Update external status
- Email: Notify stakeholders

## Deployment Schedule

### Production Windows
- **Preferred**: Tuesday-Thursday, 10am-2pm EST
- **Avoid**: Fridays, weekends, holidays, business peak hours
- **Emergency**: Any time with VP approval

### Staging Deployments
- Continuous deployment from dev branch
- No restrictions on timing
- Automatic deployment on merge

## Monitoring During Deployment

### Key Metrics Dashboard
- Request rate and latency
- Error rate by endpoint
- Pod CPU and memory usage
- Database query performance
- Active connections

### Alert Thresholds
- Error rate >2%: Warning
- Error rate >5%: Critical (trigger rollback)
- Response time >2s: Warning
- Response time >5s: Critical

## Documentation Updates

After each deployment:
1. Update deployment log
2. Document any issues encountered
3. Update runbooks if procedures changed
4. Share lessons learned with team
