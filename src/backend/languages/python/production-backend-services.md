# Production Backend Services

A correct handler is only one part of a reliable service. Production quality
comes from explicit process behavior, bounded resources, observable failures,
and repeatable deployments.

## WSGI and ASGI

**WSGI** is the traditional interface between synchronous Python web
applications and servers. **ASGI** supports asynchronous request handling,
WebSockets, and application lifecycle events.

The interface does not make all application code asynchronous. A synchronous
database driver still blocks the executing thread, and an ASGI service can
still require multiple worker processes for capacity and fault isolation.

## Processes and Workers

Production servers commonly run several worker processes. Each process has its
own interpreter, GIL, heap, connection pools, and in-process caches.

Worker sizing depends on:

- available CPU and memory;
- the ratio of CPU work to I/O waits;
- per-worker connection-pool sizes;
- latency targets and expected concurrency;
- limits of databases and external services.

More workers are not always better. Multiplying workers also multiplies memory,
connections, and cache entries. Load test the complete configuration.

## Timeouts, Retries, and Idempotency

Set finite timeouts for database operations, cache access, and outgoing HTTP
calls. A missing timeout lets one dependency consume workers indefinitely.

Retry only failures that are likely to be transient. Use:

- a small attempt limit;
- exponential backoff;
- randomized jitter;
- a total deadline;
- idempotent operations or idempotency keys.

Retries amplify load during an outage. Do not retry validation failures or
permanent authorization errors, and avoid stacking retries at several layers.

## Connection Pools

Pools reuse expensive database and HTTP connections while placing a limit on
concurrency. Configure acquisition timeouts so callers fail predictably when a
pool is exhausted.

Capacity must be calculated across all processes and replicas:

```text
total possible database connections
    = replicas × workers per replica × pool size per worker
```

Leave room for migrations, administration, and other services instead of using
the database's full limit.

## Request Boundaries

At every request boundary:

- validate type, format, and size;
- authenticate identity and authorize the requested action;
- assign or propagate a request/trace identifier;
- enforce a deadline and cancellation where supported;
- avoid exposing internal exceptions or secrets in responses;
- make state-changing requests safe against duplicates where required.

Do not trust a model merely because it has type hints. External data requires
runtime validation.

## Background Work

Short, non-critical work may run after a response if the framework owns its
lifetime. Use a durable queue for work that must survive restarts, needs retries,
or takes significant time.

A production worker needs:

- bounded concurrency and queue depth;
- idempotent handlers;
- retry and dead-letter policies;
- visibility timeouts or acknowledgements;
- metrics for lag, attempts, failures, and processing time;
- a safe shutdown procedure.

## Observability

Emit structured logs with stable event names and fields. Include request or
trace IDs, but exclude passwords, tokens, sensitive personal data, and large
payloads.

Monitor at least:

- request rate, errors, and latency percentiles;
- worker restarts, CPU, and memory;
- event-loop lag for async services;
- database and HTTP pool saturation;
- dependency latency and timeout counts;
- queue depth, age, and failure rate.

Metrics reveal trends, logs explain individual events, and traces connect work
across service boundaries.

## Graceful Shutdown

When the process receives a termination signal, it should:

1. stop accepting new traffic or fail readiness;
2. allow in-flight requests to finish within a deadline;
3. stop consuming new background jobs;
4. close clients, pools, and telemetry exporters;
5. exit before the platform's hard-kill timeout.

Shutdown behavior should be tested. Without it, deployments can interrupt
transactions or deliver partial responses.

## Deployment Checklist

- Build an immutable, reproducible artifact.
- Run as a non-root user with only required permissions.
- Pin the Python runtime and resolved dependencies.
- Apply database migrations as a controlled step.
- Expose separate liveness and readiness signals.
- Configure request, server, and shutdown timeouts.
- Set CPU and memory requests or limits intentionally.
- Keep secrets out of the image and logs.
- Roll out gradually and watch error, latency, and saturation metrics.

Most performance incidents in Python services come from slow queries, blocking
I/O, unbounded concurrency, large in-memory data, exhausted pools, or poor
worker sizing—not from individual language expressions.
