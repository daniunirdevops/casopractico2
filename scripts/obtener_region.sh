#!/bin/bash

    # Si no se pasa, se obtiene automáticamente desde Azure CLI, si no se puede obtener ninguna región permitida, se detiene 
    # el script con un mensaje de error.


    # Si utiliza un segundo parámetro, se puede pasar la región de Azure como argumento, pero entonces no se obtiene automáticamente de la CLI de Azure. 
    # Si no se pasa, se obtiene automáticamente.
    # REGION_AZURE=$2
    #if [ -z "$REGION_AZURE" ] || [ "$REGION_AZURE" == "auto" ]; then

    # Obtener automáticamente la región permitida de Azure ya que daba error al seleccionar alguna de las existentes.
    echo "Buscando región permitida en Azure..."
    REGION_AZURE=$(az policy assignment list --query "[?parameters.listOfAllowedLocations.value!=null].parameters.listOfAllowedLocations.value[0]" -o tsv)

    if [ -z "$REGION_AZURE" ]; then
        echo "Error: No se pudo obtener ninguna Bregión permitida de Azure CLI."
        exit 1 # indicamos el error
    fi
        echo "Primera región detectada : $REGION_AZURE"
