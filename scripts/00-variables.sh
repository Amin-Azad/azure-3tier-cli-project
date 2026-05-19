#!/bin/bash 


#project identity 
export PROJECT="3tier"
export ENVIRONMENT="dev"
export OWNER="amin"
export LOCATION="westeurope"

#Naming 
export RG_NAME="rg-${PROJECT}-${ENVIRONMENT}"
export VNET_NAME="vnet-${PROJECT}-${ENVIRONMENT}"

#NSG
export NSG_WEB="nsg-web-${ENVIRONMENT}"
export NSG_APP="nsg-app-${ENVIRONMENT}"
export NSG_DATA="nsg-data-${ENVIRONMENT}"
export NSG_MGMT="nsg-mgmt-${ENVIRONMENT}"

#VM
export VM_SIZE="Standard_D2lds_v6"
export VM_WEB="vm-web-${ENVIRONMENT}"
export VM_APP="vm-app-${ENVIRONMENT}"

#load balancer and public ip
export LB_NAME="lb-web-${ENVIRONMENT}"
export PIP_NAME="pip-lb-${ENVIRONMENT}"

export STORAGE_NAME="st3tier${ENVIRONMENT}01"
export SP_NAME="sp-${PROJECT}-deploy"

# Network ranges
export VNET_CIDR="10.0.0.0/16"
export SNET_WEB_CIDR="10.0.1.0/24"
export SNET_APP_CIDR="10.0.2.0/24"
export SNET_DATA_CIDR="10.0.3.0/24"
export SNET_MGMT_CIDR="10.0.4.0/24"

# Admin user for VMs
export ADMIN_USER="azureuser"

#public IP for SSH access
export MY_IP="$(curl -s ifconfig.me)/32"

# Tags
export TAGS="environment=${ENVIRONMENT} project=${PROJECT} owner=${OWNER}"

echo "Variables loaded for project: ${PROJECT}, environment: ${ENVIRONMENT}, location: ${LOCATION}"

