# configurar el provider azure
terraform {
  required_version = ">= 1.8"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

}

provider "azurerm" {
  # features {}
   features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# función aleatoria para devolver un número hexadecimal de 4 bytes, que se usará para crear un nombre único para el ACR
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet
resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
}

# crear el grupo de recursos
resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}

# crear el ACR (Azure Container Registry)
resource "azurerm_container_registry" "acr" {
  # este valor debe ser único en Azure, por lo que se le añade un sufijo aleatorio generado por la función random_string
  # otra opción seria pasarlo como variable de entorno previamente generada, pero en este caso se genera automáticamente para que sea único
  # en este último caso se debería comprobar que el nombre generado no existe ya en Azure, para evitar errores de duplicidad, pero en este caso 
  # se asume que el sufijo aleatorio es suficiente para garantizar que sea único
  # name                     = "${var.acr_prefix}${random_string.acr_suffix.result}"
  name                     = "${var.acr_prefix}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
  # REVISAR si ha de ser autenticat no hauria de ser false?
  admin_enabled            = true
} 


# -----------------------------------------------------
# REVISAR per DOCUMENTACIÓ: al utilizar módulos, las variables que se definan en el módulo principal (main.tf) no son accesibles desde los módulos, 
# por lo que hay que crear variables en los módulos para que sean accesibles desde el módulo principal, y luego pasarle los valores de las variables al módulo en el main.tf del módulo principal
# -----------------------------------------------------


#  IMPORTANTE: al utilizar módulos, las variables que se definan en el módulo principal (main.tf) no son accesibles desde los módulos, 
# por lo que hay que crear variables en los módulos para que sean accesibles desde el módulo principal, y luego pasarle los valores de 
#las variables al módulo en el main.tf del módulo principal.
# -----------------------------------------------------

# crear la red virtual y la subred
module "network" {
  source                    = "./modules/net"
  network_name = var.network_name
  subnet_name = var.subnet_name
  pip_name = var.pip_name
  prefix_name = var.prefix_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}


# crear la VM 
module "virtual_machine" {
  source                = "./modules/vm"
  
  # REVISAR per posar en documetnació em servir les referències directes del Resource Group de l'arrel
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  
  # REVISAR Connectem el mòdul de red amb el mòdul de la VM usant l'output
  subnet_id             = module.network.subnet_id 
  # asignamos la id de la targeta de red creada en el módulo de red al módulo de la VM, para que la VM se conecte a la red y tenga acceso a Internet
  network_interface_id  = module.network.nic_id
  # nombre y medida de la vm que se puede pasar al módulo de la VM desde el main.tf del módulo principal, o se puede definir en el módulo de la VM como variable con valor por defecto
  vm_name               = var.vm_name
  vm_size               = var.vm_size
  vm_admin_username     = var.vm_admin_username
  ssh_public_key_path   = var.ssh_public_key_path
  tag                   = var.tag
}

# crear el AKS (Azure Kubernetes Service)
module "aks" {
  source                = "./modules/aks"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  aks_name              = var.aks_name
  # vm_size               = var.vm_size
  vm_size               = var.aks_node_pool_size
  tag                   = var.tag
  subnet_id             = module.network.subnet_id 
  scope                 = azurerm_container_registry.acr.id
}

