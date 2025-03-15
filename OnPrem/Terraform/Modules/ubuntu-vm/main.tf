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
  required_tags = ["terraform", "ubuntu"]
  final_tags = concat(local.required_tags, var.additional_vm_tags)
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name = var.hostname
  node_name = var.proxmox_node
  description = var.description
  tags = local.final_tags

  clone {
    vm_id = var.ubuntu_template_id
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

  vga {
    memory = 16
    type = "serial0"
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}