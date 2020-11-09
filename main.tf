terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.35.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "rg-westeu-cn" {
  name     = "rg-westeu-cn"
  location = var.location
}