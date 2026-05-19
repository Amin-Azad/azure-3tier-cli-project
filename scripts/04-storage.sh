#!/bin/bash 

set -euo pipefail 

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00-variables.sh" 

echo "Creating Storage account"

az storage account create \
  --resource-group "$RG_NAME" \
  --name "$STORAGE_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --tags "$TAGS" \
  --output none

echo "Storage account key" 

STORAGE_KEY=$(az storage account keys list \
  --resource-group "$RG_NAME" \
  --account-name "$STORAGE_NAME" \
  --query "[].value" \
  --output tsv)

echo "Creating Blob container" 

az storage container create \
   --account-name "$STORAGE_NAME" \
  --account-key "$STORAGE_KEY" \
  --name uploads \
  --public-access off \
  --output none 

echo "creating file share "

az storage share-rm create \
  --resource-group "$RG_NAME" \
  --account-name "$STORAGE_NAME" \
  --name appshare \
  --quota 100 \
  --enabled-protocols SMB \
  --output none 

echo "Storage and fileShare created successfully" 

echo "Summary" 

az storage account show \
  --resource-group "$RG_NAME" \
  --name "$STORAGE_NAME" \
  --query "{Name:name, Location:location, SKU:sku.name}" \
  --output table 

