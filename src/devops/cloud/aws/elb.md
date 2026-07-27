# Elastic Load Balancing (ELB)

## What Is ELB?

Elastic Load Balancing distributes incoming traffic across multiple targets (EC2 instances, containers, IPs) in one or more AZs. AWS offers three load balancer types.

## ALB vs NLB vs GLB

| Feature | ALB | NLB | GLB |
|---------|-----|-----|-----|
| Layer | 7 (HTTP/HTTPS) | 4 (TCP/UDP) | 3 (GENEVE) |
| Static IP | No | Yes | No |
| WebSocket | Yes | Yes | N/A |
| Path/host routing | Yes | No | No |
| Ultra-low latency | No | Yes | No |
| Use case | Web apps, microservices | Gaming, IoT, extreme perf | Service mesh, custom UDP |

### ALB (Application Load Balancer)

```bash
aws elbv2 create-load-balancer \
  --name my-alb \
  --subnets subnet-aaa subnet-bbb \
  --security-groups sg-0abc123 \
  --type application
```

### NLB (Network Load Balancer)

```bash
aws elbv2 create-load-balancer \
  --name my-nlb \
  --subnets subnet-aaa subnet-bbb \
  --type network \
  --scheme internet-facing
```

### GLB (Gateway Load Balancer)

Operates at layer 3 and routes traffic to third-party virtual appliances (firewalls, IDS/IPS) using the GENEVE protocol.

## Target Groups

A target group defines where traffic is routed — EC2 instances, Lambda functions, or container IPs. Each load balancer routes to one or more target groups.

```bash
aws elbv2 create-target-group \
  --name my-tg \
  --protocol HTTP --port 80 \
  --vpc-id vpc-0abc123 \
  --health-check-path /health \
  --health-check-interval-seconds 30 \
  --healthy-threshold-count 3 \
  --unhealthy-threshold-count 2
```

## Health Checks

The load balancer periodically pings each target's health check endpoint. Targets that fail are removed from rotation automatically.

Key parameters:
- **Protocol**: HTTP, HTTPS, or TCP
- **Path**: e.g., `/health`
- **Interval**: 5–300 seconds
- **Threshold**: consecutive successes/failures before marking healthy/unhealthy

## Sticky Sessions (Session Affinity)

ALB uses a **application-based cookie** to bind a user's session to a specific target. Useful for stateful applications.

```bash
# Enable stickiness on a target group
aws elbv2 modify-target-group-attributes \
  --target-group-arn arn:aws:elasticloadbalancing:...targetgroup/my-tg/abc \
  --attributes Key=stickiness.enabled,Value=true \
                Key=stickiness.type,Value=app_cookie \
                Key=stickiness.app_cookie.cookie_name,Value=SESSION_ID
```

## SSL/TLS Termination

Load balancers terminate SSL using an ACM certificate. Traffic from the LB to targets can be HTTP (unencrypted) or re-encrypted HTTPS.

```bash
# Create HTTPS listener with ACM cert
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:...loadbalancer/app/my-alb/abc \
  --protocol HTTPS --port 443 \
  --certificates CertificateArn=arn:aws:acm:...certificate/xyz \
  --default-actions Type=forward,TargetGroupArn=arn:...targetgroup/my-tg/abc
```

## Path-Based Routing

ALB listener rules route traffic based on URL path, host header, or query parameters.

```
Listener (HTTPS :443)
  ├── Path: /api/*   → Target Group: api-tg
  ├── Path: /static/* → Target Group: static-tg
  └── Default         → Target Group: web-tg
```

```bash
aws elbv2 create-rule \
  --listener-arn arn:aws:elasticloadbalancing:...listener/app/my-lb/abc/def \
  --priority 10 \
  --conditions Field=path-pattern,Values='/api/*' \
  --actions Type=forward,TargetGroupArn=arn:...targetgroup/api-tg/abc
```

---

## Interview Q&A

**Q1: When would you choose NLB over ALB?**
Use NLB when you need ultra-low latency (microsecond-level), static IP addresses, or you're serving non-HTTP protocols like TCP, UDP, or TLS pass-through. ALB is better when you need layer-7 features like path-based routing, host-based routing, or WebSocket support.

**Q2: How does an ALB handle a failing target during a rolling deployment?**
The ALB's health checks detect that the target is unhealthy and stop routing traffic to it. Combined with Auto Scaling, the failed target can be replaced. During rolling deployments, you can set up a two-target-group strategy: shift weights from the old target group to the new one gradually, monitoring health at each step.
