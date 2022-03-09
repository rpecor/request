terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.98.0"
    }
  }
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "rpecor"
    
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
    project = var.projectName
    region = var.location
    environment = var.env
  }
}

resource "azurerm_resource_group" "example" {
  name     = "${local.naming}-rg"
  location = var.location

  tags = local.tags
}