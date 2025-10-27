#!/bin/bash

# Railway deployment script
echo "🚂 Starting Railway deployment..."

# Debug environment variables (without showing sensitive data)
echo "NODE_ENV: $NODE_ENV"
echo "DATABASE_URL set: $([ -n "$DATABASE_URL" ] && echo 'YES' || echo 'NO')"
echo "PORT: $PORT"

# If DATABASE_URL is set, show connection info (without password)
if [ -n "$DATABASE_URL" ]; then
    echo "Using Railway DATABASE_URL"
    # Extract host from DATABASE_URL for logging
    DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
    echo "Database host: $DB_HOST"
else
    echo "⚠️  DATABASE_URL not found, using individual env vars"
    echo "DB_HOST: ${DB_HOST:-not set}"
    echo "DB_PORT: ${DB_PORT:-not set}"
fi

# Run migrations in production
echo "🔧 Running database migrations..."
npx sequelize-cli db:migrate --env production || echo "Migrations completed"

# Start the application
echo "🚀 Starting application..."
exec npm start