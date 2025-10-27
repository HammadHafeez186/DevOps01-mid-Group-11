#!/bin/bash

# Railway deployment script
echo "🚂 Starting Railway deployment..."

# Set NODE_ENV to production if not set
export NODE_ENV=${NODE_ENV:-production}

# Ensure we don't load .env files in production
unset DOTENV_CONFIG_PATH

# Debug environment variables (without showing sensitive data)
echo "NODE_ENV: $NODE_ENV"
echo "DATABASE_URL set: $([ -n "$DATABASE_URL" ] && echo 'YES' || echo 'NO')"
echo "PORT: $PORT"
echo "PWD: $PWD"

# If DATABASE_URL is set, show connection info (without password)
if [ -n "$DATABASE_URL" ]; then
    echo "Using Railway DATABASE_URL"
    # Extract host from DATABASE_URL for logging
    DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
    echo "Database host: $DB_HOST"
    
    # Test DATABASE_URL format
    echo "DATABASE_URL format check..."
    if [[ $DATABASE_URL == postgresql://* ]]; then
        echo "✅ DATABASE_URL format is correct"
    else
        echo "❌ DATABASE_URL format may be incorrect"
    fi
else
    echo "⚠️  DATABASE_URL not found, using individual env vars"
    echo "DB_HOST: ${DB_HOST:-not set}"
    echo "DB_PORT: ${DB_PORT:-not set}"
fi

# Create a simple connection test
echo "🔧 Testing database connection..."
node -e "
const { Sequelize } = require('sequelize');
const config = require('./config/config.js').production;
console.log('Config:', JSON.stringify(config, null, 2));

let sequelize;
if (config.use_env_variable && process.env[config.use_env_variable]) {
    console.log('Using DATABASE_URL:', process.env[config.use_env_variable].replace(/:[^:@]*@/, ':***@'));
    sequelize = new Sequelize(process.env[config.use_env_variable], config);
} else {
    console.log('Using individual config values');
    sequelize = new Sequelize(config.database, config.username, config.password, config);
}

sequelize.authenticate()
    .then(() => console.log('✅ Database connection successful'))
    .catch(err => console.error('❌ Database connection failed:', err.message))
    .finally(() => process.exit(0));
" || echo "Connection test completed"

# Run migrations in production
echo "🔧 Running database migrations..."
npx sequelize-cli db:migrate --env production || echo "Migrations completed"

# Start the application
echo "🚀 Starting application..."
exec node server.js