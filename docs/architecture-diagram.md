# Azure 3-Tier Architecture

This diagram shows the infrastructure layout created by the scripts. The web-to-app and app-to-data lines represent the network paths allowed by the NSGs; the project does not include a complete application using those paths.

```mermaid
flowchart TD
    A[User / Internet]
    B[Standard Public Load Balancer]
    C[Web Tier<br/>Linux VM + Nginx<br/>snet-web]
    D[App Tier<br/>Linux VM<br/>snet-app]
    E[Data / Service Tier<br/>Storage Account<br/>snet-data]

    A --> B
    B --> C
    C -. allowed port 8080 .-> D
    D -. allowed ports 443 / 445 .-> E

    F[Log Analytics] --> C
    F --> B

    G[Recovery Services Vault] --> C
    G --> D

    H[User-assigned Managed Identity<br/>Storage Blob Data Contributor] --> E
    I[CloudAdmins Group<br/>Reader] --> J[Resource Group]
    K[CanNotDelete Lock] --> J
```
