# Microsoft Azure for DevOps

Azure is Microsoft's cloud platform, strong for organizations in the
Microsoft ecosystem (Entra ID, .NET, Windows Server). It offers a broad
set of services comparable to AWS and GCP.

## Virtual Machines

Azure VMs are IaaS compute instances supporting Linux and Windows with
sizes optimized for general, compute, memory, and GPU workloads.

```bash
az vm create --name my-vm --resource-group my-rg \
  --image Ubuntu2204 --size Standard_B2s \
  --admin-username azureuser \
  --ssh-key-value ~/.ssh/id_rsa.pub

az vm list -o table
az vm start --name my-vm --resource-group my-rg
az vm stop --name my-vm --resource-group my-rg
```

**AWS equivalent:** EC2

## Azure Container Instances (ACI)

ACI runs containers serverlessly — no cluster to manage. Ideal for batch
jobs, build agents, and simple microservices.

```bash
az container create --name my-app --resource-group my-rg \
  --image nginx:latest --ports 80 --ip-address Public

az container show --name my-app --resource-group my-rg \
  --query instanceView.state -o tsv
```

**AWS equivalent:** Fargate (on ECS)

## Blob Storage

Blob Storage is Azure's object storage. It supports Block Blobs (files),
Append Blobs (logs), and Page Blobs (VHDs).

```bash
az storage account create --name mystore --resource-group my-rg
az storage container create --name backups --account-name mystore
az storage blob upload --container-name backups \
  --name db-dump.sql --file ./db-dump.sql --account-name mystore
az storage blob list --container-name backups \
  --account-name mystore -o table
```

**AWS equivalent:** S3

## Azure SQL

Managed SQL Server with automatic patching, backups, and auto-tuning.

```bash
az sql server create --name myserver --resource-group my-rg \
  --location eastus --admin-user sqladmin --admin-password P@ssw0rd1234
az sql db create --name mydb --server myserver \
  --resource-group my-rg --service-tier Basic
```

**AWS equivalent:** RDS

## Virtual Network (VNet)

VNets provide isolated networks with subnets, NSGs, and peering —
directly analogous to AWS VPC.

```bash
az network vnet create --name my-vnet --resource-group my-rg \
  --address-prefix 10.0.0.0/16 --subnet-name web-subnet \
  --subnet-prefix 10.0.1.0/24

az network nsg rule create --nsg-name my-nsg --resource-group my-rg \
  --name AllowSSH --priority 1000 --protocol Tcp \
  --destination-port-ranges 22 --access Allow --direction Inbound
```

**AWS equivalent:** VPC

## Microsoft Entra ID (formerly Azure AD)

Identity and access management providing SSO, MFA, conditional access,
and RBAC for Azure resources.

```bash
az ad sp create-for-rbac --name my-app --role Contributor \
  --scopes /subscriptions/<sub-id>
```

**AWS equivalent:** IAM

## Azure Monitor

Collects metrics, logs, and traces. Includes Log Analytics, Application
Insights, and alert rules.

```bash
az monitor metrics alert create --name high-cpu --resource-group my-rg \
  --scopes /subscriptions/<sub>/.../my-vm \
  --condition "avg Percentage CPU > 80" \
  --action-group my-action-group
```

**AWS equivalent:** CloudWatch

## Quick Comparison with AWS

| Concept | Azure | AWS |
|---|---|---|
| Compute | Virtual Machines | EC2 |
| Containers | ACI / AKS | Fargate / EKS |
| Object Storage | Blob Storage | S3 |
| Managed SQL | Azure SQL | RDS |
| Networking | VNet | VPC |
| Identity | Entra ID | IAM |
| Monitoring | Azure Monitor | CloudWatch |

## Interview Q&As

### 1. What is the difference between Azure Blob Storage tiers?

**Answer:** Hot is for frequently accessed data with higher storage cost but
lower access cost. Cool is for infrequently accessed data (min 30 days) with
lower storage but higher retrieval cost. Archive is for rarely accessed data
(min 180 days) with the lowest storage cost but retrieval takes hours.
Lifecycle policies can auto-move blobs between tiers based on age.

### 2. How does Azure RBAC differ from subscription-level permissions?

**Answer:** Azure RBAC is hierarchical and additive. Permissions at a
management group or subscription level propagate to all child resources.
Roles can be scoped to management group, subscription, resource group, or
a single resource. A Contributor at subscription level can manage everything,
while a role at resource group scope only applies to that group. Deny
assignments from policies can override RBAC allow assignments.
