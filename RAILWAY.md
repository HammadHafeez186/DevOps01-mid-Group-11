# Railway Deployment Guide

## Environment Variables in Railway

Railway automatically provides these environment variables:
- `DATABASE_URL` - From PostgreSQL service (automatically configured)
- `NODE_ENV=production` - Set automatically
- `PORT` - Assigned automatically by Railway

## Manual Variables NOT Needed

Do not manually set these in Railway Variables tab:
- DB_USERNAME, DB_PASSWORD, DB_NAME, DB_HOST, DB_PORT
- These are handled by DATABASE_URL

## Railway Setup Steps

1. Add PostgreSQL service to your Railway project
2. Railway will automatically set DATABASE_URL
3. Redeploy your web service
4. Your app will connect using config/config.js production settings

## Local Development vs Railway

- **Local**: Uses .env file with individual DB variables
- **Railway**: Uses DATABASE_URL automatically from PostgreSQL service