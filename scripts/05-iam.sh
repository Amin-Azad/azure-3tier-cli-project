#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./00-variables.sh
source "${SCRIPT_DIR}/00-variables.sh"

echo "Creating Security Group"

GROUP_NAME="CloudAdmins"

GROUP_ID=$(az ad group create \
  --display-name "$GROUP_NAME" \
  --mail-nickname "$GROUP_NAME" \
  --query id \
  --output tsv 2>/dev/null || \
  az ad group show \
    --group "$GROUP_NAME" \
    --query id \
    --output tsv)

echo "Group ID: $GROUP_ID"

echo "Creating User Assigned Managed Identity"

az identity create \
  --resource-group "$RG_NAME" \
  --name "$IDENTITY_NAME" \
  --location "$LOCATION" \
  --tags "$TAGS" \
  --output none

IDENTITY_PRINCIPAL_ID=$(az identity show \
  --resource-group "$RG_NAME" \
  --name "$IDENTITY_NAME" \
  --query principalId \
  --output tsv)

echo "Managed Identity Principal ID: $IDENTITY_PRINCIPAL_ID"

echo "Assigning Storage Blob Data Contributor"

az role assignment create \
  --assignee-object-id "$IDENTITY_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_NAME" \
  --output none

echo "Assigning Reader Role to CloudAdmins Group"

az role assignment create \
  --assignee-object-id "$GROUP_ID" \
  --assignee-principal-type Group \
  --role "Reader" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG_NAME" \
  --output none

echo "IAM configuration completed successfully."