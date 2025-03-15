output "vm_info" {
    value = {
        hostname = var.hostname
        vm_tags = local.final_tags
        ipv4_address = proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses[1][0]
        mac_address = proxmox_virtual_environment_vm.ubuntu_vm.mac_addresses[1]
    }
}