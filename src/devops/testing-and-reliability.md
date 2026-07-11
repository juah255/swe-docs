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

## Test Types

### Unit tests

Unit tests verify a small piece of logic in isolation. They should be fast,
deterministic, and easy to run often.

Use them for:

- Pure functions
- Validation logic
- Branching and edge cases
- Small service methods with fake dependencies

### Integration tests

Integration tests verify that multiple parts work together, usually across real
boundaries such as a database, queue, cache, or external API stub.

Use them for:

- Repository behavior
- Database queries and transactions
- Request handlers and middleware
- Message publishing and consumption paths

Integration tests are slower than unit tests, but they catch wiring issues that
unit tests miss.

### End-to-end tests

End-to-end tests verify a user-facing flow through the system from the outside.
They exercise the app in a way that is close to production usage.

Use them for:

- Critical business journeys
- Authentication flows
- Checkout, signup, or onboarding paths
- Regression coverage for high-risk user journeys

Keep the set small. E2E tests are expensive, slower to debug, and should cover
the highest-value flows rather than every branch.

### Regression tests

Regression tests protect against a bug that already happened once. Once a bug is
fixed, capture it as a test so the same failure cannot quietly return.

Use them for:

- Production incidents
- Bug reports from QA or users
- Reproducible edge cases
- Changes to previously fragile behavior

Regression tests can be unit, integration, or end-to-end tests. The key point is
their purpose: they lock in a specific fix or guarantee.

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

Regression tests for recently fixed bugs should also run in the main pipeline if
they are cheap enough, because they are often the best protection against the
same issue reappearing.

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

### 5. Why keep end-to-end tests small?

**Answer:** E2E tests are valuable because they validate the system as a user
experiences it, but they are slower, more brittle, and harder to diagnose than
lower-level tests. A small focused suite gives confidence without making the
pipeline expensive or noisy.

The rest of the coverage should come from unit and integration tests, which are
better at pinpointing the exact failure.
