#!/bin/bash
# Azure App Service deployment script

# Wait for the database to be ready
if [ ! -z "$DATABASE_URL" ]; then
  echo "Waiting for PostgreSQL to be ready..."
  
  # Extract host and port from DATABASE_URL
  if [[ $DATABASE_URL == postgres://* ]]; then
    DB_HOST=$(echo "$DATABASE_URL" | sed -e 's/^postgres:\/\/[^:]*:[^@]*@\([^:]*\).*$/\1/')
    DB_PORT=$(echo "$DATABASE_URL" | sed -e 's/^postgres:\/\/[^:]*:[^@]*@[^:]*:\([0-9]*\).*$/\1/')
    
    # Default to port 5432 if not specified
    if [ -z "$DB_PORT" ]; then
      DB_PORT=5432
    fi
    
    # Wait for database connection
    until pg_isready -h "$DB_HOST" -p "$DB_PORT"; do
      echo "Database not ready - waiting..."
      sleep 2
    done
    
    echo "Database is ready!"
  fi
fi

# Run database migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Set the port for Gunicorn
PORT=${PORT:-8000}

# Start Gunicorn
echo "Starting Gunicorn on port $PORT..."
gunicorn core.wsgi:application --bind=0.0.0.0:"$PORT"
