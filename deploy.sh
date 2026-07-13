#!/bin/bash

# se debe rellenar el parámetro del fichero con la clave pública:
# o crear
# ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_azure
# rm ~/.ssh/nom_de_la_clau
# rm ~/.ssh/nom_de_la_clau.pub

echo "Comprovando el estado del login a Azure..."

# Intentamos obtener el nombre de la subscripción activa en Azure, si no hay ninguna sesión activa, la orden fallará y 
# se pedirá al usuario que se loguee.
if SUBSCRIPCION=$(az account show --query "name" -o tsv 2>/dev/null); then
    # Si la orden ha funcionado correctamente:
    echo "Ya esta logueado en Azure."
    echo "Subscripcion activa actual: $SUBSCRIPCION"
else
    # la orden ha fallado, se pide el login:
    echo "No se ha detectado ninguna sessión activa. Iniciando az login..."

    az login -o table
    
    if SUBSCRIPCION=$(az account show --query "name" -o tsv 2>/dev/null); then

        echo "Subscripción activa actual: " $SUBSCRIPCION
    else

        exit 1
    fi
fi

echo "--------------------------------------------------"

# Pregunta de confirmación (Input del usuario)
read -p "Quiere continuar con la execucion de Terraform en esta subscripcion? (s/N): " RESPUESTA

# Convertimos la respuesta a minúsculas para aceptar tanto 'S' como 's'
RESPUESTA=$(echo "$RESPUESTA" | tr '[:upper:]' '[:lower:]')

if [[ "$RESPUESTA" != "s" && "$RESPUESTA" != "si" ]]; then
    echo "Operación cancelada por el usuario."
    exit 0
fi

# ========================== Inicio =============================

set -e # Si cualquier orden falla para el script


# convirte el texto a minúsculas de forma automática (Ej: STart -> start)
ACCION_INICIAL=$1
ACCION=${ACCION_INICIAL,,}


# Cambiar al directorio terraform
cd terraform || exit 1 # Se detiene si no se puede cambiar al directorio terraform

