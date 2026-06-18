# Cloud Platforms

Learn the shared concepts behind cloud providers before memorizing individual service names.

## Core Services

- Virtual machines and machine images
- Containers and serverless compute
- Object, block, and file storage
- Virtual networks, subnets, routes, and gateways
- Load balancers and DNS
- Managed relational and NoSQL databases
- Queues, topics, and event systems
- Identity and access management (`IAM`)
- Key and secret management

## Architecture Topics

- Regions and availability zones
- High availability and fault tolerance
- Auto scaling
- Backups and disaster recovery
- Shared responsibility model
- Infrastructure costs and budgets
- Resource tagging and ownership
- Quotas and service limits

## Providers to Explore

- **AWS**: EC2, ECS, EKS, Lambda, S3, RDS, VPC, IAM, and CloudWatch
- **Google Cloud**: Compute Engine, GKE, Cloud Run, Cloud Storage, Cloud SQL, VPC, IAM, and Cloud Monitoring
- **Azure**: Virtual Machines, AKS, Container Apps, Blob Storage, Azure SQL, Virtual Network, Entra ID, and Azure Monitor

## Mid/Senior Interview Questions and Answers

### 1. How do regions and availability zones affect application design?

**Answer:** Regions affect latency, compliance, disaster recovery, and data
residency. Availability zones affect fault tolerance within a region.

For production systems, deploy critical components across multiple zones when
the availability target justifies it. Multi-region designs are more complex and
should be reserved for strict latency, resilience, or regulatory needs.

### 2. When should an application use virtual machines, containers, or serverless compute?

**Answer:** Use virtual machines when you need OS-level control, legacy runtime
support, or predictable long-running workloads. Use containers when you need
portable packaging, repeatable deployments, and better orchestration. Use
serverless when workloads are event-driven, spiky, and can fit within platform
limits.

Senior trade-off: serverless reduces infrastructure management but can increase
cold-start, observability, local testing, and vendor lock-in concerns.

### 3. How do security groups and network ACLs differ?

**Answer:** Security groups usually apply to resources such as instances or
interfaces and are commonly stateful. Network ACLs usually apply at the subnet
boundary and are commonly stateless.

Use security groups for service-level access control and network ACLs for coarse
subnet-level rules. Exact behavior depends on the cloud provider.

### 4. How would you estimate and monitor workload cost?

**Answer:** Estimate cost from compute size and runtime, storage volume, data
transfer, managed service pricing, logging volume, backup retention, and support
costs. Then tag resources by owner, service, and environment so spending can be
attributed.

In production, use budgets, alerts, dashboards, anomaly detection, and regular
review of idle or oversized resources.
