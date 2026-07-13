# se automatiza el puente entre terraform i ansible de aquí que se haya creado en un fichero de nombre ansible.tf, que genera un fichero de inventario de Ansible 
# y un fichero de variables de grupo para Ansible con las credenciales del ACR (Azure Container Registry) creado en el módulo principal de Terraform

# genera un recurso local_file que crea un fichero de inventario de Ansible con la IP pública de la VM creada en el módulo de Terraform, y las variables necesarias 
# para conectarse a la VM con Ansible

# [podman_vm]: Defineix un grup de màquines d'Ansible. Hi afegeix una màquina anomenada cp2demo-vm i li assigna dinàmicament la IP pública que Azure li ha donat (${azurerm_public_ip.vm_pip.ip_address}).
#[podman_vm:vars]: Defineix variables per a aquest grup. Li diu a Ansible quin usuari fer servir (var.vm_admin_username) i afegeix un paràmetre SSH (StrictHostKeyChecking=no) perquè no es quedi encallat demanant confirmació la primera vegada que es connecti.
resource "local_file" "ansible_inventory" {
  # filename = "${path.module}/../hosts.ini"
  filename = "${path.module}/../ansible/hosts.ini"
  content  = <<-EOT
    [podman_vm]
    cp2-vm ansible_host=${trimspace(module.network.public_ip_address)}

    [podman_vm:vars]
    ansible_user=${var.vm_admin_username}
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT
}

# --- Generación automática de las variables del ACR (group_vars) -------------
# NOTA didáctica: en el proyecto real, la contraseña iría cifrada con Ansible
# Vault y este fichero estaría en .gitignore. Para la demo lo dejamos en claro
# pero lo señalamos como deuda técnica.
resource "local_file" "ansible_acr_vars" {
  # filename = "${path.module}/../group_vars/all.yml"
  filename = "${path.module}/../ansible/group_vars/all.yml"
  
  content  = <<-EOT
    # Generado por Terraform — NO editar a mano. (En real: cifrar con Ansible Vault.)
    acr_login_server: "${azurerm_container_registry.acr.login_server}"
    acr_username: "${azurerm_container_registry.acr.admin_username}"
    acr_password: "${azurerm_container_registry.acr.admin_password}"

    image_tag: "${var.tag}"
  EOT
}