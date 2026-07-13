#!/bin/bash
    # para probar si funciona mysql y es persistente:
    # obtenemos el pod con :
    kubectl get pods -n wordpress

    POD_MYSQL=$(kubectl get pods -n wordpress -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^mysql' | head -n 1)

    echo "Accediendo al bash delpod: " $POD_MYSQL
    echo "Una vez dentro ejecutar:"
    echo "mysql -u root -p   "
    echo "nos pedirà la password que es la que hemos puesto en 'ansible/manifests/mysql/mysql-secret.yaml'"
    kubectl exec -it -n wordpress $POD_MYSQL -- bash


    exit 0

    # =========================================

    # comandos en mysql:
    # use wordpress;
    # select * from wp_users;

    # viendo detalles
    kubectl describe pod $POD_MYSQL -n wordpress

    # viendo logs
    kubectl logs $POD_MYSQL -n wordpress
    
    # borramos el pod y generará uno nuevo
    kubectl delete pod $POD_MYSQL -n wordpress

    kubectl get pods -n wordpress

        # 1. Obtén el nombre del NUEVO pod mysql (ya que el anterior cambió de nombre)
    NUEVO_POD_MYSQL=$(kubectl get pods -n wordpress -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^mysql' | head -n 1)

    # 2. Describe el pod para ver si el volumen se montó correctamente
    kubectl describe pod $NUEVO_POD_MYSQL -n wordpress | grep -A 5 -i "Volumes:"