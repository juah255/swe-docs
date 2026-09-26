# Production PHP Services

Production reliability depends on the full request path: load balancer, web
server, PHP runtime, application, workers, database, cache, queues, and deployment
process.

## Build an Immutable Artifact

A typical build installs locked production dependencies and performs checks:

```bash
composer install \
  --no-dev \
  --prefer-dist \
  --optimize-autoloader \
  --no-interaction
composer check-platform-reqs --no-dev
```

Build once and promote the same artifact. Do not run `composer update` on a
production host. Decide whether Composer scripts and plugins are allowed during
the build, and execute them only in a constrained, reviewed environment.

## Runtime Configuration

Keep secrets and environment-specific values outside the artifact. Validate
required configuration during startup or a deployment check. Important runtime
settings include:

- production error reporting and log destination;
- OPcache capacity and revalidation policy;
- memory and execution limits appropriate to each process type;
- upload and request body limits at PHP and the reverse proxy;
- session cookie and storage configuration;
- FPM pool sizes, timeouts, and slow-request diagnostics;
- timezone, locale, extension, and platform consistency.

Web requests, CLI commands, and workers can load different `php.ini` files.
Verify the configuration of each SAPI rather than assuming they match.

## Web and FPM Boundaries

Let the web server terminate TLS, handle static files, apply request-size and
header limits, and pass only intended scripts to FPM. Prevent arbitrary path
translation from executing uploaded or unintended PHP files.

Align timeouts from the outer proxy inward so an inner component can stop work
and return a controlled failure before the client or proxy has already given up.
Terminate runaway work carefully; a timeout at one layer does not guarantee the
database or remote operation was cancelled.

## Deployment and Migrations

Use health checks and a gradual rollout. Run backward-compatible schema
migrations through one controlled job. During rolling deployment, old and new
web processes and queue workers overlap, so database and message contracts must
support both versions.

Warm framework caches and verify the application before receiving traffic.
For timestamp-disabled OPcache, ensure new workers load the new artifact rather
than relying on filesystem replacement alone.

## Observability

Emit structured logs with timestamp, level, service, deployed version, request
or trace ID, event name, and safe identifiers. Do not record cookies, tokens,
passwords, complete payment data, or arbitrary request bodies.

Monitor request rate, errors, tail latency, FPM active and idle workers, listen
queue, memory, CPU, OPcache usage, database pools, query time, cache performance,
and queue age. Propagate trace context over HTTP and messages where supported.

Health endpoints should distinguish process liveness from readiness to serve
traffic. Do not make liveness fail because one remote dependency is briefly
unavailable; that can create a restart storm.

## Queue Workers and Scheduled Jobs

Run workers as separate supervised process types. Give them explicit concurrency,
memory policy, timeouts, retries, and graceful shutdown. Track oldest job age and
final failures, not only queue length.

In a replicated deployment, a cron entry inside every container may run the same
job several times. Use a platform scheduler, leader election, or distributed
lock, and keep the operation idempotent.

## Operational Checklist

- The PHP version and extensions are supported and patched.
- Locked dependencies and platform requirements are verified.
- Debug output is disabled and safe logging is enabled.
- OPcache and FPM pools are measured and monitored.
- Secrets, sessions, uploads, and administrative tools are protected.
- Database backups and restoration are tested.
- Migrations, worker compatibility, rollback, and graceful shutdown are planned.
- External calls have deadlines, and retries are bounded and idempotent.

