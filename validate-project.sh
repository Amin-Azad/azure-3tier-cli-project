#!/bin/bash
set -euo pipefail

# Load project variables
source scripts/00-variables.sh

# Create output folder if it does not exist
mkdir -p docs/outputs


echo "******************** Azure 3-Tier CLI Project - Validation Report**********************"

echo "Project: 3tier"
echo "Environment: $ENVIRONMENT"
echo "Location: $LOCATION"
echo "Resource Group: $RG_NAME"
echo "Generated on: $(date)"

echo ""

echo "1. Resource Group"
echo "-----------------"
az group show \
  --name "$RG_NAME" \
  --query "{Name:name, Location:location, ProvisioningState:properties.provisioningState}" \
  --output table

echo ""
echo "2. All Resources in the Resource Group"
echo "--------------------------------------"
az resource list \
  --resource-group "$RG_NAME" \
  --query "[].{Name:name, Type:type, Location:location}" \
  --output table

echo ""
echo "3. Virtual Network"
echo "------------------"
az network vnet show \
  --resource-group "$RG_NAME" \
  --name "$VNET_NAME" \
  --query "{Name:name, Location:location, AddressSpace:addressSpace.addressPrefixes[0]}" \
  --output table

echo ""
echo "4. Subnets"
echo "----------"
az network vnet subnet list \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --query "[].{Name:name, AddressPrefix:addressPrefix, NSG:networkSecurityGroup.id}" \
  --output table

echo ""
echo "5. Network Security Groups"
echo "--------------------------"
az network nsg list \
  --resource-group "$RG_NAME" \
  --query "[].{Name:name, Location:location}" \
  --output table

echo ""
echo "6. Public IP Addresses"
echo "----------------------"
az network public-ip list \
  --resource-group "$RG_NAME" \
  --query "[].{Name:name, IP:ipAddress, SKU:sku.name, Allocation:publicIPAllocationMethod}" \
  --output table

echo ""
echo "7. Load Balancer"
echo "----------------"
az network lb list \
  --resource-group "$RG_NAME" \
  --query "[].{Name:name, Location:location, SKU:sku.name}" \
  --output table

echo ""
echo "8. Load Balancer Backend Pools"
echo "------------------------------"
az network lb address-pool list \
  --resource-group "$RG_NAME" \
  --lb-name "$LB_NAME" \
  --query "[].{Name:name}" \
  --output table

echo ""
echo "9. Virtual Machines"
echo "-------------------"
az vm list \
  --resource-group "$RG_NAME" \
  --show-details \
  --query "[].{Name:name, PowerState:powerState, PrivateIP:privateIps, PublicIP:publicIps, Size:hardwareProfile.vmSize, Location:location}" \
  --output table

echo ""
echo "10. Storage Account"
echo "-------------------"
az storage account show \
  --resource-group "$RG_NAME" \
  --name "$STORAGE_NAME" \
  --query "{Name:name, Location:location, SKU:sku.name, Kind:kind, HTTPSOnly:enableHttpsTrafficOnly, MinTLS:minimumTlsVersion}" \
  --output table

echo ""
echo "11. Blob Containers"
echo "-------------------"
az storage container list \
  --account-name "$STORAGE_NAME" \
  --auth-mode login \
  --query "[].{Name:name}" \
  --output table

echo ""
echo "12. Azure File Shares"
echo "---------------------"
STORAGE_KEY=$(az storage account keys list \
  --resource-group "$RG_NAME" \
  --account-name "$STORAGE_NAME" \
  --query "[0].value" \
  --output tsv)

az storage share list \
  --account-name "$STORAGE_NAME" \
  --account-key "$STORAGE_KEY" \
  --query "[].{Name:name}" \
  --output table


echo ""
echo "13. Managed Identity"
echo "--------------------"
az identity list \
  --resource-group "$RG_NAME" \
  --query "[].{Name:name, Location:location, PrincipalId:principalId}" \
  --output table

echo ""
echo "14. IAM / RBAC Role Assignments"
echo "-------------------------------"
RG_SCOPE=$(az group show --name "$RG_NAME" --query id --output tsv)

az role assignment list \
  --scope "$RG_SCOPE" \
  --query "[].{Principal:principalName, Role:roleDefinitionName}" \
  --output table

echo ""
echo "15. Log Analytics Workspace"
echo "---------------------------"
az monitor log-analytics workspace show \
  --resource-group "$RG_NAME" \
  --workspace-name "$LAW_NAME" \
  --query "{Name:name, Location:location, RetentionDays:retentionInDays}" \
  --output table

echo ""
echo "16. Storage Diagnostic Settings"
echo "-------------------------------"
STORAGE_ID=$(az storage account show \
  --resource-group "$RG_NAME" \
  --name "$STORAGE_NAME" \
  --query id \
  --output tsv)

az monitor diagnostic-settings list \
  --resource "$STORAGE_ID" \
  --query "[].{Name:name, WorkspaceId:workspaceId}" \
  --output table

echo ""
echo "17. Load Balancer Diagnostic Settings"
echo "-------------------------------------"
LB_ID=$(az network lb show \
  --resource-group "$RG_NAME" \
  --name "$LB_NAME" \
  --query id \
  --output tsv)

az monitor diagnostic-settings list \
  --resource "$LB_ID" \
  --query "[].{Name:name, WorkspaceId:workspaceId}" \
  --output table

echo ""
echo "18. Recovery Services Vault"
echo "---------------------------"
az backup vault show \
  --resource-group "$RG_NAME" \
  --name "$RSV_NAME" \
  --query "{Name:name, Location:location, ResourceGroup:resourceGroup}" \
  --output table

echo ""
echo "19. Backup Policies"
echo "-------------------"
az backup policy list \
  --resource-group "$RG_NAME" \
  --vault-name "$RSV_NAME" \
  --query "[].{Name:name, BackupManagementType:properties.backupManagementType}" \
  --output table

echo ""
echo "20. Backup Protected Items"
echo "--------------------------"
az backup item list \
  --resource-group "$RG_NAME" \
  --vault-name "$RSV_NAME" \
  --backup-management-type AzureIaasVM \
  --query "[].{VM:properties.friendlyName, ProtectionStatus:properties.protectionStatus, HealthStatus:properties.healthStatus}" \
  --output table

echo ""
echo "21. Resource Locks"
echo "------------------"
az lock list \
  --resource-group "$RG_NAME" \
  --query "[].{Name:name, Level:level, Scope:scope}" \
  --output table

echo ""

echo " *******************Validation completed successfully****************************"

