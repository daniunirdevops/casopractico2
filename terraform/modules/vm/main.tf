# Creem la Màquina Virtual
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username

  # REVISAR associem la VM a la targeta de xarxa creada anteriorment
  network_interface_ids = [
    var.network_interface_id,
  ]

  # Configura una contrasenya senzilla per a la prova (o clau SSH)
  # admin_password                  = "ContrasenyaSegura123!" 
  # disable_password_authentication = false
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }  

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = {
    environment = var.tag
  }  

  # Añadimos este script para que se ejecute al arrancar
  # instalamos Ansible y Podman en la VM para poder ejecutar playbooks y contenedores directamente

  # REVISAR comentari!!!!
  
  # una vez instalado el software, podemos ejecutar un playbook de Ansible para desplegar el contenedor de Podman, 
  #por ejemplo, un contenedor de Nginx
  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Actualizar paquetes e instalar Ansible y Podman
              apt-get update -y
              apt-get install -y software-properties-common
              apt-add-repository --yes --update ppa:ansible/ansible
              apt-get install -y ansible podman git
              EOF
  )
}