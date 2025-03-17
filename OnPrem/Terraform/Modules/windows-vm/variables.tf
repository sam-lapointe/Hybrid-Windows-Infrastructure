variable "windows_template_id" {
    description = "The ID of the Windows Server 2025 template."
    type = number
}

variable "proxmox_node" {
    description = "The name of the proxmox node where to deploy the VM."
    type = string
}

variable "hostname" {
    description = "The Windows Hostname."
    type = string
}

variable "description" {
  description = "The VM description."
  type = string
}

variable "additional_vm_tags" {
  description = "Additional tags for the VM. Allowed values: 'dc', 'primary', 'fs', 'wac', 'sync', 'core', 'desktop'."
  type = list(string)
  default = []

  validation {
    condition = alltrue([
        for tag in var.additional_vm_tags : contains(["dc", "primary", "fs", "wac", "sync", "core", "desktop"], tag)
    ])
    error_message = "Only 'dc', 'primary', 'fs', 'wac', 'sync', 'core' and 'desktop' are allowed as additional tags."
  }
}

variable "cpu" {
    description = "The number of CPU for the VM."
    type = number
}

variable "memory" {
    description = "The number of memory in Megabyte for the VM."
    type = number
}

variable "disks" {
    description = "The disks to add to the VM."
    type = list(object({
        datastore_id = string
        interface = string
        file_format = string
        size = number
    }))
    default = []
}