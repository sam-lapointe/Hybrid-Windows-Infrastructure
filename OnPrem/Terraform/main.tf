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
    module.win-dc-01,
    module.win-dc-02,
    module.win-fs-01,
    module.win-ts-01
  ]
  ubuntu_vm_modules = [
    module.ubnt-runner-01
  ]
  # Combine both lists into a single list of modules
  all_vm_modules = concat(local.windows_vm_modules, local.ubuntu_vm_modules)
}

module "win-dc-01" {
  source = "./Modules/windows-vm"

  # Input Variables
  hostname = "dc-01"
  description = "Windows Domain Controller 01 - Managed by Terraform"
  additional_vm_tags = ["dc", "primary"]
  windows_template_id = 100
  windows_template_default_password = var.windows_template_default_password
  proxmox_node = "node-01"
  cpu = 2
  memory = 4096
}

module "win-dc-02" {
  source = "./Modules/windows-vm"

  # Input Variables
  hostname = "dc-02"
  description = "Windows Domain Controller 02 - Managed by Terraform"
  additional_vm_tags = ["dc"]
  windows_template_id = 100
  windows_template_default_password = var.windows_template_default_password
  proxmox_node = "node-01"
  cpu = 2
  memory = 4096
}

module "win-fs-01" {
  source = "./Modules/windows-vm"

  # Input Variables
  hostname = "fs-01"
  description = "Windows File Server 01 - Managed by Terraform"
  additional_vm_tags = ["fs"]
  windows_template_id = 100
  windows_template_default_password = var.windows_template_default_password
  proxmox_node = "node-01"
  cpu = 2
  memory = 4096
  disks = [ {
    datastore_id = "DataStorage-01"
    interface = "scsi1"
    file_format = "raw"
    size = 64
  } ]
}

module "win-ts-01" {
  source = "./Modules/windows-vm"

  # Input Variables
  hostname = "ts-01"
  description = "Windows Terminal Server 01 - Managed by Terraform"
  additional_vm_tags = ["ts"]
  windows_template_id = 100
  windows_template_default_password = var.windows_template_default_password
  proxmox_node = "node-01"
  cpu = 2
  memory = 4096
}

module "ubnt-runner-01" {
  source = "./Modules/ubuntu-vm"

  # Input Variables
  hostname = "runner-01"
  description = "Ubuntu 22.04 Server hosting GitHub Actions Self-Hosted Runners - Managed by Terraform"
  additional_vm_tags = ["github-runner"]
  ubuntu_template_id = 104
  ubuntu_template_default_username = var.ubuntu_template_default_username
  ubuntu_template_default_password = var.ubuntu_template_default_password
  proxmox_node = "node-01"
  cpu = 2
  memory = 4096

  # Only 1 template can be cloned at a time because Proxmox is applying a lock on the storage account that prevents the cloning of a different template.
  depends_on = [ local.windows_vm_modules ]
}

output "all_vm_info" {
  value = [
    for vm_module in local.all_vm_modules : vm_module.vm_info
  ]
}