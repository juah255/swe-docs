# Production and Deployment

A reliable Spring Boot deployment treats the application, JVM, database,
brokers, configuration, and delivery process as one operating system.

## Packaging Choices

An executable JAR is the common JVM deployment unit. Container images can be
built with Boot's build plugin or a controlled Dockerfile. Layer application
classes separately from stable dependencies to improve rebuild and transfer
time.

GraalVM native images can reduce startup time and memory footprint for suitable
workloads, with trade-offs in build time, closed-world analysis, dynamic
features, debugging, and peak behavior. Benchmark the real service rather than
assuming JVM or native is universally better.

## Container Runtime

Set resource requests and limits from measurements. Modern JVMs understand
container constraints, but the heap is only part of process memory; account for
metaspace, code cache, direct buffers, thread stacks, native libraries, and
observability agents.

Run as a non-root user, use a minimal maintained base image, make the filesystem
read-only where possible, and keep credentials out of layers and command-line
arguments.

## Graceful Shutdown

On termination, stop accepting traffic, allow bounded in-flight work to finish,
and close server, consumer, executor, and client resources. Align application
grace periods with the platform's termination deadline.

Message consumers may need to stop polling before completing current records.
Scheduled work and `@Async` tasks need an explicit shutdown policy. Test shutdown
during active requests and processing rather than relying on defaults.

## Deployment Sequence

1. Build one immutable artifact from locked, reviewed dependencies.
2. Run tests, dependency checks, and configuration validation.
3. Apply backward-compatible database migrations through one controlled job.
4. Roll out a small number of instances and verify health and key signals.
5. Continue gradually while observing errors, latency, saturation, and queues.
6. Retain a rollback path compatible with the migrated schema.

Do not let every replica independently run schema migrations at startup. During
a rolling release, old and new web and worker versions coexist, and queued
messages may have been produced by the previous version.

## Configuration and Proxy Boundaries

Promote the same artifact between environments and inject runtime configuration.
Validate trusted proxy settings before accepting forwarded host, scheme, or
client IP headers. Configure TLS, maximum body and header sizes, idle timeouts,
and request deadlines at both the edge and application layers.

Avoid placing secrets in Actuator, logs, environment dumps, or error responses.
Plan rotation without requiring unsafe manual changes.

## Capacity Planning

Budget resources across all replicas and worker types:

- servlet threads or reactive event loops;
- application executors and queues;
- database connections;
- HTTP and broker connections;
- heap and non-heap memory;
- downstream concurrency and rate limits.

More replicas can overwhelm a fixed database or external service. Load-test the
whole topology with production-like data and failure latency.

## Operational Checklist

- Actuator exposes only required endpoints and applies access control.
- Liveness and readiness semantics match platform behavior.
- Database migrations and backups have tested recovery procedures.
- Every external call has timeouts and bounded retries.
- Logs, metrics, traces, dashboards, and alerts identify the deployed version.
- Background consumers expose lag, retries, and final failures.
- Graceful shutdown and rollback are exercised regularly.
- The JDK, base image, Boot release, and dependencies remain supported.

