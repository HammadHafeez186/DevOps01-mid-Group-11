#!/bin/sh
set -e

echo " Starting DevOps Articles in Docker..."
echo "DB_HOST: ${DB_HOST:-db}"
echo "DB_PORT: ${DB_PORT:-5432}"

# Wait for database to be ready
echo " Waiting for database to be ready..."
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
until nc -z "$DB_HOST" "$DB_PORT"; do
  echo "Trying to connect to $DB_HOST:$DB_PORT..."
  sleep 2
done

echo " Database is ready!"

# Run database migrations
echo " Running database migrations..."
NODE_TLS_REJECT_UNAUTHORIZED=${NODE_TLS_REJECT_UNAUTHORIZED:-0} NODE_ENV=docker npx sequelize-cli db:migrate

echo " Migrations completed successfully"

# Run seeders
echo " Running database seeders..."
NODE_TLS_REJECT_UNAUTHORIZED=${NODE_TLS_REJECT_UNAUTHORIZED:-0} NODE_ENV=docker npx sequelize-cli db:seed:all || echo " No seeders"

echo " Starting application server..."
exec node server.js
