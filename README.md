# Azure 3-Tier CLI Project

I built this project to practice provisioning Azure infrastructure directly with the Azure CLI and Bash instead of starting with an IaC language.

The repository creates a small three-tier-style environment with separate web, application, data and management subnets. It also includes identity, monitoring, backup, validation and cleanup scripts so I could test the whole resource lifecycle in a real Azure subscription.

> **Status:** deployed and validated in Azure, then cleaned up to avoid ongoing cost.

![Azure 3-tier architecture](docs/images/architecture-diagram.png)

## What I deployed

The environment was deployed in West Europe and included:

- one Virtual Network with four subnets;
- separate Network Security Groups for web, app, data and management traffic;
- a Standard public Load Balancer and Standard public IP;
- one Linux web VM running Nginx;
- one private Linux application VM;
- a Storage account with Blob containers and an Azure File Share;
- a user-assigned Managed Identity with Storage Blob Data Contributor;
- an Entra ID security group with Reader access at resource-group scope;
- Log Analytics and diagnostic settings;
- a Recovery Services Vault and VM backup;
- tags and a CanNotDelete resource lock.

The project is an infrastructure exercise rather than a production application. The network rules model traffic between tiers, but there is no full application or database workload behind those tiers.

## Architecture

| Layer | Azure resources |
| --- | --- |
| Entry | Standard Public IP, Standard Load Balancer |
| Web | Linux VM, Nginx, web subnet and NSG |
| Application | Linux VM, private app subnet and NSG |
| Data | Storage Account, Blob containers, File Share, data subnet and NSG |
| Identity | Entra ID group, user-assigned Managed Identity, RBAC |
| Operations | Log Analytics, diagnostic settings, Recovery Services Vault |
| Governance | Resource lock and tags |

### Network layout

| Subnet | Address space | Purpose |
| --- | --- | --- |
| `snet-web` | `10.0.1.0/24` | Web tier |
| `snet-app` | `10.0.2.0/24` | Application tier |
| `snet-data` | `10.0.3.0/24` | Data/service tier |
| `snet-mgmt` | `10.0.4.0/24` | Management subnet |

The web NSG allows HTTP/HTTPS from the Internet. The app NSG only allows port 8080 from the web subnet. The data NSG only allows ports 443 and 445 from the app subnet. SSH is restricted to the detected administrator public IP on the management NSG.

The current VM layout does not use the management subnet for a jump host, so that subnet is part of the network design rather than an active administration path.

## Deployment flow

The scripts are deliberately small and separated by responsibility:

```text
deploy-all.sh
    ↓
resource group + lock
    ↓
networking + NSGs
    ↓
load balancer + VMs
    ↓
storage
    ↓
identity + RBAC
    ↓
monitoring
    ↓
backup
    ↓
validate-project.sh
    ↓
cleanup.sh
```

The main scripts are:

| Script | Purpose |
| --- | --- |
| `00-variables.sh` | Shared names, region, CIDRs and tags |
| `01-resource-group.sh` | Resource group and delete lock |
| `02-networking.sh` | VNet, subnets and NSGs |
| `03-compute.sh` | Public IP, Load Balancer and Linux VMs |
| `04-storage.sh` | Storage account, Blob containers and File Share |
| `05-iam.sh` | Entra group, Managed Identity and RBAC |
| `06-monitoring.sh` | Log Analytics and diagnostic settings |
| `07-backup.sh` | Recovery Services Vault and VM protection |
| `validate-project.sh` | Live Azure validation |
| `cleanup.sh` | Lock removal and resource-group cleanup |

## Evidence

I kept the deployment and validation evidence in the repository instead of leaving the Azure environment running.

![Deployment output](docs/images/deployall-output.PNG)

![Azure resource overview](docs/images/azure-portal-resources-overview.PNG)

The validation script checked the resource group, VNet, subnets, NSGs, public IP, Load Balancer, VMs, Storage, identity and RBAC, Log Analytics, diagnostic settings, Recovery Services Vault, backup protection and resource locks.

The full evidence is under [docs/outputs](docs/outputs/). Identifiers that are not useful to a reviewer are redacted.

## Problems I hit

Using a real subscription exposed several things I would not have learned from writing the commands alone.

**Provider registration.** Azure Backup initially failed because `Microsoft.RecoveryServices` was not registered.

**Quota and SKU availability.** VM size availability and regional vCPU quota affected which compute SKU I could use.

**Load Balancer compatibility.** A Standard Load Balancer requires a Standard public IP.

**Backup placement.** The Recovery Services Vault has to be in the same region as the VMs it protects.

**Resource locks.** The delete lock worked as expected, but cleanup had to remove it before deleting the resource group.

**Storage lifecycle.** Versioning and retention settings change how storage cleanup behaves.

These issues were useful because I had to troubleshoot the Azure control plane rather than only write a happy-path script.

## Run locally

Prerequisites: Azure CLI, Bash, an Azure subscription, an SSH key pair and enough permission to create the resources used by the scripts.

```bash
git clone https://github.com/Amin-Azad/azure-3tier-cli-project.git
cd azure-3tier-cli-project

az login
az account show --output table

chmod +x deploy-all.sh validate-project.sh scripts/*.sh

./deploy-all.sh
./validate-project.sh
```

Clean up when finished:

```bash
bash scripts/cleanup.sh
```

## Repository checks

Pull requests run lightweight validation for Bash syntax, repository hygiene and basic project structure. The live Azure validation remains a separate step because it requires an authenticated subscription and deployed resources.

This project is intentionally kept as an **Azure CLI/Bash portfolio project**. My other Azure repositories cover Bicep, Terraform, Kubernetes, Helm and GitOps, so I do not plan to convert this repository into another IaC project.
