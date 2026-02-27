terraform {
  required_providers {
    azurerm = {
        source = "registry.terraform.io/hashicorp/azurerm"
        version = "~> 3.0.0"
    }
  }
  required_version = ">=1.9.0"
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}