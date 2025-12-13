#!/bin/sh

echo " Starting DevOps Articles in Docker..."
echo "DB_HOST: ${DB_HOST:-db}"
echo "DB_PORT: ${DB_PORT:-5432}"

# Wait for database to be ready
echo " Waiting for database to be ready..."
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
until nc -z $DB_HOST $DB_PORT; do
  echo "Trying to connect to $DB_HOST:$DB_PORT..."
  sleep 2
done

echo " Database is ready!"

# Run database migrations
echo " Running database migrations..."
NODE_ENV=docker npx sequelize-cli db:migrate

if [ $? -eq 0 ]; then
    echo " Migrations completed successfully"
else
    echo " Migration failed, exiting..."
    exit 1
fi

# Run seeders
echo " Running database seeders..."
NODE_ENV=docker npx sequelize-cli db:seed:all || echo " No seeders"

echo " Starting application server..."
node server.js
