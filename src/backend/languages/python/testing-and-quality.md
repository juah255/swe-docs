# Testing and Code Quality

A reliable Python test suite gives quick feedback on business logic and focused
confidence at system boundaries. Test behavior that matters rather than
implementation details that make refactoring expensive.

## Test Layers

| Layer | Purpose | Typical dependencies |
| --- | --- | --- |
| Unit | Verify isolated business behavior quickly | In-memory values and small fakes |
| Integration | Verify adapters and infrastructure contracts | Real database, broker, file system, or service sandbox |
| End-to-end | Verify a critical user flow through the deployed interface | Full application stack |

Use many fast tests and a smaller number of expensive integration and
end-to-end tests. A unit test cannot prove that an ORM mapping or SQL migration
works; use the narrowest realistic test that can catch the failure.

## A Clear Pytest Test

```py
from decimal import Decimal


def test_transfer_rejects_insufficient_funds() -> None:
    account = Account(balance=Decimal("25.00"))

    with pytest.raises(InsufficientFunds):
        account.debit(Decimal("30.00"))

    assert account.balance == Decimal("25.00")
```

The test name describes the behavior, and the assertion checks both the error
and the important state after failure.

## Fixtures

Fixtures are useful for reusable setup and cleanup:

```py
@pytest.fixture
def saved_user(database: Database) -> Iterator[User]:
    user = database.users.create(email="reader@example.com")
    yield user
    database.users.delete(user.id)
```

Keep fixtures local and explicit. Large chains of automatic fixtures hide how a
test is constructed and make failures harder to diagnose. Prefer factories when
tests need many variations of the same model.

## Fakes, Stubs, and Mocks

- A **fake** is a lightweight working implementation, such as an in-memory
  repository.
- A **stub** returns controlled values for a test.
- A **mock** records interactions and supports expectations about calls.

Mock network, time, randomness, and other nondeterministic boundaries—not every
internal function. Patch the name used by the code under test, which may differ
from the module where the object was originally defined.

Excessive interaction assertions couple tests to implementation. When
possible, assert the returned value or externally visible state.

## Database Tests

Use the same database engine as production for behavior that depends on SQL,
transactions, constraints, or indexes. Lightweight substitutes can differ in
locking, types, and query behavior.

Each test must start from a known state. Transaction rollback is fast, but it
may hide commit-time behavior; use explicit cleanup or isolated databases for
tests that need real commit boundaries.

## Async Tests

Async tests need an event-loop-aware test plugin or runner. Await the operation
under test and clean up tasks, clients, and pools. A test that leaves background
tasks running can become flaky and can leak state into later tests.

Control time explicitly when testing retries, expiration, or scheduled work.
Sleeping in a test makes it both slow and sensitive to machine load.

## Stable Test Design

- Do not depend on test execution order.
- Avoid real internet access in the default suite.
- Give random data a reproducible seed and print it on failure.
- Freeze or inject time instead of racing the clock.
- Keep shared mutable state out of module-level fixtures.
- Test error paths, cancellation, and cleanup—not only success.
- Make failures show the relevant input and expected behavior.

## Automated Quality Checks

A typical continuous-integration pipeline runs:

1. a formatter check;
2. a linter;
3. a static type checker;
4. unit and integration tests;
5. dependency and security checks;
6. a package or container build.

Coverage shows which lines executed, not whether behavior is correct. Use it to
find untested areas, but do not treat a percentage as the quality goal.

## Testing Production Concerns

High-value service tests also verify:

- request validation and error responses;
- authentication and authorization boundaries;
- database rollback and idempotency;
- external-call timeouts and retries;
- rate and size limits;
- graceful shutdown of in-flight work;
- migrations against production-like data.

The best suite makes safe changes routine and catches failures near the layer
that owns them.
