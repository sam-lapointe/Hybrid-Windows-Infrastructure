terraform {
    #################################################
    # Before initialising the environment by running init.sh, comment the backend section.
    # Once the initilisation is completed uncomment this code, replace the storage_account_name with yours and rerun Terraform Init
    # to switch from local backend to remote Azure backend
    #################################################
    backend "azurerm" {
      resource_group_name = "WindowsHybrid"
      storage_account_name = "winhybride8be15f7" # Replace this with your storage account name.
      container_name = "tfstate"
      key = "backend.terraform.tfstate"
      use_azuread_auth = true
    }

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "4.17.0"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.73.1"
    }
  }
}

provider "azurerm" {
    features {}
    resource_provider_registrations = "none"
}

# # Generate a random ID (4 bytes)
# resource "random_id" "random_suffix" {
#   byte_length = 4
# }

data "azurerm_subscription" "current" {
}

locals {
  subscription_id = split("/", data.azurerm_subscription.current.id)[2]
}

# The resource group created with the init.sh script.
data "azurerm_resource_group" "windows_hybrid" {
    name = var.resource_group_name
}

# Deploy the storage account to the existing resource group.
resource "azurerm_storage_account" "storage_statefile" {
    name = "${var.storage_account_name}${substr(local.subscription_id, 0, 8)}"
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

# Create the storage container.
resource "azurerm_storage_container" "storage_statefile" {
    name = var.container_name
    storage_account_id = azurerm_storage_account.storage_statefile.id
    container_access_type = "private"
}

provider "proxmox" {
  endpoint = "https://192.168.0.11:8006/"
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
}

module "ubnt-runner1" {
  source = "../../OnPrem/Terraform/Modules/ubuntu-vm"

  # Input Variables
  hostname = "runner-1"
  description = "Ubuntu Server 22.04 hosting GitHub Actions Self-Hosted Runner - Managed by Terraform"
  additional_vm_tags = ["github-runner"]
  ubuntu_template_id = 102
  ubuntu_template_default_username = var.ubuntu_username
  ubuntu_template_default_ssh_privatekey = var.ubuntu_ssh_privatekey
  github_actions_token = var.github_actions_token
  proxmox_node = "node-01"
  cpu = 2
  memory = 4096
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_statefile.name
}

output "runner_info" {
  value = module.ubnt-runner1.vm_info
}