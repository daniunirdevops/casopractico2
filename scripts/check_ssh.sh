# test de conexión SSH a la máquina virtual creada, si se ha configurado la clave pública en Terraform y se ha generado la clave privada correspondiente en el host local.
echo "Probando conexión SSH a la máquina virtual..."
FICHERO_SSH=~/.ssh/id_rsa_azure
ssh -i $FICHERO_SSH  azureuser@$(terraform output -raw public_ip_address) 

"echo 'Conexión SSH exitosa a la máquina virtual.'"   

terraform output -raw acr_login_server
terraform output -raw acr_admin_username
terraform output -raw acr_admin_password

