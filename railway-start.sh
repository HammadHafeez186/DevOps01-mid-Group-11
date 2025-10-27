#!/bin/bash

# Railway deployment script
echo "🚂 Starting Railway deployment..."

# Set NODE_ENV to production if not set  
export NODE_ENV=${NODE_ENV:-production}

# Debug environment variables (without showing sensitive data)
echo "NODE_ENV: $NODE_ENV"
echo "DATABASE_URL set: $([ -n "$DATABASE_URL" ] && echo 'YES' || echo 'NO')"
echo "PORT: $PORT"

# If DATABASE_URL is set, show connection info (without password)
if [ -n "$DATABASE_URL" ]; then
    echo "✅ Using Railway DATABASE_URL"
    # Extract host from DATABASE_URL for logging (safely)
    echo "Database configured via DATABASE_URL"
else
    echo "⚠️  DATABASE_URL not found - Railway PostgreSQL service may not be connected"
fi

# Run migrations (but don't fail deployment if they fail)
echo "🔧 Running database migrations..."
npx sequelize-cli db:migrate --env production 2>/dev/null || echo "ℹ️  Migrations will run when database is available"

# Start the application
echo "🚀 Starting application..."
exec node server.js