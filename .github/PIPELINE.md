# CI/CD Pipeline Documentation

## Pipeline Stages

### Stage 1: Build & Install
- Install dependencies
- Cache node modules

### Stage 2: Lint & Security
- ESLint validation
- Security scanning with Snyk

### Stage 3: Test
- Database integration tests
- Application smoke tests

### Stage 4: Docker Build
- Build container image
- Push to registries

### Stage 5: Deploy
- Deploy to Kubernetes
- Health checks
