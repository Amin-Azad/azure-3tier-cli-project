# Azure 3-Tier Architecture

```mermaid
flowchart TB
    USER[Internet / User]
    LB[Public Load Balancer]

    USER --> LB

    subgraph RG["Resource Group: rg-3tier-dev"]

        subgraph VNET["Virtual Network: vnet-3tier-dev"]

            subgraph WEB["Web Subnet (10.0.1.0/24)"]
                WEBVM[Web VM: vm-web-dev]
            end

            subgraph APP["App Subnet (10.0.2.0/24)"]
                APPVM[App VM: vm-app-dev]
            end

            subgraph DATA["Data Subnet (10.0.3.0/24)"]
                STG[Storage Account]
            end

            subgraph MGMT["Management Subnet (10.0.4.0/24)"]
                NSG[Network Security Groups]
            end
        end

        MI[User Assigned Managed Identity]
        IAM[CloudAdmins Group + RBAC]
        LAW[Log Analytics Workspace]
        RSV[Recovery Services Vault]
        LOCK[Resource Group Delete Lock]
    end

    LB --> WEBVM
    WEBVM --> APPVM

    WEBVM --> LAW
    APPVM --> LAW
    STG --> LAW

    WEBVM --> RSV
    APPVM --> RSV

    MI --> STG
    IAM --> MI