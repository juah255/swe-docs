# Testing and Quality

A useful Django test suite checks domain behavior, database integration, HTTP
contracts, authorization, and operational configuration. Test the boundaries
where Django provides behavior instead of mocking all of them away.

## Test Layers

- Plain unit tests for calculations, policies, and state transitions.
- Model and service tests for constraints, queries, and transactions.
- View or API tests for routing, validation, permissions, and responses.
- Browser tests for a small number of critical user journeys.
- Deployment checks and smoke tests for configuration and dependencies.

## `TestCase` and `TransactionTestCase`

`django.test.TestCase` isolates tests efficiently using transactions and is the
default for most database tests.

```python
from django.test import TestCase


class OrderTests(TestCase):
    def test_customer_cannot_read_another_customers_order(self):
        response = self.client.get(self.other_customers_order.get_absolute_url())
        self.assertEqual(response.status_code, 404)
```

Use `TransactionTestCase` when the behavior itself depends on real commits,
rollbacks, locking, or transaction boundaries. It is slower because it must
reset database state differently.

Be careful when testing `transaction.on_commit()` under `TestCase`, because its
outer test transaction does not normally commit. Use Django's callback capture
helper or an appropriate transactional test.

## HTTP Test Tools

The test client exercises URL routing, middleware, views, templates, and
responses without a live server. `AsyncClient` supports async request tests.
`RequestFactory` creates request objects for testing a view in isolation, but it
does not run middleware automatically.

DRF provides request factories and API clients with convenient format and
authentication support. Assert the response contract, not every internal call.

## Factories and Fixtures

Create only the data a test needs. Factories are often easier to compose than a
large shared fixture, while data migrations may still benefit from small,
versioned fixtures. Use `setUpTestData()` for class-level data that need not be
rebuilt for every `TestCase` method.

Avoid depending on primary key sequences or test execution order. Freeze or
inject time where time affects behavior.

## Query and Configuration Tests

Guard important list pages and API endpoints against N+1 regressions:

```python
with self.assertNumQueries(3):
    response = self.client.get("/orders/")
    self.assertEqual(response.status_code, 200)
```

Use query assertions thoughtfully; harmless framework changes can make overly
broad counts brittle. Focus on stable hot paths and inspect unexpected queries.

`override_settings()` and `modify_settings()` isolate configuration changes.
Test custom system checks and run `manage.py check --deploy` against production
settings in delivery automation.

## External Systems and Tasks

At unit boundaries, fake email, payment, storage, and HTTP clients. Add focused
integration tests against realistic implementations for serialization,
timeouts, and error behavior. Never make ordinary unit tests depend on the
public internet.

For tasks, test the task function as application code and separately test that
the correct task is enqueued after commit. An immediate test backend is useful,
but it may hide serialization, worker configuration, retry, and concurrency
problems that only an integration test exposes.

## High-Value Cases

Test database constraints, invalid input, anonymous access, cross-tenant access,
duplicate submissions, retry behavior, concurrent state transitions, file-size
limits, and safe error responses. Coverage is a signal, not a substitute for
choosing meaningful failure modes.

