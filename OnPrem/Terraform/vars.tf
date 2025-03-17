variable "proxmox_username" {
  description = "Proxmox Username."
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox User's Password"
  type        = string
  sensitive   = true
}