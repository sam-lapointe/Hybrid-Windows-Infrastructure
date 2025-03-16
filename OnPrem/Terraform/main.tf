terraform {
  backend "azurerm" {
      resource_group_name = "WindowsHybrid"
      storage_account_name = "winhybrid78cd8e59" # Replace this with your storage account name.
      container_name = "tfstate"
      key = "onprem.terraform.tfstate"
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

provider "proxmox" {
  endpoint = "https://192.168.0.11:8006/"
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
}

# Currently, every modules need to be added here manually.
locals {
  windows_vm_modules = [
    module.win-dc1-f1,
    module.win-dc1-f2,
    module.win-wac,
    module.win-entra-sync1
  ]
  ubuntu_vm_modules = []
  # Combine both lists into a single list of modules
  all_vm_modules = concat(local.windows_vm_modules, local.ubuntu_vm_modules)
}

module "win-dc1-f1" {
  source = "./Modules/windows-vm"

  # Input Variables
  hostname = "dc1-f1"
  description = "Windows Domain Controller 1 of Forest 1 - Managed by Terraform"
  additional_vm_tags = ["dc", "primary", "core"]
  windows_template_id = 101
  windows_template_default_password = var.windows_template_default_password
  proxmox_node = "node-01"
  cpu = 1
  memory = 2048
  disks = [ {
    datastore_id = "DataStorage-01"
    interface = "scsi1"
    file_format = "raw"
    size = 8
  } ]
}

module "win-dc1-f2" {
  source = "./Modules/windows-vm"

  # Input Variables
  hostname = "dc1-f2"
  description = "Windows Domain Controller 1 of Forest 2 - Managed by Terraform"
  additional_vm_tags = ["dc", "primary", "core"]
  windows_template_id = 101
  windows_template_default_password = var.windows_template_default_password
  proxmox_node = "node-01"
  cpu = 1
  memory = 2048
  disks = [ {
    datastore_id = "DataStorage-01"
    interface = "scsi1"
    file_format = "raw"
    size = 8
  }]
}

module "win-wac" {
  source = "./Modules/windows-vm"

  # Input Variables
  hostname = "wac"
  description = "Windows Admin Center - Managed by Terraform"
  additional_vm_tags = ["wac", "core"]
  windows_template_id = 101
  windows_template_default_password = var.windows_template_default_password
  proxmox_node = "node-01"
  cpu = 2
  memory = 4096
}

module "win-entra-sync1" {
    source = "./Modules/windows-vm"

    # Input Variables
    hostname = "entra-sync1"
    description = "Windows with Entra Connect for Synchronization- Managed by Terraform"
    additional_vm_tags = ["sync", "desktop"]
    windows_template_id = 100
    windows_template_default_password = var.windows_template_default_password
    proxmox_node = "node-01"
    cpu = 2
    memory = 4096
}

output "all_vm_info" {
  value = [
    for vm_module in local.all_vm_modules : vm_module.vm_info
  ]
}