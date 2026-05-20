#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00-variables.sh"

echo "Starting CleanUp for $RG_NAME"

echo "Checking resource group"
az group show --name "$RG_NAME" --output table

echo "Removing resource group locks"
LOCK_IDS=$(az lock list \
  --resource-group "$RG_NAME" \
  --query "[].id" \
  --output tsv)

if [ -z "$LOCK_IDS" ]; then
  echo "No locks found."
else
  for LOCK_ID in $LOCK_IDS; do
    echo "Deleting lock: $LOCK_ID"
    az lock delete --ids "$LOCK_ID"
  done
fi

echo "Deleting resource group"
az group delete \
  --name "$RG_NAME" \
  --yes \
  --no-wait

echo "CleanUp started successfully"
echo "Resource group deletion is running in the background."
