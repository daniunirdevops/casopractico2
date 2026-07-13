variable "prefix_name" {
  type    = string
  default = "cp2"
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "cp2-rg"
}

# variable "location" que obtendremos de la variable de entorno TF_VAR_location que obtenemos en el shell deploy.sh, 
# si no está definida, se usará el valor por defecto "spaincentral"
variable "location" {
  description = "Región donde se creará el grupo de recursos"
  type        = string
  # default     = "swedencentral"
  default     = "spaincentral"
}

variable "network_name" {
  description = "Nombre de la red virtual"
  type        = string
  default     = "cp2-vnet"
}

variable "subnet_name" {
  description = "Nombre de la subnet"
  type        = string
  default     = "cp2-subnet"  
} 

variable "pip_name" {
  description = "Nombre de la ip pública de la VM"
  type        = string
  default     = "cp2-pip"
} 

variable "acr_prefix" {
  description = "Nombre del ACR (Azure Container Registry) que se creará. Debe ser único a nivel global y solo puede contener minúsculas y números."
  type        = string
  default     = "cp2AcrregistryDaniFranques"
}

# variables vm_name, vm_size, vm_admin_username y ssh_public_key_path que se utilizarán en el módulo de la VM
variable "vm_name" {
  description = "Nombre de la VM"
  type        = string
  default     = "cp2-vm-dani"
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
  description = "Ruta a la clave pública SSH para acceder a la VM de azure."
  type        = string
  default     = "~/.ssh/id_rsa_azure.pub"
}

variable "tag" {
  type        = string
  description = "Tag para la VM"
  default     = "casopractico2"
}

variable "aks_name" {
  default = "cp2-aks"
}

variable "aks_node_pool_size" {
  description = "Tamaño del node pool del AKS."
  type        = string

  # en vez de utilizar unamáquina gratuita, utilizamos una máquina de 2 vCPU y 8 GiB RAM para poder desplegar el contenedor de la aplicación web en el AKS
  default     = "Standard_D2s_v3"
}