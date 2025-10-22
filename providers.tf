terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    fabric = {
      source  = "microsoft/fabric"
      version = "~> 1.0"
    }
  }
}

# Azure Resource Manager Provider
# Used for creating Fabric Capacity in Azure
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
}

# Microsoft Fabric Provider
# Used for creating Fabric resources (workspaces, lakehouse, spark pools)
provider "fabric" {
  # Authentication is handled via Azure CLI
  # Run ./azure_login.sh before using Terraform

  # Note: Many Fabric APIs require user authentication
  # and do not support service principals yet
}
