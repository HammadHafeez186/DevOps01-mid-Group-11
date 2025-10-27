# DevOps Project - Article Management System

[![CI/CD Pipeline](https://github.com/HammadHafeez186/DevOps01-mid-Group-11/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/HammadHafeez186/DevOps01-mid-Group-11/actions/workflows/ci-cd.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/your-dockerhub-username/devops-project-app)](https://hub.docker.com/r/your-dockerhub-username/devops-project-app)

A containerized Node.js application with Express, Sequelize ORM, and PostgreSQL database, featuring a complete DevOps pipeline with CI/CD automation.

## � Live Demo (Railway)

- Articles: https://web-production-cf2cb.up.railway.app/articles


## �🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)
- Git

### Using Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/HammadHafeez186/DevOps01-mid-Group-11.git
   cd DevOps01-mid-Group-11
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your preferred values
   ```

3. **Start the application**
   ```bash
   docker-compose up --build
   ```

4. **Access the application**
   - Application: http://localhost:3000
   - Health Check: http://localhost:3000/health

### Local Development

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Start PostgreSQL (using Docker)**
   ```bash
   docker run -d --name postgres-dev \
     -e POSTGRES_USER=devops_user \
     -e POSTGRES_PASSWORD=secure_password_123 \
     -e POSTGRES_DB=devops_db \
     -p 5432:5432 postgres:15-alpine
   ```

3. **Run database migrations**
   ```bash
   npx sequelize-cli db:migrate
   npx sequelize-cli db:seed:all
   ```

4. **Start the application**
   ```bash
   npm run dev
   ```

## 📁 Project Structure

```
.
├── .github/workflows/          # CI/CD pipeline configuration
│   └── ci-cd.yml              # Main GitHub Actions workflow
├── config/                    # Database configuration
│   └── config.json           # Sequelize configuration
├── init-db/                   # Database initialization scripts
│   └── init.sh               # PostgreSQL setup script
├── migrations/                # Database migrations
├── models/                    # Sequelize models
├── seeders/                   # Database seeders
├── test/                      # Test files
│   └── basic.test.js         # Basic smoke tests
├── views/                     # EJS templates
├── .env.example              # Environment variables template
├── app.js                    # Express application
├── docker-compose.yml        # Multi-service container setup
├── docker-compose.test.yml   # Testing container setup
├── Dockerfile               # Application container image
├── healthcheck.js           # Application health check
├── package.json             # Node.js dependencies and scripts
└── server.js                # Application entry point
```

## 🐳 Docker Configuration

### Services

- **app**: Node.js application container
- **postgres**: PostgreSQL database container

### Features

- **Internal networking**: Services communicate through Docker's internal network
- **Persistent storage**: Database data persists using Docker volumes
- **Health checks**: Both services include health monitoring
- **Security**: Non-root user execution, optimized image layers

### Available Commands

```bash
# Build and start all services
docker-compose up --build

# Run tests in containers
npm run test:docker

# Build Docker image manually
npm run docker:build

# View logs
docker-compose logs -f

# Stop and remove containers
docker-compose down -v
```

## 🔧 CI/CD Pipeline

The project includes a comprehensive 5-stage GitHub Actions pipeline:

### Pipeline Stages

1. **Build & Install**
   - Install Node.js dependencies
   - Cache node_modules for faster builds
   - Validate package integrity

2. **Lint & Security Scan**
   - ESLint code quality checks
   - npm audit for vulnerability scanning
   - Snyk security analysis
   - Generate security reports

3. **Test with Database**
   - Start PostgreSQL service
   - Run database migrations
   - Execute smoke tests
   - Validate application functionality

4. **Build Docker Image**
   - Build optimized Docker image
   - Run container tests
   - Push to Docker Hub (on main branch)
   - Generate metadata and tags

5. **Deploy (Conditional)**
   - Deploy to production (main branch only)
   - Update Render/Railway services
   - Generate deployment reports

### Pipeline Features

- **Conditional deployment**: Only deploys from main branch
- **Parallel execution**: Independent jobs run concurrently
- **Artifact management**: Security reports and build outputs preserved
- **Secrets management**: Secure handling of credentials
- **Status reporting**: Detailed pipeline summaries

## Security & Secrets Management

### GitHub Secrets Required

Set these secrets in your GitHub repository settings:

```bash
# Docker Hub credentials
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password

# Deployment credentials
RENDER_API_KEY=your_render_api_key
RENDER_SERVICE_ID=your_render_service_id

# Optional: Security scanning
SNYK_TOKEN=your_snyk_token
```

### Security Features

- **No hardcoded credentials**: All sensitive data uses environment variables
- **Container security**: Non-root user execution
- **Dependency scanning**: Automated vulnerability checks
- **Image optimization**: Minimal attack surface with Alpine Linux
- **Secret rotation**: Easy credential updates through GitHub Secrets

## Testing

### Test Types

- **Smoke tests**: Basic application functionality
- **Health checks**: Endpoint availability testing
- **Container tests**: Docker image validation
- **Integration tests**: Database connectivity verification

### Running Tests

```bash
# Local testing
npm test

# Docker container testing
npm run test:docker

# Lint checking
npm run lint

# Security audit
npm run security:audit
```

## Monitoring & Health Checks

### Application Health

- **Health endpoint**: `/health` - Returns application status
- **Database connectivity**: Automatic PostgreSQL connection validation
- **Container health**: Docker health check integration

### Monitoring Features

- Container health status monitoring
- Application startup validation
- Database connection verification
- Response time tracking

## Deployment

### Docker Hub

Images are automatically pushed to Docker Hub:
```bash
docker pull your-dockerhub-username/devops-project-app:latest
```

### Render Deployment

The application auto-deploys to Render on main branch updates:
1. Pipeline builds and tests the application
2. Docker image is pushed to registry
3. Render service is triggered for deployment
4. Deployment status is reported

### Environment Configuration

Production environment variables:
```bash
NODE_ENV=production
DATABASE_URL=postgresql://user:password@host:port/database
PORT=3000
```

## 🛠️ Development Workflow

### Branch Strategy

- **main**: Production-ready code, auto-deploys
- **dev**: Development branch for integration
- **feature/***: Feature development branches

### Contribution Guidelines

1. Create feature branch from `dev`
2. Implement changes with tests
3. Submit pull request to `dev`
4. Merge to `main` after review and testing

### Code Quality

- ESLint configuration for code consistency
- Automated security scanning
- Comprehensive test coverage requirements
- Docker image optimization

## API Endpoints

## 📄 Documentation

- DevOps Report: [devops_report.md](./devops_report.md)

### Article Management

- `GET /` - Redirect to articles listing
- `GET /articles` - List all articles
- `GET /articles/create` - Article creation form
- `POST /articles` - Create new article
- `GET /articles/:id` - View specific article
- `PUT /articles/:id` - Update article
- `DELETE /articles/:id` - Delete article

### System Endpoints

- `GET /health` - Application health check

## Troubleshooting

### Common Issues

1. **Database connection errors**
   ```bash
   # Check PostgreSQL container status
   docker-compose logs postgres
   
   # Verify environment variables
   docker-compose config
   ```

2. **Port conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep :3000
   
   # Use different ports
   PORT=3001 docker-compose up
   ```

3. **Build failures**
   ```bash
   # Clean Docker cache
   docker system prune -a
   
   # Rebuild without cache
   docker-compose build --no-cache
   ```

### Support

For issues and questions:
- Check the [GitHub Issues](https://github.com/HammadHafeez186/DevOps01-mid-Group-11/issues)
- Review the CI/CD pipeline logs
- Verify environment configuration

##  Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Sequelize Documentation](https://sequelize.org/)
- [Express.js Documentation](https://expressjs.com/)

---

**COMSATS University Islamabad, Lahore Campus**  
Course: DevOps for Cloud Computing (CSC418)  
Semester: Fall 2025 | Group 11 (Hammad Hafeez, Abdullah Shahid)