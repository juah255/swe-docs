# Testing

Backend testing verifies business rules, API contracts, persistence,
integrations, and operational behavior. A useful test suite gives fast feedback
for common changes while retaining enough real-system coverage to catch wiring
and infrastructure problems.

## Testing Levels

### Unit Tests

Unit tests exercise a small piece of logic without real databases, networks, or
filesystems. They are best for calculations, validation, state transitions, and
domain rules.

```python
def test_order_cannot_exceed_available_stock():
    product = Product(stock=2)

    with pytest.raises(InsufficientStock):
        product.reserve(quantity=3)
```

Unit tests should be deterministic and fast enough to run on every change.

### Integration Tests

Integration tests verify that components work with real infrastructure or
realistic substitutes. Examples include repository tests against PostgreSQL,
cache tests against Redis, and message publication through a broker.

Use the same database engine as production when behavior depends on SQL,
constraints, transactions, indexes, or isolation levels. SQLite is not a full
substitute for PostgreSQL or MySQL.

### API Tests

API tests call the application through its HTTP boundary and verify routing,
validation, authentication, serialization, status codes, headers, and error
formats.

```python
def test_create_order(client, user_token):
    response = client.post(
        "/orders",
        headers={"Authorization": f"Bearer {user_token}"},
        json={"product_id": 42, "quantity": 2},
    )

    assert response.status_code == 201
    assert response.json()["status"] == "pending"
    assert response.headers["location"].startswith("/orders/")
```

### End-to-End Tests

End-to-end tests run a deployed application with real dependencies and exercise
complete workflows. They provide high confidence but are slower and harder to
diagnose. Keep them focused on critical paths such as registration, checkout,
and payment recovery.

### Contract Tests

Contract tests verify that service consumers and providers agree on request,
response, and event schemas. They catch incompatible changes without requiring
every service to run in one large test environment.

OpenAPI schema checks, consumer-driven contracts, and event schema validation
are common approaches.

## What to Test

For each behavior, consider:

- Happy path
- Boundary values and empty input
- Invalid and malformed input
- Missing, expired, and incorrect credentials
- Allowed and forbidden roles or ownership
- Dependency timeout and failure
- Duplicate requests and retries
- Concurrent updates
- Transaction rollback
- Pagination boundaries
- Data isolation between tenants

Focus assertions on observable behavior. Tests coupled to private methods or
internal call order become brittle during harmless refactoring.

## Test Doubles

- **Stub:** returns a controlled response
- **Fake:** working lightweight implementation, such as an in-memory repository
- **Mock:** verifies expected interactions
- **Spy:** records calls while retaining some or all real behavior

Use test doubles at boundaries you own. Excessive mocking can create tests that
pass even though the assembled application fails.

Patch a dependency where the system under test looks it up, not necessarily
where the dependency was originally defined.

## Database Testing

Database tests should verify:

- Migrations apply successfully from a supported starting version
- Constraints reject invalid or duplicate data
- Transactions commit and roll back correctly
- Queries return correct results and ordering
- Tenant and authorization filters cannot be omitted
- Important queries use suitable indexes at realistic scale

Each test needs isolation. Common strategies are transaction rollback, schema
recreation, table truncation, or a disposable database container. Parallel tests
must not share mutable records unless that is the behavior under test.

Avoid fixed IDs and assumptions about test execution order.

## Testing External Services

Unit and component tests should replace external APIs with controlled fakes or
HTTP stubs. Test success, timeout, rate limiting, malformed responses, and
partial failures.

A smaller set of integration tests can run against a provider sandbox. Sandbox
tests should not be the only coverage because they may be slow, unavailable, or
non-deterministic.

Record-and-replay tools can help, but recordings may contain secrets or become
stale when an API changes.

## Testing Asynchronous Jobs

Separate enqueue behavior from worker behavior:

1. Verify the API commits state and publishes the correct job.
2. Invoke the job handler directly with controlled dependencies.
3. Run integration tests against the real broker for acknowledgment and retry behavior.

