# Azure 3-Tier Architecture

```mermaid
flowchart TB
    User[Internet / User] --> LB[Public Load Balancer]

    subgraph Azure[Azure Resource Group: rg-3tier-dev]
        subgraph VNET[Virtual Network: vnet-3tier-dev]
            subgraph WEB[Web Subnet: snet-web]
                LB --> WEBVM[Web VM: vm-web-dev]
            end

            subgraph APP[App Subnet: snet-app]
                WEBVM --> APPVM[App VM: vm-app-dev]
            end

            subgraph DATA[Data Subnet: snet-data]
                STG[Storage Account]
            end

            subgraph MGMT[Management Subnet: snet-mgmt]
                NSG[Network Security Groups]
            end
        end

        MI[Managed Identity]
        IAM[CloudAdmins Group + RBAC]
        LAW[Log Analytics Workspace]
        RSV[Recovery Services Vault]
        LOCK[Resource Group Delete Lock]

        WEBVM --> LAW
        APPVM --> LAW
        STG --> LAW
        WEBVM --> RSV
        APPVM --> RSV
        MI --> STG
        IAM --> Azure
        LOCK --> Azure
    end

