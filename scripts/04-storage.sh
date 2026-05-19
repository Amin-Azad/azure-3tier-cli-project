#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00-variables.sh"

echo "Storage Account create "

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

echo "Enabling Blob Protection"

az storage account blob-service-properties update \
  --account-name "$STORAGE_NAME" \
  --resource-group "$RG_NAME" \
  --enable-delete-retention true \
  --delete-retention-days 7 \
  --enable-container-delete-retention true \
  --container-delete-retention-days 7 \
  --enable-versioning true \
  --output none

echo "Storage Account Key"

STORAGE_KEY=$(az storage account keys list \
  --resource-group "$RG_NAME" \
  --account-name "$STORAGE_NAME" \
  --query "[0].value" \
  --output tsv)

echo "Blob Containers create"

for CONTAINER in assets logs backups; do
  az storage container create \
    --account-name "$STORAGE_NAME" \
    --account-key "$STORAGE_KEY" \
    --name "$CONTAINER" \
    --public-access off \
    --output none

  echo "Container created or already exists: $CONTAINER"
done

echo "Azure File Share create"

az storage share-rm create \
  --resource-group "$RG_NAME" \
  --account-name "$STORAGE_NAME" \
  --name appshare \
  --quota 100 \
  --enabled-protocols SMB \
  --output none

echo "Uploading Sample HTML File"

echo '<html><body><h1>3-Tier App</h1></body></html>' > /tmp/index.html

az storage blob upload \
  --account-name "$STORAGE_NAME" \
  --account-key "$STORAGE_KEY" \
  --container-name assets \
  --name index.html \
  --file /tmp/index.html \
  --overwrite true \
  --output none

echo "Generating Read-Only SAS Token for assets container"

EXPIRY=$(date -u -d '1 hour' +%Y-%m-%dT%H:%MZ 2>/dev/null || date -u -v+1H +%Y-%m-%dT%H:%MZ)

SAS=$(az storage container generate-sas \
  --account-name "$STORAGE_NAME" \
  --account-key "$STORAGE_KEY" \
  --name assets \
  --permissions r \
  --expiry "$EXPIRY" \
  --output tsv)

echo "SAS token generated. Expiry: $EXPIRY"
echo "Do not commit SAS token to GitHub."

echo "Storage Summary"

az storage account show \
  --resource-group "$RG_NAME" \
  --name "$STORAGE_NAME" \
  --query "{Name:name, Location:location, SKU:sku.name}" \
  --output table

echo "Storage resources created successfully."