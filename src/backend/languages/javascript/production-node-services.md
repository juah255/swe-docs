# Production Node.js Services

A production Node.js service needs bounded resources, explicit failure policy,
observable behavior, and clean process lifecycle management. The runtime makes
high concurrency possible, but the application must decide how much work is
safe.

## Processes and Capacity

A Node.js process normally runs application JavaScript on one main event-loop
thread. Run multiple processes or replicas to use multiple CPU cores and provide
failure isolation.

Capacity planning must include:

- CPU and memory per process;
- expected concurrent requests;
- database and HTTP pool sizes;
- downstream rate and connection limits;
- background work sharing the process;
- latency and event-loop-delay targets.

More processes also mean more pools, cache copies, sockets, and memory. Validate
the complete configuration with production-like load.

## Server Limits

Configure the HTTP server and framework deliberately:

- request, header, keep-alive, and shutdown timeouts;
- maximum header and request-body sizes;
- limits for uploads, form fields, and parsed JSON;
- connection and request concurrency where needed;
- proxy trust only for known network topology.

Reject oversized or malformed input early. A reverse proxy adds protection but
does not replace limits inside the application.

## Connection Pools

Database and outbound HTTP pools reuse connections and bound resource use. A
pool needs an acquisition timeout and saturation metrics.

Calculate database capacity across the deployment:

```text
possible database connections
    = replicas × processes per replica × pool size per process
```

Reserve capacity for migrations, administrators, and other applications.

## Security Boundaries

- Validate external values by type, shape, range, and size.
- Authenticate identity and authorize the specific resource and action.
- Avoid dynamic code execution and unsafe shell construction.
- Protect against prototype pollution when copying untrusted object keys.
- Set secure headers and cookie attributes appropriate to the interface.
- Keep dependencies and the Node.js runtime supported and patched.
- Store secrets outside source control and never include them in logs.

JSON parsing creates data, not trusted domain objects. Convert validated input
into application models before business logic relies on it.

## Observability

Use structured logs with stable event names and request or trace identifiers.
Record errors as error objects so stack and cause information remain available.

Monitor at least:

- request rate, errors, and latency percentiles;
- event-loop delay and event-loop utilization;
- CPU, memory, garbage collection, and process restarts;
- database and HTTP pool saturation;
- dependency latency and timeout counts;
- queue depth, age, retries, and dead-letter volume.

Metrics reveal trends, logs explain individual events, and traces connect calls
across service boundaries.

## Graceful Shutdown

Handle the platform's termination signal and give shutdown one clear owner:

1. fail readiness and stop accepting new work;
2. stop consuming new background jobs;
3. abort or finish in-flight operations within a deadline;
4. close HTTP servers, pools, clients, and telemetry exporters;
5. exit before the platform sends a hard-kill signal.

Force a non-zero exit if shutdown itself exceeds the deadline. A supervisor or
orchestrator should replace failed processes.

## Background Work

Do not start important fire-and-forget work inside a request handler. Use a
durable queue when work must survive restart, be retried, or take significant
time.

A worker should have bounded concurrency, idempotent handlers, retry and
dead-letter policies, acknowledgement rules, and graceful shutdown. Monitor
queue time separately from execution time.

## Health Signals

- **Liveness** answers whether the process should be restarted.
- **Readiness** answers whether the process should receive new traffic.

Readiness can fail during startup and draining. Avoid making liveness depend on
every downstream service; a database outage should not necessarily place every
application replica into a restart loop.

## Deployment Checklist

- Pin the supported Node.js runtime and resolved dependencies.
- Build one immutable artifact and promote it across environments.
- Run as a non-root user with only required permissions.
- Keep secrets outside the image.
- Apply migrations as a controlled, backward-compatible step.
- Configure timeouts, size limits, pool limits, and shutdown deadlines.
- Expose meaningful liveness and readiness endpoints.
- Roll out gradually while watching errors, latency, and saturation.
- Test startup, dependency failure, process signals, and shutdown behavior.

The most common production problems are slow dependencies, blocked event loops,
unbounded promises or queues, exhausted pools, large buffered payloads, and
missing timeout or cancellation paths.
