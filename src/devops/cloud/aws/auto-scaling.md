# Auto Scaling

## What Is Auto Scaling?

Amazon EC2 Auto Scaling automatically adjusts the number of EC2 instances in response to demand. It maintains application availability and allows you to scale horizontally.

## Core Concepts

- **Minimum**: Lowest instance count the group maintains
- **Maximum**: Highest instance count allowed
- **Desired**: Current target count (between min and max)
- **Launch Template**: Defines instance configuration (AMI, type, security groups, user data)

```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --launch-template LaunchTemplateName=my-template,Version='$Latest' \
  --min-size 2 --max-size 10 --desired-capacity 3 \
  --vpc-zone-identifier "subnet-aaa,subnet-bbb" \
  --target-group-arns arn:aws:elasticloadbalancing:...targetgroup/my-tg/abc \
  --health-check-type ELB \
  --health-check-grace-period 300
```

## Launch Templates

A launch template is a versioned configuration for launching instances.

```bash
aws ec2 create-launch-template \
  --launch-template-name my-template \
  --version-description "v1" \
  --launch-template-data '{
    "ImageId": "ami-0abcdef1234567890",
    "InstanceType": "t3.micro",
    "SecurityGroupIds": ["sg-0abc123"],
    "UserData": "IyEvYmluL2Jhc2gKYXB0IHVwZGF0ZSAteQ=="
  }'
```

Benefits over launch configs: versioning, rollback, canary deployments, and multiple versions.

## Scaling Policies

### Target Tracking

Maintains a target metric value. Auto Scaling adjusts capacity automatically.

```bash
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name my-asg \
  --policy-name cpu-70-target \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 70.0
  }'
```

### Step Scaling

Define CloudWatch alarm thresholds that trigger specific capacity changes.

```
CPU > 50%  → Add 1 instance
CPU > 70%  → Add 2 instances
CPU > 90%  → Add 4 instances
```

### Scheduled Scaling

Anticipate predictable load patterns (e.g., business hours, end-of-month).

```bash
aws autoscaling put-scheduled-update-group-action \
  --auto-scaling-group-name my-asg \
  --scheduled-action-name scale-up-morning \
  --recurrence "0 8 * * MON-FRI" \
  --min-size 5 --max-size 20 --desired-capacity 10
```

## Health Checks

| Type | Checks | Replacement |
|------|--------|-------------|
| EC2 | Instance status only | After grace period |
| ELB | Instance + application health | Faster replacement |

Set `--health-check-type ELB` and `--health-check-grace-period` to give apps time to start before checks begin.

## Cooldown

The cooldown period is a fixed time (in seconds) after a scaling activity during which no new scaling activities are triggered. This prevents rapid oscillation (flapping).

- **Default Cooldown**: Applies to all scaling policies (default 300s)
- **Instance Warmup** (target tracking): Time for a new instance to contribute metrics

```bash
# Set instance warmup for a target tracking policy
--target-tracking-configuration '{
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ASGAverageCPUUtilization"
  },
  "TargetValue": 70.0,
  "ScaleInCooldown": 300,
  "ScaleOutCooldown": 60
}'
```

## Best Practices

1. Set min >= 2 for high availability across AZs
2. Use ELB health checks so unhealthy instances are replaced
3. Prefer target tracking over step scaling for simplicity
4. Use scheduled scaling for predictable traffic patterns
5. Set warmup periods to avoid premature scale-in

---

## Interview Q&A

**Q1: What is the difference between target tracking and step scaling?**
Target tracking automatically adjusts capacity to keep a metric at a target value — it's declarative and self-managing. Step scaling requires you to define CloudWatch alarms and specific capacity adjustments at each threshold — it's imperative and gives more fine-grained control. Target tracking is recommended for most use cases.

**Q2: Why is the health check grace period important?**
When a new instance launches, it needs time to boot, install software (via user data), and pass health checks. Without a grace period, the load balancer might mark the instance as unhealthy before it's ready, causing Auto Scaling to terminate and replace it repeatedly in a destructive loop.
