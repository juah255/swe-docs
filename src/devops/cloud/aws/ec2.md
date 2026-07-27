# Amazon EC2

## What Is EC2?

Elastic Compute Cloud (EC2) provides resizable virtual machines in the AWS cloud. You pick an AMI, an instance type, a security group, and a key pair — and you have a running server in minutes.

## Instance Types

| Family | Purpose | Example |
|--------|---------|---------|
| General (T/M) | Balanced CPU & memory | t3.micro, m5.large |
| Compute (C) | CPU-intensive workloads | c5.xlarge |
| Memory (R) | In-memory databases, caching | r5.2xlarge |
| Storage (I/D) | High I/O, dense storage | i3.4xlarge |
| Accelerator (P/G) | ML training, GPU rendering | p3.2xlarge |

Burstable T3 instances earn CPU credits when idle and spend them during spikes — ideal for variable workloads.

## AMIs

An AMI is a pre-configured OS image. AWS provides public AMIs (Amazon Linux 2, Ubuntu, Windows), and you can create custom AMIs from running instances.

```bash
# List Amazon Linux 2 AMIs
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'Images[*].[ImageId,Name]' --output table
```

## Security Groups

Stateful firewalls attached to instances. Allow inbound/outbound rules by protocol, port, and source CIDR or another security group.

```bash
# Allow SSH from your IP only
aws ec2 authorize-security-group-ingress \
  --group-id sg-0abc123 --protocol tcp --port 22 \
  --cidr 203.0.113.5/32
```

## Key Pairs

EC2 uses public-key cryptography for SSH access. AWS stores the public key; you keep the `.pem` file.

```bash
# Create a key pair and save the private key
aws ec2 create-key-pair --key-name my-key \
  --query 'KeyMaterial' --output text > my-key.pem
chmod 400 my-key.pem
```

## User Data

A script that runs once at launch. Useful for bootstrapping software installations.

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
echo "<h1>Hello from EC2</h1>" > /var/www/html/index.html
```

Pass it via the console or CLI:

```bash
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t3.micro \
  --key-name my-key \
  --user-data file://userdata.sh
```

## Spot Instances

Unused AWS capacity sold at up to 90% discount. Great for batch jobs, CI runners, and stateless workloads that tolerate interruption.

- **Spot Block**: Previously available (now legacy)
- **Spot Fleet**: Request across multiple instance types and AZs
- Use **interruption notices** (2-minute warning via metadata or EventBridge) to checkpoint work

```bash
aws ec2 request-spot-instances \
  --spot-price "0.05" \
  --instance-count 1 \
  --type one-time \
  --launch-specification file://spec.json
```

## EC2 vs Containers

| Factor | EC2 | Containers (ECS/EKS) |
|--------|-----|----------------------|
| OS control | Full control | Shared kernel |
| Scaling | Minutes | Seconds |
| Density | 1 app per VM | Many containers per host |
| Best for | Legacy apps, GPU, high I/O | Microservices, bursty workloads |

Choose EC2 when you need full OS access, licensed software, or dedicated hardware. Choose containers for portability and faster scaling.

## Horizontal vs Vertical Scaling

- **Vertical scaling (scale up):** Bigger machine (more CPU, RAM). Simple, no code changes needed. Has a ceiling (largest instance size) and causes downtime during resizes.
- **Horizontal scaling (scale out):** More machines behind a load balancer. Higher ceiling, better fault tolerance, but requires stateless services, shared sessions (Redis), and distributed data stores.

Horizontal scaling is the answer for high availability and large scale. Vertical scaling is a reasonable starting point for smaller workloads.

**Stateless requirement:** For horizontal scaling, each request must be handleable by any instance. Store session state in Redis or a database, not on local disk.

---

## Interview Q&A

**Q1: What is the difference between an instance store and an EBS volume?**
An instance store is ephemeral, physically attached to the host machine — data is lost if the instance stops or terminates. EBS volumes are network-attached block storage that persist independently and can be detached and reattached to another instance.

**Q2: When would you choose a Spot Instance over a Reserved Instance?**
Spot Instances are ideal for fault-tolerant, stateless, or time-flexible workloads (batch processing, CI/CD pipelines, data processing) where interruptions are acceptable. Reserved Instances are better for steady-state, always-on workloads where you need predictable capacity and pricing over a 1–3 year commitment.
