terraform {
    #################################################
    # Before initialising the environment by running init.sh, comment the backend section.
    # Once the initilisation is completed uncomment this code, replace the storage_account_name with yours and rerun Terraform Init
    # to switch from local backend to remote Azure backend
    #################################################
    backend "azurerm" {
      resource_group_name = "WindowsHybrid"
      storage_account_name = "winhybrid78cd8e59" # Replace this with your storage account name.
      container_name = "tfstate"
      key = "backend.terraform.tfstate"
      use_azuread_auth = true
    }

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "4.17.0"
    }
  }
}

provider "azurerm" {
    features {}
    resource_provider_registrations = "none"
}

# Generate a random ID (4 bytes)
resource "random_id" "random_suffix" {
  byte_length = 4
}

# The resource group created with the init.sh script.
data "azurerm_resource_group" "windows_hybrid" {
    name = var.resource_group_name
}

# Deploy the storage account to the existing resource group.
resource "azurerm_storage_account" "storage_statefile" {
    name = "${var.storage_account_name}${random_id.random_suffix.hex}"
    resource_group_name = data.azurerm_resource_group.windows_hybrid.name
    location = data.azurerm_resource_group.windows_hybrid.location
    account_tier = "Standard"
    account_replication_type = "LRS"
    
    blob_properties {
      versioning_enabled = true
      delete_retention_policy {
        days = 7
      }
      container_delete_retention_policy {
        days = 7
      }
    }
    
    share_properties {
      retention_policy {
        days = 7
      }
    }

    

    tags = {
      utility = "terraform"
    }
}

# Create the container.
resource "azurerm_storage_container" "storage_statefile" {
    name = var.container_name
    storage_account_id = azurerm_storage_account.storage_statefile.id
    container_access_type = "private"
}