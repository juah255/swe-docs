# Testing and Reliability

Testing provides delivery confidence, while reliability practices keep systems dependable after release.

## Testing Tooling

- **Jest** is a testing framework.

## Tests in Delivery Pipelines

- Static analysis and linting
- Unit tests
- Integration tests
- End-to-end tests
- Contract tests
- Infrastructure validation
- Security scanning
- Performance, load, and stress testing
- Smoke tests after deployment

## Reliability Practices

- Health checks
- Timeouts, retries, and exponential backoff
- Circuit breakers
- Graceful degradation
- Redundancy and failover
- Backups and tested restoration
- Capacity planning
- Safe deployment and rollback procedures

## Incident Management

- Detection and triage
- Clear incident roles
- Communication and status updates
- Mitigation and recovery
- Blameless post-incident reviews
- Follow-up actions with owners

## Mid/Senior Interview Questions and Answers

### 1. Which tests should run on every pull request?

**Answer:** Pull requests should run fast tests that catch common regressions:
linting, type checks, unit tests, focused integration tests, build validation,
and relevant security checks.

Long end-to-end, load, or soak tests usually run on schedules, staging
deployments, or release candidates unless the system is small enough to keep
them fast and reliable.

### 2. How do load, stress, and soak tests differ?

**Answer:** Load tests verify behavior under expected traffic. Stress tests push
the system beyond expected limits to find failure points. Soak tests run for a
long time to reveal leaks, resource exhaustion, or degradation.

Good performance testing uses production-like data, realistic traffic patterns,
and clear success criteria.

### 3. What should a health check verify?

**Answer:** A health check should verify that the process can serve traffic and
that critical dependencies are available enough for the check's purpose.

Use different checks for different purposes. A liveness check should be simple
and avoid restarting healthy-but-degraded services. A readiness check can verify
dependencies needed before receiving traffic.

### 4. How do `RTO` and `RPO` guide disaster recovery?

**Answer:** `RTO` is the maximum acceptable time to restore service. `RPO` is
the maximum acceptable data loss window.

Low RTO requires faster failover and practiced recovery. Low RPO requires more
frequent backups, replication, or synchronous durability guarantees.
