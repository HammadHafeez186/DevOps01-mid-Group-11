# CI/CD Pipeline Documentation

## Pipeline Stages

### Stage 1: Build & Install
- Install dependencies with npm ci
- Cache node modules for faster builds
- Validate package integrity

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
