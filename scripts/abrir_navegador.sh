#!/bin/bash

    IP_WORDPRESS=$1
    IP_PODMAN=$2

    URL_WORDPRESS="http://$IP_WORDPRESS"
    URL_PODMAN="https://$IP_PODMAN"

    # --- detector de navegador según el SO ---
    NAVEGADOR="xdg-open" # Por defecto en Linux (Ubuntu, Debian, etc.)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        NAVEGADOR="open" # Para macOS
    fi

    # --- PREGUNTA INTERACTIVA ---
    echo -n "¿Quieres abrir los sitios web desplegados en tu navegador? (s/n): "
    read -r RESPUESTA

    if [[ "$RESPUESTA" =~ ^[Ss]$ || "$RESPUESTA" == "" ]]; then
        
        echo "Abriendo aplicación de Podman en: $URL_PODMAN"
        $NAVEGADOR "$URL_PODMAN" > /dev/null 2>&1 &

        sleep 1 # Pausa para dar tiempo al navegador

        echo "Abriendo WordPress en: $URL_WORDPRESS"
        $NAVEGADOR "$URL_WORDPRESS" > /dev/null 2>&1 &
        
    else

        echo "Puede acceder :"
        echo "   - Podman   : $URL_PODMAN"
        echo "   - WordPress: $URL_WORDPRESS"
    fi