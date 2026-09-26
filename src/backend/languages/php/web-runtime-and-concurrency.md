# Web Runtime and Concurrency

## SAPIs and Process Models

PHP runs through a Server API, or SAPI. Common modes include:

- PHP-FPM behind Nginx or Apache for HTTP requests;
- CLI for commands, jobs, and worker processes;
- an Apache module in some deployments;
- long-running application servers and event-loop runtimes.

In a typical FPM deployment, a pool of worker processes handles one request per
worker at a time. The web server manages client connections and passes PHP work
to the pool. Tune web and FPM concurrency together with database and downstream
connection limits.

## Request Isolation

Traditional PHP code assumes request state ends after the response. Static
variables and singletons do not normally need an application-level reset because
the request environment is torn down, though the worker process and OPcache
remain.

Long-running servers, queue consumers, and event loops break that assumption.
Static state, container singletons, locale, timezone, error handlers, database
transactions, and per-request caches can leak into later work. Frameworks built
for a long-running mode usually provide reset hooks; application code must still
avoid retaining request objects or user data.

## HTTP Input and Output

Native PHP exposes request information through superglobals such as `$_GET`,
`$_POST`, `$_FILES`, `$_COOKIE`, and `$_SERVER`. Treat all of it as untrusted and
normalize it at the application boundary.

Headers must be sent before response body bytes. A front controller and response
abstraction help prevent scattered `header()` and `echo` calls.

PSR-7 defines immutable HTTP message interfaces. PSR-15 defines server request
handlers and middleware. Middleware composes cross-cutting transport behavior
such as request IDs, authentication, routing context, and response headers.
Domain authorization still belongs near the operation and data it protects.

## Cookies and Sessions

PHP sessions associate a session identifier cookie with server-side data in the
configured handler. Starting a session can lock it; a long request may block
other requests from the same user. Write required changes and close the session
early when later work does not need it.

Configure secure, HTTP-only cookies, an appropriate `SameSite` policy, strict
session handling, and identifier rotation after authentication. Never place
secrets or large object graphs in a session.

## Fibers and Event Loops

Fibers are cooperatively suspended execution contexts. They provide a primitive
used by async libraries, but they do not make blocking I/O non-blocking and do
not schedule themselves.

An event-loop or coroutine runtime needs compatible non-blocking clients for
HTTP, database, DNS, filesystem, and timers. One blocking library call can stall
the loop. Bound concurrency so an async fan-out does not exhaust sockets,
memory, or a downstream service.

## Background Work

A response should not depend on an in-process callback continuing after it is
sent. FPM workers can be recycled, containers can stop, and fatal errors can
discard the work.

Use a durable queue for email, media processing, webhooks, and retryable jobs.
Design handlers for at-least-once delivery:

- pass stable identifiers rather than serialized service objects;
- make effects idempotent;
- use bounded retry with backoff and jitter;
- distinguish permanent rejection from transient failure;
- record attempts and dead-letter outcomes;
- publish only after related database work commits.

For critical database-to-message consistency, use a transactional outbox.

## CLI and Workers

CLI processes should use meaningful exit codes, write normal output to standard
output and diagnostics to standard error, and respond to termination signals.
Long-lived consumers should periodically release large references, close stale
connections, and support graceful shutdown between jobs.

Set memory and time policy deliberately. A worker supervisor can restart a
process after a bounded number of jobs or memory threshold, but restarts are a
safety measure, not a substitute for diagnosing a leak.

