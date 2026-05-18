#!/bin/bash 

set -euo pipefail 

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00-variables.sh"


#creating resource group if dosent exist 

if az group show --name "$RG_NAME" &>/dev/null; then 
    echo "Resource group '$RG_NAME' already exist - skipping"
else
    az group create \
    --name "$RG_NAME" \
    --location "$LOCATION" \
    --tags "$TAGS" \
    --output table 

    echo "Created resource group '$RG_NAME' "

fi

#adding CanNotDelete lock to the resource group 
az lock create \
--name "lock-${RG_NAME}" \
--resource-group "$RG_NAME" \
--lock-type CanNotDelete \
--output none 2>/dev/null || echo "Lock alrady exist "

