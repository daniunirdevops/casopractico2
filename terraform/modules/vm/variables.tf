variable "location" {
  type        = string
  description = "Ubicació de la VM"
}

variable "resource_group_name" {
  type        = string
  description = "Nom del Resource Group"
}

variable "tag" {
  type        = string
  description = "Tag para la VM"
}

variable "subnet_id" {
  type        = string
  description = "ID de la subnet on es connectarà la VM"
}

variable "vm_name" {
  type        = string
  default     = "cp2-vm-dani"
}

variable "network_interface_id" {
  type        = string
  description = "ID de la tarjeta de red que viene del módulo net"
}

# tamaño de la vm, Burstable, 2 vCPU, 1 GiB RAM, AMD64 (free tier, imágenes amd64)
variable "vm_size" {
  description = "Tamaño de la VM."
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Ruta a la clave pública SSH para acceder a la VM de azure. Por defecto, se usará la clave pública generada por defecto en el sistema (~/.ssh/id_rsa.pub)."
  type        = string
  default     = "~/.ssh/id_rsa_azure.pub"
}