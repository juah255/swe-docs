# Production and Deployment

A production Django system includes more than application code: a process
server, reverse proxy or load balancer, database, cache, storage, task workers,
monitoring, and a repeatable release process all participate in correctness.

## WSGI or ASGI

Deploy the project with a production WSGI or ASGI server. Django's development
server is not designed for production.

Choose WSGI for a predominantly synchronous application. Choose ASGI when the
application has meaningful async I/O or ASGI integrations. Running under ASGI
does not automatically make synchronous views, middleware, database calls, or
libraries asynchronous.

Put a reverse proxy or managed load balancer in front to handle TLS, request-size
limits, slow clients, and appropriate timeouts. Preserve client and scheme
headers only through trusted proxies.

## Release Flow

A typical release pipeline performs these steps:

1. Build an immutable application artifact and install locked dependencies.
2. Run tests, system checks, static analysis, and security scanning.
3. Collect static files and publish them to their serving location.
4. Back up and apply reviewed, backward-compatible migrations.
5. Roll out web and worker processes gradually.
6. Run health checks and smoke tests, then observe key signals.

Do not have every application replica race to run migrations at startup. Use one
controlled deployment job and design schema changes for mixed application
versions.

```bash
python manage.py check --deploy
python manage.py migrate --noinput
python manage.py collectstatic --noinput
```

Run the deployment check against the actual production settings. Django's
system checks are not automatically performed whenever a WSGI server starts.

## Static Files and Media

Static files are versioned application assets. Collect and serve them through a
CDN, object storage integration, or web server suited to the deployment.

Media is user-controlled data and needs a separate durability and security
plan. Use persistent shared storage rather than a container's local filesystem,
and define access control, retention, scanning, and backups.

## Process and Connection Sizing

Set worker counts from load tests and resource budgets rather than a copied
formula. Account for:

- memory per process and thread;
- database, cache, and HTTP connection limits;
- request latency and blocking behavior;
- background queues and worker concurrency;
- graceful shutdown time and in-flight requests.

Application timeouts should be shorter than outer proxy deadlines where
possible, leaving time to return a controlled error. Configure remote calls with
connect and read timeouts.

## Health and Observability

Expose separate health signals when the platform supports them:

- **liveness** says the process can continue running;
- **readiness** says it can receive traffic;
- **startup** gives slow initialization its own window.

Do not make a liveness check fail because an optional dependency is briefly
unavailable; that can cause a restart storm. Readiness may include only the
dependencies required to serve the endpoint class.

Collect structured logs, metrics, traces, and error reports with a request or
trace identifier. Monitor latency percentiles, response codes, saturation,
query time, lock waits, queue age, task failures, and deployment markers. Scrub
credentials and personal data.

## Background Workers

Deploy task workers and schedulers as independently scalable process types. Give
them explicit queues, concurrency, timeouts, retry policy, and graceful shutdown.
Track queue age as well as queue length: a short queue of stuck jobs can still be
an outage.

Ensure web and worker versions remain compatible during rolling deployments.
Tasks already in a queue may have been produced by the previous release.

## Operational Readiness

Before launch, verify secrets, hosts, HTTPS, cookies, email, storage, backups,
restoration, migration rollback strategy, alert ownership, and incident
procedures. Test shutdown, dependency failure, and recovery in a staging
environment that resembles production.

