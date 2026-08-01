# Defense in Depth

Defense in depth means protecting a system with multiple independent layers
so that a failure in one layer does not expose the system.

## Layers

- Network: firewalls, ACLs, segmentation.
- Host: patching, hardening, endpoint protection.
- Application: input validation, authorization, safe rendering.
- Data: encryption, hashing, backups, least privilege.
- Human: training, reviews, separation of duties.

## Example: Protecting a Database

- Network ACLs restrict which hosts can reach the database.
- The database account has least privilege and no unnecessary grants.
- Parameterized queries prevent SQL injection from reaching the database.
- Monitoring alerts on unusual access patterns.

## Why Layers Must Not Share a Weakness

- Layers that share the same weakness fail together, defeating the model.
- For example, encrypting data in transit does not help if the same key
  also protects data at rest and is exposed.
- Independent layers force an attacker to defeat several different
  controls instead of one.

Related: [Security Principles](security-principles.md),
[Zero Trust](zero-trust.md).
