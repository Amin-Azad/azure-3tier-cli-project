#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00-variables.sh"

echo "Creating Public IP for Load Balancer"

az network public-ip create \
  --resource-group "$RG_NAME" \
  --name "$PIP_NAME" \
  --sku Standard \
  --allocation-method Static \
  --location "$LOCATION" \
  --tags "$TAGS" \
  --output none

echo "Creating Load Balancer"

az network lb create \
  --resource-group "$RG_NAME" \
  --name "$LB_NAME" \
  --sku Standard \
  --public-ip-address "$PIP_NAME" \
  --frontend-ip-name Frontend1 \
  --backend-pool-name BackendPool1 \
  --location "$LOCATION" \
  --tags "$TAGS" \
  --output none

echo "Creating Health Probe"

az network lb probe create \
  --resource-group "$RG_NAME" \
  --lb-name "$LB_NAME" \
  --name HealthProbe80 \
  --protocol Tcp \
  --port 80 \
  --output none

echo "Creating Load Balancing Rule"

az network lb rule create \
  --resource-group "$RG_NAME" \
  --lb-name "$LB_NAME" \
  --name HTTPRule \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name Frontend1 \
  --backend-pool-name BackendPool1 \
  --probe-name HealthProbe80 \
  --output none

echo "Creating Web VM"

az vm create \
  --resource-group "$RG_NAME" \
  --name "$VM_WEB" \
  --image Ubuntu2204 \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --vnet-name "$VNET_NAME" \
  --subnet snet-web \
  --nsg "" \
  --public-ip-address "" \
  --size "$VM_SIZE" \
  --tags "$TAGS" \
  --output none

echo "Installing Nginx on Web VM"

az vm extension set \
  --resource-group "$RG_NAME" \
  --vm-name "$VM_WEB" \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"commandToExecute": "sudo apt-get update && sudo apt-get install -y nginx && sudo systemctl enable nginx && sudo systemctl start nginx"}' \
  --output none

echo "Creating App VM"

az vm create \
  --resource-group "$RG_NAME" \
  --name "$VM_APP" \
  --image Ubuntu2204 \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --vnet-name "$VNET_NAME" \
  --subnet snet-app \
  --nsg "" \
  --public-ip-address "" \
  --size "$VM_SIZE" \
  --tags "$TAGS" \
  --output none

echo "Adding Web VM NIC to Load Balancer Backend Pool"

WEB_NIC_ID=$(az vm show \
  --resource-group "$RG_NAME" \
  --name "$VM_WEB" \
  --query "networkProfile.networkInterfaces[0].id" \
  --output tsv)

WEB_NIC_NAME=$(basename "$WEB_NIC_ID")

WEB_IPCONFIG_NAME=$(az network nic ip-config list \
  --resource-group "$RG_NAME" \
  --nic-name "$WEB_NIC_NAME" \
  --query "[0].name" \
  --output tsv)

az network nic ip-config address-pool add \
  --resource-group "$RG_NAME" \
  --nic-name "$WEB_NIC_NAME" \
  --ip-config-name "$WEB_IPCONFIG_NAME" \
  --lb-name "$LB_NAME" \
  --address-pool backendpool1 \
  --output none

echo "Compute resources created successfully."