# Evaluar la acción solicitada
if [ -z "$ACCION" ] || [ "$ACCION" == "start" ]; then

    # ======= DEFINICIÓN DE VARIABLES =======
    # ======================================
    export TF_VAR_tag="casopractico2"

    # Región como variable para Terraform
    # comentar para utilizar la región por defecto en variables.tf

    # export TF_VAR_location="swedencentral"
    export TF_VAR_location="spaincentral"

    # variable de entorno para el archivo ssh de la clave pública, si se desea pasar como variable a Terraform, por ejemplo:
    export TF_VAR_ssh_public_key_path="$HOME/.ssh/id_rsa_azure.pub"

    # Verificamos que el archivo existe
    if [ ! -f "$TF_VAR_ssh_public_key_path" ]; then
        echo "Error: No se encontró la clave pública en: $TF_VAR_ssh_public_key_path"
        echo "Debe verificar la ruta o generar la clave antes de continuar."
        exit 1 # indicamos el error
    fi

    # ======= INICIO DE DESPLIEGUE =======
    # ======================================
    echo "Iniciando despliegue de infraestructura..."
    terraform init || exit 1 # Se detiene si el init falla

    terraform plan -out=tfplan  && terraform apply tfplan && rm -f tfplan
    echo "Volviendo al directorio original."
    cd ..
    ACR=$(cd terraform && terraform output -raw acr_login_server)
    
    # ======= GENERACIÓN DE IMAGENES =======
    # ======================================
    # le indicamos que la plataforma destino es AMD64/Intel de 64 bits, para que la imagen de contenedor sea compatible con la arquitectura de la máquina virtual creada en Azure, que es AMD64/Intel 64 bits.
    # IMAGEN_PODMAN="$ACR/web-nginx:$TF_VAR_tag"
    IMAGEN_PODMAN="$ACR/web:$TF_VAR_tag"

    echo "Construyendo imagen de contenedor en local con Podman para la plataforma AMD64/Intel 64 bits..."
    # con el flag --network=host se utiliza la red del host para la construcción de la imagen
    podman build --platform=linux/amd64 -t "$IMAGEN_PODMAN" web # --network=host

    echo "Obteniendo imagen WordPress"
    podman pull docker.io/library/wordpress:latest

    # etiqueto la imagen
    echo "Etiquetando la imagen"
    podman tag docker.io/library/wordpress:latest $ACR/wordpress:$TF_VAR_tag

    # ======= DESPLIEGUE DE IMAGENES =======
    # ======================================
    # Iniciar sesión en el Azure Container Registry (ACR) con Podman, con mi usuario y contraseña de ACR obtenidos de Terraform, para poder subir imágenes al registro 
    # privado de contenedores asi después se puede hacer un push de la imagen de contenedor a ACR.
    echo "Iniciando sesión en Azure Container Registry con Podman..." 
    podman login "$ACR" \
    -u "$(cd terraform && terraform output -raw acr_admin_username)" \
    -p "$(cd terraform && terraform output -raw acr_admin_password)"

    
    echo "Subiendo imagen de contenedor Podman creada a Azure Container Registry ..."
    podman push  $IMAGEN_PODMAN

    echo "Comprobando que la imagen de contenedor se ha subido correctamente a ACR..."
    # Comprobar que la imagen de contenedor se ha subido correctamente a ACR
    #podman search $IMAGEN_PODMAN

    # opcional, para limpiar la imagen local después de subirla a ACR
    # podman rmi $IMAGEN_PODMAN  
    echo "Subida de imagen completada con éxito."  


    echo "Subiendo la imagen WordPress"
    podman push $ACR/wordpress:$TF_VAR_tag    


    # ======= DESPLIEGUE DE ENTORNOS =======
    # ======================================
    echo "Iniciando aprovisionamiento de software con Ansible..."

    # Ejecutamos el playbook apuntando al inventario local
    ansible-playbook -i ansible/hosts.ini ansible/playbook_podman.yml

    # Comprobación de acceso a la aplicación web desplegada en la máquina virtual creada en Azure, utilizando la IP pública obtenida de Terraform.
    IP_PODMAN=$(cd terraform && terraform output -raw vm_public_ip)

    # Obtener credenciales del cluster AKS para kubectl
    # nos servira para obtener las credenciales del cluster AKS y poder interactuar con él usando kubectl, para comprobar que el despliegue de la aplicación web en el cluster AKS se ha realizado correctamente.
    # con el flag --overwrite-existing se asegura que se sobrescriben las credenciales existentes

    # crea un fichero de configuración de kubectl en el directorio ~/.kube/config, que permite a kubectl interactuar con el cluster AKS creado por Terraform.
    # algo similar a ssh, pero aplicado a kubernetes, para poder ejecutar comandos de kubectl en el cluster AKS creado por Terraform.
    echo "Obteniendo credenciales del cluster AKS para kubectl..."
    az aks get-credentials --resource-group $(cd terraform && terraform output -raw resource_group) --name $(cd terraform && terraform output -raw aks_name) --overwrite-existing       

    # tenemos la información de conexión al cluster AKS en el fichero ~/.kube/config, que es utilizado por kubectl para interactuar con el cluster AKS creado por Terraform.

    # ahora kubernetes ya conoce las credenciales del cluster AKS y se puede interactuar con él usando kubectl
    echo "Comprobando que kubectl puede acceder al cluster AKS..."
    # kubectl cluster-info
    kubectl get nodes --request-timeout='5s' &> /dev/null
    # $? guarda el resultado del último comando ejecutado (0 = éxito, cualquier otro número = error)
    if [ $? -eq 0 ]; then
        echo "Conexión exitosa con el clúster."
    else
        echo "Error: No se pudo conectar al clúster de Kubernetes."
        exit 1
    fi
    

    # Despliegue de Kubernetes
    echo "Ejecutando playbook para Kubernetes"

    cd ansible && pwd

    # Ejecutamos el playbook que realiza el despliegue de kubernetes con WordPress, MySQL y el volumen persistente
    ansible-playbook playbook_k8s.yml

    # Volver al directorio original
    echo "Volviendo al directorio original"
    cd .. && pwd

    echo "Mostrando IP"
    kubectl get svc -n wordpress 
    # ======================================

    echo "Esperando la dirección IP del Balanceador de Carga de Azure..."

    # se espera hasta 3 minutos (180 segundos) a que la propiedad de ingress contenga la IP
    # font: https://kubernetes.io/docs/reference/kubectl/generated/kubectl_wait/
    kubectl wait --namespace wordpress --for=jsonpath='{.status.loadBalancer.ingress[0].ip}' svc/wordpress --timeout=180s
    
    IP_WORDPRESS=$(kubectl get svc wordpress -n wordpress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

    echo "--------------------------------------------------------"
    echo "             DESPLIEGUE FINALIZADO CON ÈXITO          "
    echo "--------------------------------------------------------"

    # abrir el navegador con las direcciones de la VM y de WordPress
    scripts/abrir_navegador.sh "$IP_WORDPRESS" "$IP_PODMAN"

elif [ "$ACCION" == "stop" ] || [ "$ACCION" == "destroy" ]; then

    # Destruir la infraestructura creada por Terraform
    echo "Destruyendo infraestructura..."
    # con el flag -auto-approve se evita la confirmación manual de destrucción
    terraform destroy -auto-approve
    # Volver al directorio original
    cd ..
else
    # Informar que el parámetro no es válido
    echo "Error: Parámetro no válido. Usa 'start' o 'stop'."
    exit 1
fi

echo "Script finalizado."
