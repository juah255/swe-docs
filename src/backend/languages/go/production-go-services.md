# Production Go Services

A production Go service needs deliberate HTTP behavior, bounded resources,
observable failures, and a clean process lifecycle. Compilation into one binary
simplifies delivery but does not remove runtime or deployment concerns.

## HTTP Server Configuration

Configure a server explicitly instead of relying on package-level convenience
functions for a public service:

```go
server := &http.Server{
    Addr:              config.Address,
    Handler:           routes,
    ReadHeaderTimeout: 5 * time.Second,
    ReadTimeout:       15 * time.Second,
    WriteTimeout:      30 * time.Second,
    IdleTimeout:       60 * time.Second,
}
```

Choose values from real request and streaming behavior. A write timeout suitable
for JSON responses may be wrong for long-lived streaming. Limit request bodies
before decoding and apply route-specific application deadlines where needed.

## HTTP Clients

Reuse a configured `http.Client` and transport so connections can be pooled.
Creating a new transport per request prevents effective reuse.

Set finite deadlines, propagate request contexts, check status codes, and close
response bodies:

```go
request, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
if err != nil {
    return Result{}, err
}

response, err := client.Do(request)
if err != nil {
    return Result{}, err
}
defer response.Body.Close()
```

Read or stream the body with a size limit. For small discarded responses, fully
consuming the body may allow connection reuse; never read an untrusted unlimited
body only for that purpose.

## Database Pools

`database/sql` manages a pool. Configure maximum open and idle connections,
connection lifetime, and acquisition behavior based on database capacity and
load tests.

Calculate capacity across the full deployment:

```text
possible connections = replicas × maximum open connections per replica
```

Reserve database capacity for migrations, administration, and other services.
Monitor pool wait time and saturation, not only query duration.

## Timeouts, Retries, and Idempotency

Every network or storage call needs a finite deadline. Derive child deadlines
from the request context and leave time for cleanup and response writing.

Retry only transient failures when the operation is idempotent or protected by
an idempotency key. Use a small attempt limit, exponential backoff, jitter, and
a total deadline. Avoid layered retries that multiply attempts during an outage.

## Request Boundaries

- Limit headers and bodies before expensive parsing.
- Decode strictly enough for the public contract.
- Validate types, formats, ranges, and cross-field rules.
- Authenticate identity and authorize the resource and action.
- Propagate request and trace identifiers.
- Return stable public errors without internal implementation detail.

Struct tags guide encoders; they do not validate domain rules automatically.

## Observability

Use structured logs with stable field names. Pass a request-scoped logger or
fields deliberately rather than storing mutable request context globally.

Monitor at least:

- request rate, errors, and latency percentiles;
- CPU, heap, allocation rate, and garbage collection;
- goroutine count and scheduler pressure;
- database and HTTP pool saturation;
- dependency latency and timeout counts;
- queue depth, age, retries, and failures;
- process restarts and shutdown duration.

Expose profiling endpoints only through protected operational access. Profiles
can reveal sensitive data and consume resources.

## Graceful Shutdown

Use signal-aware context cancellation and a bounded shutdown deadline:

```go
shutdownCtx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
defer cancel()

if err := server.Shutdown(shutdownCtx); err != nil {
    return fmt.Errorf("shutdown HTTP server: %w", err)
}
```

A complete shutdown sequence should:

1. fail readiness and stop accepting new traffic;
2. stop consuming new jobs;
3. let in-flight work finish or cancel it within a deadline;
4. close clients, pools, listeners, and telemetry exporters;
5. exit before the platform's hard-kill timeout.

Test process signals and forced deadlines with the built binary.

## Health Signals

- **Liveness** indicates whether the process should be restarted.
- **Readiness** indicates whether it should receive new work.

Readiness may depend on completed initialization and draining state. Avoid making
liveness depend on every downstream service, which can cause restart loops
during an external outage.

## Security and Configuration

- Parse configuration once and fail safely on invalid values.
- Keep credentials in a secret manager and out of logs.
- Run with minimal operating-system and network permissions.
- Use TLS at the service or trusted proxy boundary.
- Keep the Go toolchain and dependencies supported and patched.
- Avoid unsafe shell construction and path handling.
- Apply authentication, authorization, rate, and size limits at explicit
  boundaries.

## Deployment Checklist

- Produce a reproducible binary for the target platform.
- Include required certificates, time-zone data, migrations, and templates.
- Run as a non-root user in a minimal runtime image when containerized.
- Record build version and revision for diagnostics.
- Apply backward-compatible migrations as a controlled step.
- Configure CPU, memory, pools, timeouts, and shutdown deadlines.
- Expose liveness, readiness, metrics, and protected diagnostics.
- Roll out gradually while watching errors, latency, and saturation.

Most production incidents come from slow dependencies, missing deadlines,
unbounded goroutines or queues, pool exhaustion, data races, and incomplete
shutdown—not from Go syntax itself.
