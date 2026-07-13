variable "location" {
  type        = string
  description = "Ubicació de la VM"
}

variable "resource_group_name" {
  type        = string
  description = "Nom del Resource Group"
}

variable "subnet_id" {
  type        = string
  description = "ID de la subnet on es connectarà la VM"
}

variable "tag" {
  type        = string
  description = "Tag para la VM"
}

variable "aks_name" {
  default = "cp2-aks"
}

variable "vm_size" {
  description = "Tamaño de la VM."
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "scope" {
  description = "Scope for the role assignment"
  type        = string
  default     = ""
}