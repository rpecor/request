terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.98.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "rpecor"

# prefixed workspaces to support multiple environments in the future
    workspaces {
      prefix = "request-"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  naming = "${var.projectName}-${var.env}"
  tags = {
    project     = var.projectName
    region      = var.location
    environment = var.env
  }
}

resource "azurerm_resource_group" "request" {
  name     = "${local.naming}-rg"
  location = var.location

  tags = local.tags
}

# Create the App Service Plan, specifying SKU and capacity (instance count)
resource "azurerm_app_service_plan" "request_asp" {
  name                = "${local.naming}-asp"
  location            = var.location
  resource_group_name = azurerm_resource_group.request.name
  kind                = "Linux"
  reserved            = true
  per_site_scaling    = "true"
  sku {
    tier     = "Basic"
    size     = "B1"
    capacity = 2
  }

  tags = local.tags
}

# Build the service that runs on the App Service Plan 
resource "azurerm_app_service" "request_container" {
  name                = "${local.naming}-rc"
  location            = var.location
  resource_group_name = azurerm_resource_group.request.name
  app_service_plan_id = azurerm_app_service_plan.request_asp.id
  https_only          = true
  site_config {
    always_on                 = "false"
    linux_fx_version          = "DOCKER|ghcr.io/rpecor/request:${var.deploy_ID}" # this VAR is set in TFC, can be changed to update image or roll back
    health_check_path         = "/health"
    use_32_bit_worker_process = false
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://ghcr.io",
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false",
    "WEBSITES_PORT"                       = "3000"
  }

  tags = local.tags
}