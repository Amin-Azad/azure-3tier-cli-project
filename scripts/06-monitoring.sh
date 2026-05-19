#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./00-variables.sh
source "${SCRIPT_DIR}/00-variables.sh"

echo "Creating Log Analytics Workspace"

az monitor log-analytics workspace create \
  --resource-group "$RG_NAME" \
  --workspace-name "$LAW_NAME" \
  --location "$LOCATION" \
  --tags "$TAGS" \
  --output none

LAW_ID=$(az monitor log-analytics workspace show \
  --resource-group "$RG_NAME" \
  --workspace-name "$LAW_NAME" \
  --query id \
  --output tsv)

echo "diagnostics seeting enable for Storage Account"

STORAGE_ID=$(az storage account show \
  --resource-group "$RG_NAME" \
  --name "$STORAGE_NAME" \
  --query id \
  --output tsv)

az monitor diagnostic-settings create \
  --name "diag-${STORAGE_NAME}" \
  --resource "$STORAGE_ID" \
  --workspace "$LAW_ID" \
  --metrics '[{"category":"Transaction","enabled":true}]' \
  --output none

echo "diagnostics setting enable for Load Balancer"

LB_ID=$(az network lb show \
  --resource-group "$RG_NAME" \
  --name "$LB_NAME" \
  --query id \
  --output tsv)

az monitor diagnostic-settings create \
  --name "diag-${LB_NAME}" \
  --resource "$LB_ID" \
  --workspace "$LAW_ID" \
  --metrics '[{"category":"AllMetrics","enabled":true}]' \
  --output none

echo "Monitoring setup completed"

az monitor log-analytics workspace show \
  --resource-group "$RG_NAME" \
  --workspace-name "$LAW_NAME" \
  --query "{Name:name, Location:location, ResourceGroup:resourceGroup}" \
  --output table