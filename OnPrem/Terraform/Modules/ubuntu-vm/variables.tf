variable "ubuntu_template_id" {
    description = "The ID of the Ubuntu 22.04 server template."
    type = number
}

variable "proxmox_node" {
    description = "The name of the proxmox node where to deploy the VM."
    type = string
}

variable "hostname" {
    description = "The Ubuntu Hostname."
    type = string
}

variable "description" {
  description = "The VM description."
  type = string
}

variable "ubuntu_template_default_username" {
    description = "The default's user username."
    type = string
}

variable "ubuntu_template_default_ssh_privatekey" {
    description = "The default's user password."
    type = string
    sensitive = true
}

variable "github_actions_token" {
  description = "The token to link the runner to the repository."
  type = string
  sensitive = true
}

variable "additional_vm_tags" {
  description = "Additional tags for the VM. Allowed values: 'github-runner'."
  type = list(string)
  default = []

  validation {
    condition = alltrue([
        for tag in var.additional_vm_tags : contains(["github-runner"], tag)
    ])
    error_message = "Only 'github-runner' is allowed as additional tags."
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