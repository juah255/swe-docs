# Deployment and Production

Next.js deployment behavior depends on which framework features the application
uses and what the platform supports. Select the target early; filesystem,
streaming, cache, image, WebSocket, and process-lifetime assumptions affect the
architecture.

## Deployment Options

| Target | Appropriate for | Important limits |
| --- | --- | --- |
| Managed Next.js platform | Full framework features with provider integration | Provider-specific regions, pricing, and limits |
| Node.js server | Long-running process with direct control | Requires reverse proxy, scaling, cache, and lifecycle operations |
| Docker container | Portable Node.js deployment and immutable artifact | Same distributed-state concerns as Node.js plus orchestration |
| Static export | Sites needing no Next.js runtime server | No request-time rendering, Server Actions, Proxy, or other runtime-only features |
| Adapter platform | Runtime integrated through a supported adapter | Feature support and semantics are platform-specific |

Verify support for every used feature instead of assuming all Next.js hosts are
equivalent.

## Production Build

Run a production build in CI and smoke-test the result. Current Next.js builds
do not implicitly replace explicit lint and type-check pipeline steps, so run
those separately.

A typical pipeline includes:

1. frozen dependency installation;
2. formatting, linting, and type checking;
3. unit and integration tests;
4. database or schema compatibility checks;
5. `next build`;
6. end-to-end smoke tests against the artifact;
7. image signing, provenance, and deployment.

## Standalone Output

For containers, standalone output can create a smaller server bundle containing
the traced runtime dependencies. Copy public assets and generated static assets
according to the documented container layout.

Tracing is not infallible. Smoke-test routes that load templates, native
modules, certificates, migrations, and dynamically discovered files.

## Reverse Proxy

When self-hosting, place a hardened reverse proxy or load balancer in front of
the Next.js server. It can enforce malformed-request handling, slow-client
protection, body limits, rate limits, TLS, compression, and connection policy.

Configure forwarded hosts and protocols only from trusted infrastructure. An
untrusted forwarded host can affect redirects, origins, cookies, and canonical
URLs.

## Build-Time and Runtime Configuration

Public-prefixed environment variables are inlined at build time. Server-only
variables may be read at runtime when the route actually renders dynamically.

For one image promoted across environments:

- keep secrets and environment-specific server values out of the build;
- avoid embedding a production hostname into client code unless intended;
- force runtime evaluation only where it is operationally required;
- validate missing configuration before serving traffic.

## Multi-Instance Caching

Several server replicas need shared or coordinated cache state. Configure a
cache handler and tag invalidation strategy supported by the platform.

Test:

- invalidation propagation between replicas;
- behavior during rolling deploys;
- cache key separation between environments and builds;
- regional consistency and failover;
- response when shared cache is unavailable.

Local disk and module memory are not reliable shared state.

## Server Function Encryption

Self-hosted replicas must use a consistent Server Action encryption key when
framework-encrypted action references can move between instances or builds.
Store the key as a secret, rotate it deliberately, and follow the framework's
required encoding and length.

Use deployment identifiers and skew protection where available so users with an
older page do not send actions or request chunks incompatible with a newer
deployment.

## Database Migrations

Use backward-compatible expand-and-contract migrations:

1. add compatible schema;
2. deploy code that handles both forms;
3. backfill and observe;
4. enforce the new constraint;
5. remove old fields in a later release.

Do not run uncontrolled migrations in every server instance on startup.

## Static Assets and CDN

Hashed build assets can receive long immutable caching. HTML, RSC responses,
and user-specific output need framework-aware cache headers.

Keep prior chunks available during rollout or deploy atomically. Old HTML that
references deleted assets causes chunk failures for active sessions.

Use a consistent build ID and asset strategy across replicas serving the same
release.

## Health and Shutdown

Expose platform-appropriate readiness and liveness signals. Readiness should
fail while an instance initializes or drains; liveness should not restart every
replica merely because a downstream service is temporarily unavailable.

On long-running Node.js servers, stop new traffic, finish bounded in-flight work,
flush telemetry, and close resources before the orchestrator's hard deadline.

Serverless platforms control more of this lifecycle; do not rely on background
tasks continuing after a response.

## Production Checklist

- The chosen host supports every runtime, cache, streaming, image, and connection
  feature in use.
- The actual production artifact passes browser smoke tests.
- A reverse proxy and trusted forwarding policy protect self-hosted servers.
- Secrets remain server-only and runtime configuration is validated.
- Cache and Server Action state work across replicas and releases.
- Database changes remain compatible during rolling deployment.
- Old assets survive long enough for active pages.
- Metrics, tracing, health checks, rollback, and incident diagnostics are ready.
