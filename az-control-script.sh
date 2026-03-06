#!/bin/bash

set -a; source .env; set +a

ACTION=$1

set -e
if [ "$ACTION" == 'START_ALL' ]; then
    echo "Starting Jenkins Server"
    az vm start --resource-group $RG --name $VM_NAME
    echo "Starting AKS Cluster"
    az aks start --resource-group $RG --name $AKS_NAME
    echo "Starting PG Server"
    az postgres flexible-server start --resource-group $RG --name $PG_NAME
    echo "---- All resources started ----"
elif [ "$ACTION" == 'STOP_ALL' ]; then
    echo "Stopping Jenkins Server"
    az vm stop --resource-group $RG --name $VM_NAME
    echo "Stopping AKS Cluster"
    az aks stop --resource-group $RG --name $AKS_NAME
    echo "Stopping PG Server"
    az postgres flexible-server stop --resource-group $RG --name $PG_NAME
    echo "---- All resources stopped ----"
elif [ "$ACTION" == 'VM_START' ]; then
    echo "Starting Jenkins Server"
    az vm start --resource-group $RG --name $VM_NAME
elif [ "$ACTION" == 'VM_STOP' ]; then
    echo "Stopping Jenkins Server"
    az vm stop --resource-group $RG --name $VM_NAME
elif [ "$ACTION" == 'AKS_START' ]; then
    echo "Starting AKS Cluster"
    az aks start --resource-group $RG --name $AKS_NAME
elif [ "$ACTION" == 'AKS_STOP' ]; then
    echo "Stopping AKS Cluster"
    az aks stop --resource-group $RG --name $AKS_NAME
elif [ "$ACTION" == 'PG_START' ]; then
    echo "Starting PG Server"
    az postgres flexible-server start --resource-group $RG --name $PG_NAME
elif [ "$ACTION" == 'PG_STOP' ]; then
    echo "Stopping PG Server"
    az postgres flexible-server stop --resource-group $RG --name $PG_NAME
else
    echo "Invalid action: $ACTION"
    exit 1
fi