Test duplicate delivery, retry exhaustion, dead-letter routing, and recovery
after a worker failure. Avoid tests that wait an arbitrary number of seconds;
poll a condition with a deadline or control the clock.

## Time and Randomness

Clock access and random ID generation should be injectable or controllable.
This makes expiration, scheduling, retry, and ordering tests deterministic.

```python
def test_token_is_expired(clock):
    token = issue_token(expires_at=clock.now() + timedelta(minutes=5))
    clock.advance(minutes=6)

    assert validate(token).is_expired
```

Freeze or inject time instead of adding real sleeps.

## Concurrency Tests

Concurrency bugs often pass ordinary tests. Add targeted tests for operations
such as inventory reservation, account balance updates, unique resource
creation, and job claiming.

Run competing operations at the same time and assert the final invariant. The
database should enforce critical guarantees with locks, isolation, or unique and
check constraints rather than relying only on application timing.

## Performance and Load Testing

Load tests answer questions such as:

- What throughput can the service sustain?
- How do p50, p95, and p99 latency change under load?
- Which dependency saturates first?
- Does the system recover after a traffic spike?
- Are rate limits and backpressure effective?

Use realistic data sizes and request mixes. A test against an empty database can
hide missing indexes and poor query plans.

Performance tests need explicit acceptance thresholds. A graph without a target
does not determine whether the result is acceptable.

## Security Testing

Automated security coverage should include:

- Authentication and authorization failures
- Cross-tenant access attempts
- Injection payloads and unsafe file paths
- Request body and upload limits
- Secret and sensitive-data exposure
- Dependency and container vulnerability scanning
- Abuse cases such as brute force and rate-limit bypass

Security scanners supplement tests but do not replace authorization and business
logic coverage.

## Test Data

Use factories or builders that provide valid defaults and make the important
differences explicit:

```python
order = order_factory(status="paid", tenant_id=tenant.id)
```

Do not use production personal data in test environments. Synthetic data should
preserve relevant shapes, edge cases, and volumes without exposing real users.

## Reliable Test Suites

A flaky test produces different results without a meaningful code change.
Common causes are shared state, real time, random ordering, external services,
race conditions, fixed ports, and missing cleanup.

Fix or quarantine flaky tests with an owner and deadline. Blind automatic
retries can hide real race conditions and teach the team to ignore failures.

Keep failure messages clear and preserve relevant logs or artifacts for CI
diagnosis.

## CI Strategy

A practical pipeline commonly runs:

1. Formatting, linting, type checking, and unit tests
2. Integration and API tests with disposable dependencies
3. Build, migration, contract, and security checks
4. Focused end-to-end and smoke tests against a deployed environment

Run independent checks in parallel. Cache dependencies carefully, but never
allow caches to make test results depend on a previous build.

Coverage is a diagnostic metric, not the goal. High line coverage can still miss
incorrect assertions, authorization gaps, concurrency failures, and missing
requirements.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between a unit test and an integration test?

**Answer:** A unit test isolates a small piece of logic and replaces external
boundaries. An integration test verifies real components working together, such
as repository code with the production database engine. The distinction is
about boundaries and dependencies, not only test speed.

### 2. Why can too much mocking be harmful?

**Answer:** Mocks can reproduce the implementation's assumptions instead of the
dependency's real behavior. A suite may pass while SQL, serialization,
transactions, or network integration is broken. Use mocks for controlled unit
tests and real dependencies for important integration contracts.

### 3. How do you test an operation that must be idempotent?

**Answer:** Send the same request concurrently and sequentially with the same
idempotency key. Assert that only one business effect exists and every response
refers to that result. Also verify that reusing the key with a different payload
is rejected.

### 4. How should a team respond to flaky tests?

**Answer:** Treat flakiness as a defect. Capture evidence, identify shared state,
timing, ordering, or environment assumptions, and fix the cause. Quarantine only
when necessary and keep ownership visible; do not normalize rerunning the suite
until it passes.
