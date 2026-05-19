# Azure 3-Tier Architecture

```mermaid
flowchart TD
    A[User / Internet]
    B[Public Load Balancer]
    C[Web Tier<br>vm-web-dev<br>snet-web]
    D[App Tier<br>vm-app-dev<br>snet-app]
    E[Storage Tier<br>Storage Account<br>st3tierdev01]

    A --> B
    B --> C
    C --> D
    D --> E

    C --> F[Log Analytics Workspace]
    D --> F

    C --> G[Recovery Services Vault<br>VM Backup]
    D --> G

    H[Managed Identity] --> E
    I[CloudAdmins Group<br>RBAC Reader] --> J[Resource Group<br>rg-3tier-dev]
    K[Delete Lock] --> J
