#!/bin/bash

    POD="mysql-0"
    POD="wordpress-64df79454d-kf9p5"
    POD=$(kubectl get pods -n wordpress -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^wordpress' | head -n 1)
    
    echo $POD
    exit 0

    # ============== ACCIONES ==============

    # Para borrar un
    # borramos el pod y generará uno nuevo
    kubectl delete pod $POD -n wordpress

    # obtenemos los pods que estan en el namespace wordpress y su estado
    kubectl get pods -n wordpress

    # en modo vigilante para ejecutar en otro terminal y ver por los distintos pasos 
    kubectl get pods -n wordpress -w

    # comunicación de los pods 
    kubectl get svc -n wordpress

    # información sobre discos
    kubectl get pvc -n wordpress

    # eventos en el workspace
    kubectl get events -n wordpress --sort-by=.metadata.creationTimestamp

    # viendo detalles
    kubectl describe pod $POD -n wordpress

    # viendo logs
    kubectl logs $POD -n wordpress
    