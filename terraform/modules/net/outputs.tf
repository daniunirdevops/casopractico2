# obtener el id de la subred creada en el módulo de red, para poder pasarla como variable al módulo de la VM
output "subnet_id" {
  value = azurerm_subnet.vsubnet.id 
}

# obtenemos el id de la targeta de red creada en el módulo de red, para poder pasarla como variable al módulo de la VM
output "nic_id" {
  value       = azurerm_network_interface.vm_nic.id
  description = "El ID de la tarjeta de red para la VM"
}

# obtenemos la ip pública de la vm que se ha generado en el módul network, para poder conectarnos a la vm por ssh, y la pasamos como output del módulo principal
output "public_ip_address" {
  value       = azurerm_public_ip.vm_pip.ip_address
  description = "La IP pública generada por la VM"
}
