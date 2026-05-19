# Azure 3-Tier Architecture

```mermaid
flowchart LR
    User[User / Internet] --> LB[Public Load Balancer]
    LB --> WebVM[Web VM<br>vm-web-dev<br>snet-web]
    WebVM --> AppVM[App VM<br>vm-app-dev<br>snet-app]
    AppVM --> Storage[Storage Account<br>st3tierdev01]

    WebVM --> Monitor[Log Analytics Workspace]
    AppVM --> Monitor

    WebVM --> Backup[Recovery Services Vault]
    AppVM --> Backup

    Identity[Managed Identity] --> Storage
    RBAC[CloudAdmins Group<br>RBAC Reader Access] --> RG[Resource Group<br>rg-3tier-dev]
    Lock[Delete Lock] --> RG