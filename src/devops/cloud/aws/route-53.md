# Amazon Route 53

## What Is Route 53?

Route 53 is AWS's scalable DNS and domain registration service. It routes end users to internet applications by translating domain names to IP addresses.

## DNS Record Types

| Record | Maps To | Example |
|--------|---------|---------|
| A | IPv4 address | `example.com -> 192.0.2.1` |
| AAAA | IPv6 address | `example.com -> 2001:db8::1` |
| CNAME | Another domain name | `www.example.com -> example.com` |
| Alias | AWS resource (ALB, CloudFront, S3) | `example.com -> ALB DNS name` |
| MX | Mail server | `example.com -> mail.example.com` |
| TXT | Text data (SPF, DKIM) | `"v=spf1 include:..."` |
| NS | Name servers for the zone | Delegation |
| SOA | Start of authority | Zone metadata |

### Alias vs CNAME

| Feature | Alias | CNAME |
|---------|-------|-------|
| Works at zone apex | Yes | No |
| Additional cost | Free | N/A |
| Targets | AWS resources only | Any domain name |

```bash
# Create an alias record pointing to an ALB
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890 \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "example.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "my-alb-123456.us-east-1.elb.amazonaws.com",
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "EvaluateTargetHealth": true
        }
      }
    }]
  }'
```

## Routing Policies

### Simple

Single resource. All traffic goes to one destination.

### Weighted

Distribute traffic across multiple resources by percentage.

```json
{ "Name": "api.example.com", "Type": "A", "SetIdentifier": "v1", "Weight": 80 }
{ "Name": "api.example.com", "Type": "A", "SetIdentifier": "v2", "Weight": 20 }
```

Use for canary deployments and A/B testing.

### Latency

Route to the AWS region with the lowest latency for the user.

```json
{ "Name": "api.example.com", "Type": "A", "SetIdentifier": "us-east-1", "Region": "us-east-1" }
{ "Name": "api.example.com", "Type": "A", "SetIdentifier": "eu-west-1", "Region": "eu-west-1" }
```

### Failover

Primary/secondary configuration for disaster recovery. Route 53 checks health of the primary and fails over to secondary if unhealthy.

### Geolocation

Route based on the user's physical location (continent, country, or state).

## Health Checks

Route 53 monitors endpoint health and removes unhealthy targets from DNS responses.

```bash
aws route53 create-health-check \
  --caller-reference $(date +%s) \
  --health-check-config '{
    "IPAddress": "192.0.2.1",
    "Port": 443,
    "Type": "HTTPS",
    "ResourcePath": "/health",
    "RequestInterval": 10,
    "FailureThreshold": 3
  }'
```

Health checks integrate with failover and weighted routing policies. For private hosted zones, use CloudWatch alarms as the health check source.

---

## Interview Q&A

**Q1: What is the difference between an Alias record and a CNAME?**
A CNAME maps a name to another name and cannot be used at the zone apex (the root domain). An Alias record maps a name to an AWS resource and works at the zone apex. Alias records are free, while standard DNS queries against CNAME records count against your Route 53 query pricing. Alias records also automatically track changes to the underlying resource's IP address.

**Q2: How does weighted routing work with health checks?**
When a target associated with a weighted record fails its health check, Route 53 removes it from DNS responses. Traffic is redistributed proportionally among the remaining healthy targets based on their relative weights. For example, if you have two targets weighted 50/50 and one becomes unhealthy, all traffic goes to the remaining healthy target.
