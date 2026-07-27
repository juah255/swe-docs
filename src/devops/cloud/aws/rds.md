# Amazon RDS

## What Is RDS?

Relational Database Service (RDS) is a managed SQL database that handles provisioning, patching, backups, and replication. You focus on queries, not infrastructure.

## Supported Engines

| Engine | Versions |
|--------|----------|
| Amazon Aurora | MySQL & PostgreSQL compatible |
| PostgreSQL | 12–16 |
| MySQL | 5.7, 8.0 |
| MariaDB | 10.x |
| Oracle | 19c, 21c |
| SQL Server | 2019, 2022 |

**Aurora** provides up to 5x throughput over MySQL and 3x over PostgreSQL with auto-scaling storage.

## Multi-AZ vs Read Replicas

| Feature | Multi-AZ | Read Replicas |
|---------|----------|---------------|
| Purpose | High availability | Read scaling |
| Sync | Synchronous (automatic failover) | Asynchronous replication |
| Standby writes | No | No |
| Use case | Production HA | Reporting, analytics |

```bash
# Create Multi-AZ instance
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --db-instance-class db.r5.large \
  --engine aurora-mysql \
  --master-username admin \
  --master-user-password secret123 \
  --multi-az \
  --allocated-storage 100

# Create a read replica
aws rds create-db-instance-read-replica \
  --db-instance-identifier mydb-replica-1 \
  --source-db-instance-identifier mydb \
  --db-instance-class db.r5.large
```

## Automated Backups

- Enabled by default; set retention from 1 to 35 days
- Backs up during the daily backup window
- Includes transaction logs for point-in-time recovery (PITR)
- Can restore to any second within the retention window

```bash
# Modify backup retention
aws rds modify-db-instance \
  --db-instance-identifier mydb \
  --backup-retention-period 14
```

## Snapshots

Manual backups that persist until explicitly deleted. Useful before major changes.

```bash
# Create a snapshot
aws rds create-db-snapshot \
  --db-instance-identifier mydb \
  --db-snapshot-identifier mydb-before-upgrade

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier mydb-restored \
  --db-snapshot-identifier mydb-before-upgrade
```

## Parameter Groups

Database engine configuration as code. Control memory allocation, connection limits, log settings, and more.

```bash
# Create a custom parameter group
aws rds create-db-parameter-group \
  --db-parameter-group-family aurora-mysql8.0 \
  --db-parameter-group-name my-params \
  --description "Custom Aurora parameters"

# Set a parameter
aws rds modify-db-parameter-group \
  --db-parameter-group-name my-params \
  --parameters "ParameterName=max_connections,ParameterValue=500,ApplyMethod=pending-reboot"

# Apply to instance
aws rds modify-db-instance \
  --db-instance-identifier mydb \
  --db-parameter-group-name my-params \
  --apply-immediately
```

## IAM Authentication

Authenticate to RDS using IAM credentials instead of passwords. Uses `aws_iam_auth` plugin.

```sql
-- Create a database user for IAM auth
CREATE USER 'app_user' IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS';
GRANT SELECT ON mydb.* TO 'app_user'@'%';
```

```python
import boto3

token = client.generate_db_auth_token(
    DBHostname='mydb.abc123.us-east-1.rds.amazonaws.com',
    Port=3306,
    DBUsername='app_user'
)
# Use token as password in DB connection
```

Benefits: no hardcoded passwords, automatic credential rotation via IAM.

---

## Interview Q&A

**Q1: When should you choose Aurora over standard RDS MySQL?**
Choose Aurora when you need higher throughput (up to 5x MySQL), auto-scaling storage (up to 128 TB), faster failover (typically 30 seconds), or better durability (6 copies across 3 AZs). Standard RDS MySQL is simpler and cheaper for smaller workloads where Aurora's performance isn't needed.

**Q2: What happens during a Multi-AZ failover?**
AWS detects the primary is unhealthy (via health checks), promotes the standby to primary, and updates the DNS endpoint to point to the new primary. The entire process typically takes 60–120 seconds. Your application reconnects using the same DNS name with no manual intervention. Writes fail during the brief failover window.
