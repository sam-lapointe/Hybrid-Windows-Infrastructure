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

variable "domain" {
    description = "The domain the VM needs to join (e.g., example.com). Either WORKGORUP or a valid domain name."
    type = string
    default = "WORKGROUP"

    validation {
      condition = (
        var.domain == "WORKGROUP" ||
        (can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{1,62}[A-Za-z0-9]\\.)+[A-Za-z]{2,}$", var.domain)) && length(var.domain) <= 64)
      )
      error_message = "The domain must be either 'WORKGROUP' or a valid domain name (e.g., example.com) with a maximum total length of 64 characters."
    }
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