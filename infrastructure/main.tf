terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Random string for unique resource names
resource "random_string" "resource_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-friendsapp-${var.environment}-${random_string.resource_suffix.result}"
  location = var.location
  tags     = var.tags
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrfriends${var.environment}${random_string.resource_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = var.tags
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "psql-friendsapp-${var.environment}-${random_string.resource_suffix.result}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "14"
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7
  
  tags = var.tags
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "profiles_db" {
  name      = "friendsapp_profiles"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Allow Azure services to access PostgreSQL
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Storage Account for profile images
resource "azurerm_storage_account" "storage" {
  name                     = "stfriends${var.environment}${random_string.resource_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.tags
}

# Container for profile images
resource "azurerm_storage_container" "media" {
  name                  = "media"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"
}

# App Service Plan
resource "azurerm_service_plan" "app_plan" {
  name                = "asp-friendsapp-${var.environment}-${random_string.resource_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  
  tags = var.tags
}

# App Service
resource "azurerm_linux_web_app" "app_service" {
  name                = "app-friendsapp-${var.environment}-${random_string.resource_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.app_plan.id
  
  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.acr.login_server}/friendsapp"
      docker_image_tag = "latest"
    }
    always_on = true
  }
  
  app_settings = {
    "WEBSITES_PORT"                     = "8000"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"        = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"   = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"   = azurerm_container_registry.acr.admin_password
    "DJANGO_SETTINGS_MODULE"            = "core.settings"
    "DEBUG"                             = "False"
    "ALLOWED_HOSTS"                     = "${azurerm_linux_web_app.app_service.default_hostname},${var.custom_domain}"
    "DATABASE_URL"                      = "postgres://${var.db_admin_username}:${var.db_admin_password}@${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/${azurerm_postgresql_flexible_server_database.profiles_db.name}"
    "AZURE_STORAGE_ACCOUNT_NAME"        = azurerm_storage_account.storage.name
    "AZURE_STORAGE_ACCOUNT_KEY"         = azurerm_storage_account.storage.primary_access_key
    "AZURE_STORAGE_CONTAINER"           = azurerm_storage_container.media.name
    "SECRET_KEY"                        = var.django_secret_key
  }
  
  tags = var.tags
}

# Output the App Service URL
output "app_service_url" {
  value = "https://${azurerm_linux_web_app.app_service.default_hostname}"
}

# Output the App Service name
output "app_service_name" {
  value = azurerm_linux_web_app.app_service.name
}

# Output the Resource Group name
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

# Output the PostgreSQL server FQDN
output "postgresql_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

# Output the Storage Account name
output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

# Output the ACR name
output "acr_name" {
  value = azurerm_container_registry.acr.name
}
