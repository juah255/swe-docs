# Testing and Code Quality

A strong JavaScript test suite verifies behavior at the right boundary and
controls sources of nondeterminism. Tooling should make unsafe patterns visible
before code reaches production.

## Test Layers

| Layer | Purpose | Typical dependencies |
| --- | --- | --- |
| Unit | Verify business behavior quickly | Plain values, fakes, and controlled clocks |
| Integration | Verify adapters and infrastructure contracts | Real database, broker, filesystem, or service sandbox |
| End-to-end | Verify a critical flow through the public interface | Complete application stack |

Use the narrowest test that can prove the behavior. A mocked repository cannot
prove that a query, schema constraint, or transaction works.

## A Focused Test

The built-in Node.js test runner can express a small unit test without global
state:

```js
import assert from "node:assert/strict";
import { test } from "node:test";

test("debit keeps the balance unchanged when funds are insufficient", () => {
  const account = new Account({ balance: 25 });

  assert.throws(() => account.debit(30), InsufficientFundsError);
  assert.equal(account.balance, 25);
});
```

Other test frameworks provide additional runners, matchers, mocks, and browser
support. Pick one primary toolchain and keep its conventions consistent.

## Dependency Control

Construct services with explicit dependencies:

```js
const service = createUserService({
  users: new InMemoryUserRepository(),
  clock: { now: () => new Date("2030-01-01T00:00:00Z") },
  ids: { next: () => "user-123" },
});
```

This is clearer than modifying module globals. Use:

- **fakes** for lightweight working implementations;
- **stubs** for controlled responses;
- **spies or mocks** when the interaction itself is the behavior.

Excessive call assertions couple tests to implementation details. Prefer
observable output and state when possible.

## Async Tests

Return or await the promise under test so the runner owns its completion:

```js
test("loads a user", async () => {
  const user = await service.load("user-123");
  assert.equal(user.email, "reader@example.com");
});
```

A test that starts async work without awaiting it can pass before assertions or
rejections occur. Close servers, pools, streams, and background tasks after each
test; leaked handles make suites hang or interfere with later cases.

## Time, Timers, and Randomness

Inject a clock for domain decisions. Use fake timers only where timer scheduling
itself is under test, and restore them reliably.

Avoid real sleeps. They make tests slow and sensitive to machine load. Give
randomized tests a reproducible seed and report it when a failure occurs.

## Database and API Tests

Use the production database engine for SQL, transaction, constraint, and locking
behavior. Each test should start from known data and clean up independently of
execution order.

For outgoing HTTP, use a controlled local server or adapter fake. Do not let the
default test suite depend on the public internet. Verify timeout, cancellation,
malformed response, and partial-failure paths in addition to success.

## Static Quality Checks

JavaScript projects benefit from:

- a formatter for consistent syntax;
- a linter for unsafe patterns and likely mistakes;
- TypeScript checking or `checkJs` with JSDoc when static analysis is desired;
- dependency, license, and secret scanning;
- tests against every supported Node.js runtime;
- a reproducible package or container build.

Useful lint rules catch floating promises, accidental coercion, unreachable
code, unused values, and unsafe equality. Choose rules that prevent real defects
rather than creating noisy style debates.

## Stable Test Design

- Do not depend on test order or shared mutable module state.
- Assert meaningful behavior, not every internal call.
- Await all asynchronous work.
- Control time, randomness, network, and identifiers.
- Test errors, cancellation, cleanup, and duplicate delivery.
- Keep fixture data small and relevant to the scenario.
- Make failures show the important input and expected outcome.

Coverage indicates executed code, not correct behavior. Use it to find blind
spots, while prioritizing tests around business risk and production failures.
