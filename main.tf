terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.8.0"
    }
  }

resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East US"
}