# Caching, Performance, and Resilience

Optimize from measurements, not framework folklore. Establish request latency,
allocation rate, garbage collection, CPU, thread pools, connection pools, SQL,
cache hit rate, and downstream latency before changing architecture.

## Spring Cache

Spring's cache abstraction applies caching through interceptors:

```java
@Cacheable(cacheNames = "products", key = "#id")
public ProductView getProduct(UUID id) {
    return repository.fetchView(id)
        .orElseThrow(() -> new ProductNotFound(id));
}

@CacheEvict(cacheNames = "products", key = "#id")
public void updateProduct(UUID id, UpdateProduct command) {
    // update through a transactional application service
}
```

The annotations are commonly proxy-based, so self-invocation can bypass them.
Select and configure a real cache provider for production; the abstraction does
not turn an in-memory map into a coherent distributed cache.

A safe cache design specifies:

- every input represented in the key, including tenant and permission scope;
- lifetime and invalidation ownership;
- behavior for missing values and failures;
- serialization and schema evolution;
- maximum size and eviction policy;
- protection against stampedes.

Evict after a successful commit when the cached result depends on transactional
data. Caches improve latency but add another state consistency problem.

## Database Performance

Inspect generated SQL and query plans. Eliminate N+1 access, paginate collections,
fetch only required columns or relationships, and build indexes around actual
filters and ordering. Monitor pool wait time and database lock contention.

An oversized connection pool can overload the database and increase tail
latency. Budget connections across every web replica, worker, migration job, and
administrative tool.

## Timeouts and Retries

Every remote call should have explicit connect and response deadlines. Bound the
total request budget across retries and downstream calls.

Retry only transient failures and only when the operation is idempotent or uses
an idempotency key. Use exponential backoff with jitter. Layered retries in an
HTTP client, service, queue, and proxy can multiply load during an outage.

## Circuit Breakers and Bulkheads

A circuit breaker can stop repeated calls to a failing dependency and probe for
recovery. It does not repair the dependency and needs a meaningful fallback or
error path.

Bulkheads isolate resources so one dependency cannot consume every thread,
connection, or queue slot. Configure small, observable boundaries and reject
work predictably when saturated.

Rate limits protect capacity and policy boundaries. Apply them at the gateway
and, when needed, at a domain-aware application layer. Decide whether limits are
per identity, tenant, token, route, or expensive operation.

## JVM and Application Profiling

Use Java Flight Recorder, allocation profiling, thread dumps, heap dumps, and
continuous metrics to diagnose evidence. Common problems include:

- blocking or lock contention;
- unbounded collections and queues;
- excessive serialization or logging;
- connection pool starvation;
- large persistence contexts;
- cache retention and class-loader leaks;
- too many application replicas for the database budget.

Tune garbage collection and heap only after understanding allocation and live
data. A larger heap can postpone a memory problem while lengthening recovery.

## Load and Failure Testing

Test realistic payloads, data volume, concurrency, and dependency latency.
Measure tail percentiles and resource saturation, not only average throughput.
Exercise timeouts, partial failures, broker lag, database failover, and graceful
shutdown to verify resilience behavior under stress.

