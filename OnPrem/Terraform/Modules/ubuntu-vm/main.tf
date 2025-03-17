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

resource "null_resource" "setup_runner" {
  depends_on = [ proxmox_virtual_environment_vm.ubuntu_vm ]

  connection {
    type = "ssh"
    user = var.ubuntu_template_default_username
    private_key = var.ubuntu_template_default_ssh_privatekey
    host = proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses[1][0]
    target_platform = "unix"
  }

  provisioner "remote-exec" {
    inline = [ 
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz",
      "echo 'b13b784808359f31bc79b08a191f5f83757852957dd8fe3dbfcc38202ccf5768  actions-runner-linux-x64-2.322.0.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz",
      "./config.sh --unattended --url https://github.com/sam-lapointe/Hybrid-Windows-Infrastructure --token ${var.github_actions_token}",
      "sudo ./svc.sh install",
      "sudo ./svc.sh start"
     ]
  }       
}