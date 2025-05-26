#!/bin/zsh
# Azure deployment script for containerized app

# Exit on error
set -e

# Configuration
ACR_NAME=$(terraform -chdir=infrastructure output -raw acr_name 2>/dev/null || echo "acrfriends${1:-dev}")
APP_SERVICE_NAME=$(terraform -chdir=infrastructure output -raw app_service_name 2>/dev/null)
RESOURCE_GROUP=$(terraform -chdir=infrastructure output -raw resource_group_name 2>/dev/null)

# Build and tag the Docker image
echo "Building and tagging Docker image..."
docker build -t friendsapp:latest .
docker tag friendsapp:latest ${ACR_NAME}.azurecr.io/friendsapp:latest

# Log in to Azure
echo "Logging in to Azure..."
az login

# Log in to Azure Container Registry
echo "Logging in to Azure Container Registry..."
az acr login --name ${ACR_NAME}

# Push the image to Azure Container Registry
echo "Pushing image to Azure Container Registry..."
docker push ${ACR_NAME}.azurecr.io/friendsapp:latest

# Restart the web app to pull the latest image
if [ -n "$APP_SERVICE_NAME" ] && [ -n "$RESOURCE_GROUP" ]; then
  echo "Restarting Azure Web App to pick up the new image..."
  az webapp restart --name ${APP_SERVICE_NAME} --resource-group ${RESOURCE_GROUP}
  echo "Deployment completed successfully!"
else
  echo "Infrastructure may not be deployed yet. Deploy infrastructure first with 'terraform apply' in the infrastructure directory."
fi
