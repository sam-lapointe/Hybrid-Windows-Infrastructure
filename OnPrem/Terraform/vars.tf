variable "PROXMOX_USERNAME" {
  description = "Proxmox Username."
  type        = string
}

variable "PROXMOX_PASSWORD" {
  description = "Proxmox User's Password"
  type        = string
  sensitive   = true
}