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

# Depending on how this will be integrated with Ansible in the CI/CD, it might be best later to configure the VM name with Ansible.
resource "null_resource" "rename_windows_vm" {
  depends_on = [ proxmox_virtual_environment_vm.windows_vm ]

  provisioner "remote-exec" {
    # SSH connection settings to configure the VM hostname
    connection {
    type = "ssh"
    user = "Administrator"
    password = var.windows_template_default_password
    host = proxmox_virtual_environment_vm.windows_vm.ipv4_addresses[0][0]
    target_platform = "windows"
  }

    # Rename the Windows hostname
    inline = [
      "powershell -Command \"if ((Get-ComputerInfo).CsName -ne '${var.hostname}') {Rename-Computer -NewName '${var.hostname}' -Force -Restart}\""
    ]
  }  
}