resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_name
  sku_tier            = "Free"

  default_node_pool {
    name           = "system"
    vm_size         = var.vm_size
    node_count      = 1
    vnet_subnet_id  = var.subnet_id
    
    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"

    # así no provoca conflictos con la red virtual y la subred que se crean en el módulo de red, ya que se utiliza un rango de IPs diferente para el AKS
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"    
  }
}

# Asignación de rol para permitir que el AKS acceda al ACR
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = var.scope
}