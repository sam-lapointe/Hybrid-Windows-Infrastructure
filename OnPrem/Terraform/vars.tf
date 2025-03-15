variable "proxmox_username" {
  description = "Proxmox Username."
  type = string
}

variable "proxmox_password" {
    description = "Proxmox User's Password"
    type = string
    sensitive = true
}

variable "windows_template_default_password" {
    description = "The default password of the user Administrator."
    type = string
    sensitive = true
}

variable "ubuntu_template_default_username" {
    description = "The default's user username."
    type = string
}

variable "ubuntu_template_default_password" {
    description = "The default's user password."
    type = string
    sensitive = true
}