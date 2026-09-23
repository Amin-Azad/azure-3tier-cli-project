#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00-variables.sh"

echo "Starting cleanup for $RG_NAME"

if ! az group show --name "$RG_NAME" --output none 2>/dev/null; then
  echo "Resource group does not exist. Nothing to clean up."
  exit 0
fi

echo "Removing resource group locks"

mapfile -t LOCK_IDS < <(
  az lock list     --resource-group "$RG_NAME"     --query "[].id"     --output tsv
)

for LOCK_ID in "${LOCK_IDS[@]}"; do
  echo "Deleting lock: $LOCK_ID"
  az lock delete --ids "$LOCK_ID"
done

echo "Deleting resource group"

az group delete   --name "$RG_NAME"   --yes

if az group exists --name "$RG_NAME" | grep -qi '^true$'; then
  echo "ERROR: resource group still exists after cleanup."
  exit 1
fi

echo "Cleanup completed. Resource group removed."
