# Environment Setup Instructions

## Local Development Setup

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Update `.env` with your actual values:**
   - `DB_PASSWORD`: Your PostgreSQL password
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub personal access token

## GitHub Secrets Setup (for CI/CD)

Add these secrets to your GitHub repository:
- Go to: Settings → Secrets and Variables → Actions
- Add the following secrets:

| Secret Name | Description |
|-------------|-------------|
| `DOCKER_USERNAME` | Your Docker Hub username |
| `DOCKER_PASSWORD` | Your Docker Hub personal access token |

## Security Notes

- ⚠️ **Never commit `.env` files** - they contain sensitive information
- ✅ **Use `.env.example`** as a template for other developers
- 🔐 **Use GitHub Secrets** for CI/CD credentials
- 🛡️ **Enable push protection** to prevent accidental secret commits