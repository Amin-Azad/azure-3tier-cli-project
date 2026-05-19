#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./00-variables.sh
source "${SCRIPT_DIR}/00-variables.sh"

echo "=== Creating Recovery Services Vault ==="

az backup vault create \
  --resource-group "$RG_NAME" \
  --name "$RSV_NAME" \
  --location "$LOCATION" \
  --output none

echo "=== Creating Backup Policy ==="

az backup policy create \
  --resource-group "$RG_NAME" \
  --vault-name "$RSV_NAME" \
  --name "$BACKUP_POLICY_NAME" \
  --backup-management-type AzureIaasVM \
  --policy "$(az backup policy get-default-for-vm \
      --resource-group "$RG_NAME" \
      --vault-name "$RSV_NAME")" \
  --output none

echo "=== Enabling Backup for Web VM ==="

az backup protection enable-for-vm \
  --resource-group "$RG_NAME" \
  --vault-name "$RSV_NAME" \
  --vm "$VM_WEB" \
  --policy-name "$BACKUP_POLICY_NAME" \
  --output none

echo "=== Enabling Backup for App VM ==="

az backup protection enable-for-vm \
  --resource-group "$RG_NAME" \
  --vault-name "$RSV_NAME" \
  --vm "$VM_APP" \
  --policy-name "$BACKUP_POLICY_NAME" \
  --output none

echo "Backup configuration completed."

az backup vault show \
  --resource-group "$RG_NAME" \
  --name "$RSV_NAME" \
  --query "{Name:name, Location:location, ResourceGroup:resourceGroup}" \
  --output table