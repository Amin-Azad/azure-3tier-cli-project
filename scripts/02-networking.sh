#!/bin/bash 

set -euo pipefail 

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00-variables.sh"

# Creating Vnet 

az network vnet create \
--resource-group "$RG_NAME" \
--name "$VNET_NAME" \
--address-prefix "$VNET_CIDR" \
--location "$LOCATION" \
--tags "$TAGS" \
--output none 

# Subnet creating 

az network vnet subnet create \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name snet-web \
  --address-prefix "$SNET_WEB_CIDR" \
  --output none

az network vnet subnet create \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name snet-app \
  --address-prefix "$SNET_APP_CIDR" \
  --output none

az network vnet subnet create \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name snet-data \
  --address-prefix "$SNET_DATA_CIDR" \
  --output none

az network vnet subnet create \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name snet-mgmt \
  --address-prefix "$SNET_MGMT_CIDR" \
  --output none

# NSG Create 
az network nsg create \
--resource-group "$RG_NAME" \
--name "$NSG_WEB" \
--location "$LOCATION" \
--tags "$TAGS" \
--output none 

az network nsg create \
--resource-group "$RG_NAME" \
--name "$NSG_APP" \
--location "$LOCATION" \
--tags "$TAGS" \
--output none

az network nsg create \
-g "$RG_NAME" \
-n "$NSG_DATA" \
--location "$LOCATION" \
--tags "$TAGS"  \
--output none

az network nsg create \
-g "$RG_NAME" \
-n "$NSG_MGMT" \
--location "$LOCATION" \
--tags "$TAGS" \
--output none

# Creating NSG ROLES
# NSG_WEB rule
az network nsg rule create \
--resource-group "$RG_NAME" \
--nsg-name "$NSG_WEB" \
--name Allow-HTTP-HTTPS \
--priority 100 \
--direction Inbound \
--protocol TCP \
--source-address-prefixes Internet \
--destination-port-ranges 80 443 \
--access Allow \
--output none

# NSG_APP Rule
az network nsg rule create \
--resource-group "$RG_NAME" \
--nsg-name "$NSG_APP" \
--name Allow-from-web-subnet \
--priority 100 \
--direction Inbound \
--source-address-prefixes "$SNET_WEB_CIDR" \
--destination-port-ranges 8080 \
--access Allow \
--output none 

#NSG_DATA Rule
az network nsg rule create \
  -g "$RG_NAME" \
  --nsg-name "$NSG_DATA" \
  --name Allow-From-App \
  --priority 100 \
  --direction Inbound \
  --protocol Tcp \
  --source-address-prefixes "$SNET_APP_CIDR" \
  --destination-port-ranges 443 445 \
  --access Allow \
  --output none

az network nsg rule create \
  -g "$RG_NAME" \
  --nsg-name "$NSG_MGMT" \
  --name Allow-SSH-MyIP \
  --priority 100 \
  --direction Inbound \
  --protocol Tcp \
  --source-address-prefixes "$MY_IP" \
  --destination-port-ranges 22 \
  --access Allow \
  --output none

# Associating NSGs with subnets
az network vnet subnet update \
  -g "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name snet-web \
  --network-security-group "$NSG_WEB" \
  --output none

az network vnet subnet update \
  -g "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name snet-app \
  --network-security-group "$NSG_APP" \
  --output none

az network vnet subnet update \
  -g "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name snet-data \
  --network-security-group "$NSG_DATA" \
  --output none

az network vnet subnet update \
  -g "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name snet-mgmt \
  --network-security-group "$NSG_MGMT" \
  --output none

az network vnet subnet list \
  -g "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --query "[].{Subnet:name, CIDR:addressPrefix, NSG:networkSecurityGroup.id}" \
  --output table