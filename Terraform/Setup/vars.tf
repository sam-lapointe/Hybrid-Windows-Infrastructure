# This variable must be changed if the resource group name was changed in the init.sh.
variable "resource_group_name" {
  description = "The name of the resource group."
  default = "WindowsHybrid"
}

variable "storage_account_name" {
    description = "The name of the storage account must length between 3 and 16 characters and contain numbers and lowercase letters only. 8 random characters will be appended to make it unique."
    default = "winhybrid"

    validation {
      condition = length(var.storage_account_name) <= 16
      error_message = "The storage account name must be at most 16 characters long."
    }
}

variable "container_name" {
  description = "The name of the Blob Storage container."
  default = "tfstate"
}