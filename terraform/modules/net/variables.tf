variable "prefix_name" {
  type    = string
  default = "casopractico2"
}

variable "location" {
  description = "Región donde se creará el grupo de recursos"
  type        = string
  default     = "spaincentral" #"swedencentral"
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "rg-casopractico2"
}

variable "network_name" {
  description = "Nombre de la red virtual"
  type        = string
  default     = "vnet-casopractico2"
}

variable "subnet_name" {
  description = "Nombre de la subnet"
  type        = string
  default     = "subnet-casopractico2"  
}

variable "pip_name" {
  description = "Nombre de la ip pública de la VM"
  type        = string
  default     = "pip-casopractico2"
}