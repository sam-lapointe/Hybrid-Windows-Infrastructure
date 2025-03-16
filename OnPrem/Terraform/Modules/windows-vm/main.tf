terraform {
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

locals {
  required_tags = ["terraform", "windows"]
  final_tags = concat(local.required_tags, var.additional_vm_tags)
}

resource "proxmox_virtual_environment_vm" "windows_vm" {
  name = var.hostname
  node_name = var.proxmox_node
  description = var.description
  tags = local.final_tags

  clone {
    vm_id = var.windows_template_id
    full = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var. cpu
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
    floating = var.memory
  }

  network_device {
    bridge = "vmbr0"
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id = disk.value.datastore_id
      interface = disk.value.interface
      file_format = disk.value.file_format
      size = disk.value.size
    }
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}