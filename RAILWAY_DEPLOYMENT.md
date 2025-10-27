# 🚂 Railway Deployment Guide

## Why Railway?
- ✅ **Zero-config** deployment from GitHub
- ✅ **Automatic** Node.js detection
- ✅ **Built-in** PostgreSQL database
- ✅ **Simple** API for CI/CD
- ✅ **Free tier** available

## Step-by-Step Setup

### 1. Create Railway Account
1. Go to https://railway.app
2. Click "Start a New Project"
3. Sign up with your GitHub account

### 2. Deploy Your App
1. In Railway dashboard, click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose your `DevOps01-mid-Group-11` repository
4. Railway will automatically:
   - Detect Node.js project
   - Install dependencies
   - Build and deploy

### 3. Add PostgreSQL Database
1. In your project dashboard, click "New"
2. Select "Database" → "PostgreSQL"
3. Railway automatically provides:
   - `DATABASE_URL` environment variable
   - Connection string format: `postgresql://user:password@host:port/database`

### 4. Configure Environment Variables
In Railway dashboard → Your service → Variables tab, add:
```bash
NODE_ENV=production
PORT=${{PORT}}
DATABASE_URL=${{Postgres.DATABASE_URL}}
```

### 5. Set up GitHub Actions Integration

#### Required GitHub Secrets:
1. Go to your GitHub repo → Settings → Secrets and variables → Actions
2. Add these secrets:

**RAILWAY_TOKEN:**
1. In Railway dashboard → Account Settings → Tokens
2. Create new token → Copy value

**RAILWAY_SERVICE_ID:**
1. In Railway project → Service → Settings
2. Copy Service ID from URL or settings

### 6. Test Deployment
1. Push to `main` branch
2. GitHub Actions will automatically:
   - Build and test your app
   - Build Docker image
   - Deploy to Railway
   - Show deployment logs

## Benefits of This Setup

### 🔄 Automatic Deployments
- Every push to `main` triggers deployment
- Full CI/CD pipeline with testing

### 📊 Deployment Logs in Pipeline
- Real-time deployment status
- Error logs if deployment fails
- Success confirmation with URLs

### 🐳 Docker Integration
- Railway can deploy from Docker images
- Or directly from source code (simpler)

### 💾 Database Management
- Built-in PostgreSQL with backups
- Automatic connection string injection
- Web-based database browser

## Alternative: Direct GitHub Integration

### Even Simpler Setup:
1. Railway dashboard → New Project
2. "Deploy from GitHub repo"
3. Select your repo
4. Railway handles everything automatically!

**No GitHub Actions needed** - Railway watches your repo and deploys on every push to main.

## Comparison: Railway vs Render

| Feature | Railway | Render |
|---------|---------|---------|
| Setup Time | 2 minutes | 10 minutes |
| Config Required | Zero | Multiple steps |
| Database Setup | 1 click | Separate service |
| GitHub Integration | Built-in | Manual webhook |
| Free Tier | $5 credit | Limited hours |
| Deployment Speed | Fast | Moderate |

## Next Steps
1. Sign up for Railway
2. Connect your GitHub repo
3. Add database
4. Push to main branch
5. Watch it deploy! 🚀

## Troubleshooting
- **Build fails?** Check `package.json` scripts
- **Database connection?** Verify `DATABASE_URL` variable
- **Port issues?** Use `process.env.PORT` in your app