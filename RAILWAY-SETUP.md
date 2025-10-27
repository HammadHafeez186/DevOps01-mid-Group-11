# Railway Database Setup - URGENT FIX

## Problem
Railway is not automatically providing database environment variables.

## Solution
You must manually add the DATABASE_URL in Railway Dashboard.

## Steps:

1. Go to Railway Dashboard
2. Select your project
3. Click on your Web Service (not the database)
4. Go to "Variables" tab
5. Add these variables:

```
NODE_ENV=production
DATABASE_URL=postgresql://[PGUSER]:[PGPASSWORD]@[PGHOST]:[PGPORT]/[PGDATABASE]
```

**Get these values from your Railway PostgreSQL service settings:**
- PGUSER: postgres
- PGPASSWORD: [from Railway PostgreSQL service]
- PGHOST: [from Railway PostgreSQL service - Public Networking]
- PGPORT: [from Railway PostgreSQL service - Public Networking] 
- PGDATABASE: railway

6. Click "Deploy" to redeploy with the new variable

## Alternative: Individual Variables
If DATABASE_URL doesn't work, add these instead:

```
NODE_ENV=production
PGHOST=[from Railway PostgreSQL Public Networking]
PGPORT=[from Railway PostgreSQL Public Networking] 
PGUSER=postgres
PGPASSWORD=[from Railway PostgreSQL service settings]
PGDATABASE=railway
```

## Security Note
These credentials are already exposed in your PostgreSQL service settings in Railway, so adding them as environment variables doesn't create additional security risk.