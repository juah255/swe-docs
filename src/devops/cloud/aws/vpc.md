# Amazon VPC

## What Is VPC?

Virtual Private Cloud (VPC) is a logically isolated section of the AWS network where you launch resources. You define IP address ranges, subnets, route tables, and gateways.

## Subnets

| Type | Internet Access | Use Case |
|------|----------------|----------|
| Public | Route to Internet Gateway | Web servers, bastion hosts |
| Private | No direct internet route | Databases, internal services |

```bash
# Create a VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create a public subnet
aws ec2 create-subnet \
  --vpc-id vpc-0abc123 \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a

# Enable auto-assign public IP
aws ec2 modify-subnet-attribute \
  --subnet-id subnet-0abc123 \
  --map-public-ip-on-launch
```

## Route Tables

Route tables control where network traffic is directed.

```
# Public subnet route table
Destination    Target
10.0.0.0/16    local          # VPC-internal traffic
0.0.0.0/0      igw-0abc123    # Internet access
```

```bash
# Create route to Internet Gateway
aws ec2 create-route \
  --route-table-id rtb-0abc123 \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id igw-0abc123
```

## Internet Gateway (IGW)

Attaches to your VPC and enables communication between VPC resources and the internet. One IGW per VPC.

```bash
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway \
  --internet-gateway-id igw-0abc123 \
  --vpc-id vpc-0abc123
```

## NAT Gateway

Allows private subnet instances to initiate outbound internet connections (e.g., for patches, API calls) while remaining unreachable from outside.

```bash
# Allocate an Elastic IP
aws ec2 allocate-address --domain vpc

# Create NAT Gateway in a public subnet
aws ec2 create-nat-gateway \
  --subnet-id subnet-public \
  --allocation-id eipalloc-0abc123
```

Add a route in the private route table:

```
Destination    Target
10.0.0.0/16    local
0.0.0.0/0      nat-0abc123
```

## Security Groups vs NACLs

| Feature | Security Group | NACL |
|---------|---------------|------|
| Scope | Instance-level | Subnet-level |
| State | Stateful (return traffic auto-allowed) | Stateless (must allow both directions) |
| Rules | Allow only | Allow and Deny |
| Evaluation | All rules evaluated | Rules processed in order |

**Security Groups** are the primary firewall. Use NACLs as an additional subnet-level defense.

```bash
# Security Group: allow HTTPS inbound
aws ec2 authorize-security-group-ingress \
  --group-id sg-0abc123 \
  --protocol tcp --port 443 \
  --cidr 0.0.0.0/0
```

## VPC Flow Logs

Capture IP traffic metadata for analysis and troubleshooting.

```bash
# Enable flow logs for a VPC
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-0abc123 \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /vpc/flowlogs \
  --deliver-logs-permission-arn arn:aws:iam::123456789012:role/FlowLogsRole
```

Flow log format:

```
version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes start end action log-status
```

Common use cases: troubleshooting connectivity, security analysis, compliance auditing.

---

## Interview Q&A

**Q1: What is the difference between a NAT Gateway and a NAT Instance?**
A NAT Gateway is a fully managed, highly available AWS service that scales automatically up to 45 Gbps. A NAT Instance is an EC2 instance you manage yourself — cheaper but requires manual scaling, patching, and failover configuration. NAT Gateway is recommended for production workloads; NAT Instance is useful for lab environments or very small workloads.

**Q2: Why would you use both Security Groups and NACLs?**
Security Groups operate at the instance level and are stateful — they're the primary firewall and are sufficient for most use cases. NACLs operate at the subnet level and are stateless — they're useful as a secondary defense layer, such as blocking known malicious IP ranges at the subnet boundary before traffic even reaches an instance. Using both provides defense in depth.
