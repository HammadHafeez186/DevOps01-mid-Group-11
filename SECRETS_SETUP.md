# GitHub Secrets Configuration

This document lists all the GitHub Secrets that need to be configured for the CI/CD pipeline to work properly.

## Required Secrets

### AWS Configuration
- `AWS_ACCESS_KEY_ID` - AWS access key for Terraform and EKS deployment
- `AWS_SECRET_ACCESS_KEY` - AWS secret access key
- `AWS_ACCOUNT_ID` - Your AWS account ID (e.g., 322467327252)

### Application Secrets
- `RESEND_API_KEY` - Resend API key for email functionality
  - Format: `re_XXXXXXXXXXXXXXXXXXXX`
  - Get from: https://resend.com/api-keys
- `SESSION_SECRET` - Express session secret for secure cookie encryption
  - Format: 64-character hex string
  - Generate: `openssl rand -hex 32`

## How to Add Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its name and value

## Secret Values Reference

**IMPORTANT: Never commit actual secret values to the repository!**

Add these secrets to GitHub Actions (Settings → Secrets and variables → Actions):

```bash
# Application Secrets
RESEND_API_KEY=re_YOUR_ACTUAL_RESEND_API_KEY_HERE
SESSION_SECRET=YOUR_64_CHARACTER_HEX_STRING_HERE

# AWS Secrets (from your AWS account)
AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
AWS_ACCOUNT_ID=322467327252
```

### How to Generate SESSION_SECRET

```bash
# On Linux/Mac
openssl rand -hex 32

# On Windows PowerShell
-join ((48..57) + (97..102) | Get-Random -Count 64 | ForEach-Object {[char]$_})
```

## Database Credentials

Database credentials are automatically managed:
- `DB_PASSWORD` - Retrieved from AWS Secrets Manager (created by Terraform)
- `DATABASE_URL` - Constructed automatically with RDS endpoint from Terraform outputs

The Ansible playbook automatically:
1. Retrieves the RDS endpoint from Terraform outputs
2. Fetches the password from AWS Secrets Manager
3. URL-encodes the password to handle special characters
4. Creates the Kubernetes secret with all required values

## Verification

After adding secrets to GitHub, you can verify they're configured by:
1. Going to Settings → Secrets and variables → Actions
2. You should see all secrets listed (values are hidden)
3. The CI/CD pipeline will use these secrets during deployment

## Security Notes

- Never commit secrets to the repository
- Rotate secrets regularly
- Use different secrets for different environments (dev/staging/prod)
- The SESSION_SECRET should be a random 64-character hex string
- The RESEND_API_KEY is obtained from your Resend account dashboard
