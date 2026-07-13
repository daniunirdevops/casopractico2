# obtener la IP pública de la VM para poder conectarnos a ella por SSH
# también la podemos obtener desde el módulo de red, pero la obtenemos desde el módulo principal para poder usarla en el script de despliegue deploy.sh
# Para comprobar:
# terraform output vm_public_ip
# o
# ssh -i fichero_clave_ssh usuario@<IP_PUBLICA>
output "vm_public_ip" {
  value       = module.network.public_ip_address
  description = "IP pública de la máquina virtual"
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "aks_name" {
  value = module.aks.aks_name
}