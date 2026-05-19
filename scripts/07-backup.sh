#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00-variables.sh"

echo "Creating Recovery Services Vault"

az backup vault create \
  --resource-group "$RG_NAME" \
  --name "$RSV_NAME" \
  --location "$LOCATION" \
  --output none

echo "Creating Backup Policy"

az backup policy create \
  --resource-group "$RG_NAME" \
  --vault-name "$RSV_NAME" \
  --name "$BACKUP_POLICY_NAME" \
  --backup-management-type AzureIaasVM \
  --policy "$(az backup policy get-default-for-vm \
      --resource-group "$RG_NAME" \
      --vault-name "$RSV_NAME")" \
  --output none 2>/dev/null || echo "Backup policy already exists - skipping"

echo "Getting VM Resource IDs"

WEB_VM_ID=$(az vm show -g "$RG_NAME" -n "$VM_WEB" --query id -o tsv)
APP_VM_ID=$(az vm show -g "$RG_NAME" -n "$VM_APP" --query id -o tsv)

enable_backup_if_needed () {
  local VM_NAME="$1"
  local VM_ID="$2"

  echo "Checking backup protection for $VM_NAME"

  if az backup item list \
    --resource-group "$RG_NAME" \
    --vault-name "$RSV_NAME" \
    --backup-management-type AzureIaasVM \
    --query "[?properties.friendlyName=='$VM_NAME']" \
    -o tsv | grep -q "$VM_NAME"; then

    echo "Backup already enabled for $VM_NAME - skipping"

  else
    echo "Enabling backup for $VM_NAME"

    az backup protection enable-for-vm \
      --resource-group "$RG_NAME" \
      --vault-name "$RSV_NAME" \
      --vm "$VM_ID" \
      --policy-name "$BACKUP_POLICY_NAME" \
      --output none

    echo "Backup enabled for $VM_NAME"
  fi
}

enable_backup_if_needed "$VM_WEB" "$WEB_VM_ID"
enable_backup_if_needed "$VM_APP" "$APP_VM_ID"

echo "Backup protected items"

az backup item list \
  --resource-group "$RG_NAME" \
  --vault-name "$RSV_NAME" \
  --backup-management-type AzureIaasVM \
  --output table

echo "Backup configuration completed."