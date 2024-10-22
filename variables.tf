variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group"
}

variable "location" {
  type        = string
  description = "Azure Region"
}

variable "prefix" {
  type        = string
  description = "Prefix for resources"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "vm_count" {
  type        = number
  description = "Number of VMs to create"
}

variable "vm_admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "public_key_path" {
  type        = string
  description = "Path to the SSH public key"
}

variable "allowed_ssh_ip_address" {
  type        = list(string)
  description = "List of allowed IP addresses for SSH"
}
