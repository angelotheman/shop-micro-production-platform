variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "keyvault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
  default     = ""
}

variable "object_id" {
  description = "Object ID for Key Vault access"
  type        = string
  default     = ""
}

variable "secret_names" {
  description = "List of secret names to create"
  type        = list(string)
  default     = ["db-password", "redis-password"]
}
