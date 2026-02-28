terraform {
  required_providers {
    azurerm = {
        source = "registry.terraform.io/hashicorp/azurerm"
        version = "~> 4.0.0"
    }
  }

required_version = ">=1.9.0"
}

resource "azurerm_resource_group" "test_rg" {
  name     = "example-resources"
  location = "West Europe"
}
