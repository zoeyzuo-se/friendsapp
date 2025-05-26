# Friends App - Profile Management Service

A Django-based backend API service for a Tinder-like app. This service is responsible for user profile management.

## Features

- RESTful API for profile management
- Profile image storage using Azure Blob Storage
- PostgreSQL database for data persistence
- Health check endpoint

## API Endpoints

- `POST /api/profiles/` – Create a user profile
- `GET /api/profiles/{id}/` – Retrieve a user profile
- `GET /api/health/` – Service health check

## Prerequisites

- Python 3.10+
- Poetry for dependency management
- Azure account (for production deployment)

## Local Development Setup

1. Clone the repository:
   ```
   git clone <repository-url>
   cd friendsapp
   ```

2. Install dependencies:
   ```
   poetry install
   ```

3. Configure environment variables:
   Create a `.env` file based on the provided example.

4. Run database migrations:
   ```
   poetry run python manage.py migrate
   ```

5. Start the development server:
   ```
   poetry run python manage.py runserver
   ```

6. Access the API at http://localhost:8000/api/

## Docker Development Setup

1. Build and run the Docker containers:
   ```
   docker-compose up --build
   ```

2. Access the API at http://localhost:8000/api/

## Deployment

This project is configured for deployment to Azure using Terraform and Docker containers.

### Infrastructure Deployment

1. Navigate to the `infrastructure` directory
2. Initialize Terraform:
   ```
   terraform init
   ```
3. Apply the Terraform configuration:
   ```
   terraform apply
   ```

### Application Deployment

1. Build and deploy the Docker image to Azure:
   ```
   ./deploy.sh
   ```

This script will:
- Build the Docker image
- Push it to Azure Container Registry
- Restart the Azure Web App to pick up the new image

## Environment Variables

The following environment variables should be set in production:

- `DEBUG`: Set to 'False' in production
- `SECRET_KEY`: A secure random string
- `ALLOWED_HOSTS`: Comma-separated list of hostnames
- `DATABASE_URL`: PostgreSQL connection string
- `AZURE_STORAGE_ACCOUNT_NAME`: Azure Storage account name
- `AZURE_STORAGE_ACCOUNT_KEY`: Azure Storage account key
- `AZURE_STORAGE_CONTAINER`: Azure Storage container name (default: 'media')