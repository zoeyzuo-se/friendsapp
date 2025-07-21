#!/bin/zsh
# Azure deployment script for containerized app

# Exit on error
set -e

# Configuration
ENV=${1:-dev}
ACR_NAME=$(terraform -chdir=infrastructure output -raw acr_name 2>/dev/null || echo "acrfriends${ENV}")
APP_SERVICE_NAME=$(terraform -chdir=infrastructure output -raw app_service_name 2>/dev/null)
RESOURCE_GROUP=$(terraform -chdir=infrastructure output -raw resource_group_name 2>/dev/null)
TIMESTAMP=$(date +%Y%m%d%H%M%S)
IMAGE_TAG="v-${TIMESTAMP}"

echo "⚙️ Deploying to environment: ${ENV}"
echo "⚙️ Using ACR: ${ACR_NAME}"
echo "⚙️ App Service: ${APP_SERVICE_NAME}"
echo "⚙️ Resource Group: ${RESOURCE_GROUP}"

# Build and tag the Docker image
echo "🔨 Building and tagging Docker image..."
docker build -t friendsapp:${IMAGE_TAG} .
docker tag friendsapp:${IMAGE_TAG} ${ACR_NAME}.azurecr.io/friendsapp:${IMAGE_TAG}
docker tag friendsapp:${IMAGE_TAG} ${ACR_NAME}.azurecr.io/friendsapp:latest

# Log in to Azure
echo "🔑 Logging in to Azure..."
az account show &> /dev/null || az login

# Log in to Azure Container Registry
echo "🔑 Logging in to Azure Container Registry..."
az acr login --name ${ACR_NAME}

# Push the image to Azure Container Registry
echo "📤 Pushing image to Azure Container Registry..."
docker push ${ACR_NAME}.azurecr.io/friendsapp:${IMAGE_TAG}
docker push ${ACR_NAME}.azurecr.io/friendsapp:latest

# Restart the web app to pull the latest image
if [ -n "$APP_SERVICE_NAME" ] && [ -n "$RESOURCE_GROUP" ]; then
  echo "🔄 Restarting Azure Web App to pick up the new image..."
  az webapp restart --name ${APP_SERVICE_NAME} --resource-group ${RESOURCE_GROUP}
  
  # Get the app URL
  APP_URL=$(terraform -chdir=infrastructure output -raw app_service_url 2>/dev/null)
  echo "✅ Deployment completed successfully!"
  echo "🌐 Your app is available at: ${APP_URL}"
  echo "🧪 Health check: ${APP_URL}/api/health/"
else
  echo "⚠️ Infrastructure may not be deployed yet. Deploy infrastructure first with:"
  echo "   cd infrastructure && terraform init && terraform apply"
fi
