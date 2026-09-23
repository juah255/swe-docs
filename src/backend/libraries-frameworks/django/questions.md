# Django Questions

These questions are useful for review and interviews. Strong answers explain
trade-offs and failure modes instead of only naming an API.

## 1. What is the difference between a Django project and an app?

A project is the deployed configuration and root application. An app is a
focused Python package that owns a capability and can potentially be reused.
Apps should follow domain boundaries, not be created mechanically per model.

## 2. When is a QuerySet evaluated?

Chaining most queryset methods only constructs a query. Iteration, conversion to
a list, length or truth testing, serialization, and other consuming operations
can execute it. Evaluation location matters because a loop or template can turn
one intended query into repeated work.

## 3. How do `select_related()` and `prefetch_related()` differ?

`select_related()` joins single-valued foreign-key or one-to-one relationships in
one SQL query. `prefetch_related()` issues additional queries and joins results
in Python, so it supports many-valued relationships. Both should be chosen from
the access pattern and measured query behavior.

## 4. When should a rule be a database constraint?

Use a database constraint when invalid persisted state must be impossible across
all write paths and concurrent requests. Form or serializer validation provides
better messages, but it can be bypassed and may race. Many systems use both.

## 5. What does `transaction.atomic()` guarantee?

It creates a transaction or nested savepoint so database work in the block can
commit or roll back together. It does not automatically make remote calls
transactional, prevent every race, or choose the correct locking strategy.

## 6. Why use `transaction.on_commit()`?

It delays a callback until the surrounding transaction commits. This prevents a
task or email from observing a row that later rolls back. It is not itself a
durable message queue; critical event delivery may require an outbox.

## 7. How should a zero-downtime schema change be deployed?

Expand the schema compatibly, deploy code that can handle old and new forms,
backfill in bounded batches, switch reads, enforce final constraints, and only
then contract the old schema. Application and worker versions overlap during a
rolling release.

## 8. What is dangerous about Django signals?

Signals make control flow implicit, may run inside a transaction, can be
registered more than once, and are easy to miss during bulk operations. Use
explicit services for critical workflows and reserve signals for decoupled
integration behavior with clear tests.

## 9. Function-based or class-based views?

Function views are direct and easy to trace. Class-based views provide reusable
dispatch, generic CRUD behavior, and mixins. Choose whichever produces the
clearest local control flow; deep inheritance is not automatically better reuse.

## 10. What is the role of middleware?

Middleware wraps request and response processing for cross-cutting concerns. Its
order is significant, it may short-circuit requests, and it can be sync, async,
or dual-capable. Domain and object authorization usually belong closer to the
operation rather than in global middleware.

## 11. When does an async Django view help?

It helps under ASGI when the request waits on async-compatible I/O and the
middleware and libraries do not force synchronous adaptation. It does not speed
up CPU-bound work, and blocking calls still block execution.

## 12. Can an async view use transactions normally?

Not directly in current Django async mode. Put the transaction and synchronous
ORM work in one sync function and call it with `sync_to_async()`. Avoid splitting
one transaction across several boundary crossings.

## 13. Does Django's Tasks framework run workers?

No. In Django 6.0+, it defines task and queue interfaces and hands work to a
configured backend. Production execution still requires suitable external
infrastructure. Its built-in backends are intended for development and testing.

## 14. How do you prevent DRF authorization leaks?

Require authentication as appropriate, scope the base queryset to the caller,
apply request and object permissions, and derive ownership or tenant fields from
trusted context. Test cross-user and cross-tenant access for list and detail
routes.

## 15. How do you avoid N+1 queries in a serializer?

Inspect the fields and nested relationships the serializer accesses, then shape
the view queryset with appropriate joins, prefetches, and annotations. Add a
query-count regression test for important endpoints. DRF does not optimize this
automatically.

## 16. What makes a safe cache key?

It includes every input that can change the result, such as object version,
tenant, locale, user or permission scope, and feature version. It also has an
expiry or invalidation strategy. Missing a privacy dimension can leak data.

## 17. `TestCase` or `TransactionTestCase`?

Use `TestCase` for most database tests because its transaction-based isolation
is fast. Use `TransactionTestCase` when the code under test depends on actual
commit, rollback, locking, or transaction visibility behavior.

## 18. Why is `DEBUG=False` insufficient for production security?

Production also requires correct hosts, TLS, cookie policy, secret handling,
proxy trust, CSRF, authorization, request limits, supported dependencies,
logging hygiene, and infrastructure controls. Run deployment checks, but treat
them as a baseline rather than a complete audit.

## 19. How should a Django application be scaled?

First measure the bottleneck. Then tune queries and indexes, cache suitable
results, bound external I/O, size web and worker processes against connection
budgets, move durable work to queues, and scale stateless processes horizontally.
Adding workers without database capacity can reduce reliability.

## 20. When is Django a good choice?

Django fits products that benefit from an integrated ORM, migrations, auth,
admin, forms, templates, and mature conventions. A smaller framework may be
preferable for a narrowly scoped service, but framework choice should follow the
domain, team, ecosystem, and operational needs rather than a benchmark alone.

