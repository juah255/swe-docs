# AWS Identity and Access Management (IAM)

## What Is IAM?

IAM controls who can do what on AWS resources. It's global (not region-specific) and free to use.

## Core Components

| Component | Description |
|-----------|-------------|
| **User** | An entity with credentials (console access, access keys) |
| **Group** | A collection of users that share the same permissions |
| **Role** | An identity assumed temporarily (by users, services, or accounts) |
| **Policy** | A JSON document defining allowed/denied actions on resources |

## Policy Structure

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

## Policy Types

| Type | Scope |
|------|-------|
| Identity-based | Attached to users, groups, or roles |
| Resource-based | Attached to resources (e.g., S3 bucket policies) |
| Permission boundaries | Maximum permissions an identity can have |
| SCPs | Organization-wide permission guardrails |
| Session policies | Limit permissions during role assumption |

## Policy Evaluation

1. Default **deny**
2. All policies are evaluated; **deny** always wins
3. Explicit deny overrides any allow
4. If no allow matches → implicit deny

```
Request → SCP → Permission Boundary → Identity Policy → Resource Policy → Decision
```

## Least Privilege

Grant only the permissions needed to perform a task. Start restrictive and add permissions as needed.

```bash
# Use IAM Access Advisor to find unused permissions
aws iam get-service-last-accessed-details \
  --arn arn:aws:iam::123456789012:user/alice
```

## Role Assumption

Roles provide temporary credentials via the Security Token Service (STS).

```bash
# Assume a role
aws sts assume-role \
  --role-arn arn:aws:iam::123456789012:role/my-role \
  --role-session-name my-session

# Use the returned credentials
export AWS_ACCESS_KEY_ID=ASIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
```

## Cross-Account Access

Share resources across AWS accounts without sharing credentials.

```bash
# Account A: Create a role that Account B can assume
aws iam create-role \
  --role-name cross-account-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::ACCOUNT_B_ID:root" },
      "Action": "sts:AssumeRole"
    }]
  }'

# Account B: Assume the role in Account A
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT_A_ID:role/cross-account-role \
  --role-session-name cross-account
```

## Best Practices

1. **Root account**: Enable MFA, use only for account-level tasks
2. **MFA**: Enforce on all human users, especially admin
3. **Roles over keys**: Use roles for services and cross-account; avoid long-lived access keys
4. **Rotate credentials**: Automated rotation for access keys
5. **Use groups**: Assign permissions to groups, not users directly
6. **Audit regularly**: CloudTrail + IAM Access Advisor + Access Analyzer

```bash
# Enable IAM Access Analyzer (finds externally shared resources)
aws iam create-access-analyzer \
  --analyzer-name my-analyzer \
  --scope-account
```

---

## Interview Q&A

**Q1: What is the difference between an IAM role and an IAM user?**
An IAM user has long-term credentials (password, access keys) and represents a person or application. An IAM role has no permanent credentials — it's assumed temporarily via STS, and the caller receives short-lived temporary credentials. Roles are preferred for EC2 instances, Lambda functions, cross-account access, and federated identities because they eliminate hardcoded credentials.

**Q2: How does policy evaluation work when multiple policies apply?**
Policies are additive — permissions from all applicable policies are unioned. However, an explicit **Deny** in any policy always overrides all **Allow** statements. The evaluation flow: SCPs → permission boundaries → identity-based policies → resource-based policies. If any layer explicitly denies, the request is denied. If no policy explicitly allows, the request is implicitly denied.
