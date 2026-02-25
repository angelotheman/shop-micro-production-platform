variable "subscription_id" { type = string }
variable "project_name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }

# ACR
variable "acr_name" { type = string } # must be globally unique, lowercase, 5-50 chars

# AKS
variable "aks_name" { type = string }
variable "dns_prefix" { type = string }
variable "node_count" { type = number }
variable "node_size" { type = string }
variable "node_pool" { type = string }
variable "environment_name" { type = string }