#!/bin/bash
# Azure App Service deployment script

echo "Starting deployment script at $(date)"

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
    
    # Wait for database connection with timeout
    echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
    RETRY_COUNT=0
    MAX_RETRIES=30
    
    until pg_isready -h "$DB_HOST" -p "$DB_PORT" -q; do
      RETRY_COUNT=$((RETRY_COUNT+1))
      if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "Failed to connect to PostgreSQL after $MAX_RETRIES attempts."
        echo "Continuing anyway, but migrations might fail."
        break
      fi
      echo "Database not ready - waiting... ($RETRY_COUNT/$MAX_RETRIES)"
      sleep 2
    done
    
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      echo "Database is ready!"
    fi
  fi
fi

# Run database migrations
echo "Running database migrations..."
python manage.py migrate --noinput || echo "Migrations failed, but continuing..."

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create media directory if it doesn't exist
mkdir -p media/profile_pictures

# Set the port for Gunicorn
PORT=${PORT:-8000}
WORKERS=${WORKERS:-4}
TIMEOUT=${TIMEOUT:-120}

# Start Gunicorn with proper settings for production
echo "Starting Gunicorn on port $PORT with $WORKERS workers..."
gunicorn core.wsgi:application \
  --bind=0.0.0.0:"$PORT" \
  --workers="$WORKERS" \
  --timeout="$TIMEOUT" \
  --access-logfile=- \
  --error-logfile=- \
  --log-level=info
