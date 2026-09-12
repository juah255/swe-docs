# Production TypeScript Services

Production executes JavaScript, not TypeScript types. Reliability depends on the
emitted artifact, Node.js runtime, runtime validation, resource limits, and
operational behavior—not only a clean compiler result.

## Build the Deployable Artifact

A production build should be reproducible and contain everything needed at
runtime:

- emitted or bundled JavaScript;
- required runtime dependencies;
- package metadata and lock file as appropriate;
- migrations, schemas, templates, and static assets;
- source maps handled according to the security policy;
- a clear executable entry point.

Run a smoke test against the built artifact. Development runners can resolve
TypeScript paths, extensions, and files differently from production Node.js.

## Type Checking and Transpilation

Some build tools remove TypeScript syntax without checking types. Run `tsc` in
no-emit mode or an equivalent full check in CI even when another tool produces
the output.

Pin the compiler and runtime versions used in CI. Compiler upgrades can change
inference and declaration behavior without changing runtime code, so review
them like other dependencies.

## Runtime Validation

Validate HTTP, configuration, queue, database, and third-party data at entry.
Apply size limits before expensive parsing, then convert accepted data into
trusted application types.

Generated clients and ORM types do not make remote systems truthful. Deployment
order, stale messages, manual database changes, and independent services can
all produce values outside the local type model.

## Source Maps and Errors

Source maps translate generated stack frames back to TypeScript locations. Make
them available to the error-reporting system used by operators, while deciding
carefully whether they should be publicly served or embedded in client-facing
artifacts.

Preserve error causes and stable codes. HTTP responses should never expose
stack traces, source paths, SQL messages, or secrets.

## Observability

Structured logs and telemetry should use stable, typed field conventions where
practical:

```ts
type RequestLogContext = {
  requestId: string;
  traceId?: string;
  route: string;
  method: string;
};
```

Typing logging helpers reduces inconsistent fields, but runtime redaction is
still required. Never log credentials, tokens, full request bodies, or sensitive
personal data by default.

Monitor request rates, errors, latency percentiles, event-loop delay, CPU,
memory, pool saturation, dependency timeouts, queue lag, and process restarts.

## Schema and Database Changes

Types, application code, and storage schemas can be deployed at different
times. Use backward-compatible migrations:

1. expand the schema so old and new code both work;
2. deploy code that writes or reads the new form safely;
3. backfill and observe;
4. enforce new constraints;
5. remove obsolete fields in a later deployment.

Generating new database types does not make a breaking migration safe.

## API and Event Compatibility

Include schema compatibility checks for public APIs and durable events. During
rolling deployments, producers and consumers may run different application
versions simultaneously.

Handle unknown external variants according to an explicit policy. A TypeScript
union generated at build time cannot predict a value added by another service
after deployment.

## Dependency and Supply-Chain Safety

- Commit and enforce the lock file.
- Keep runtime dependencies separate from development tools.
- Review packages, install scripts, ownership, and maintenance.
- Update the Node.js runtime and dependencies regularly.
- Run vulnerability and license checks appropriate to the project.
- Avoid shipping the compiler and source files when production does not need
  them.

Type-only packages usually do not belong in the production dependency set, but
confirm whether framework metadata or build-time generation is required during
deployment.

## Graceful Shutdown

The application should fail readiness, stop accepting new requests and jobs,
finish or cancel in-flight work within a deadline, close pools and clients, flush
telemetry, and exit before the platform's hard-kill timeout.

Types can define lifecycle interfaces, but integration tests must prove that
real resources close and the built process responds correctly to signals.

## Deployment Checklist

- Use strict type checking and a reproducible production build.
- Test the emitted entry point on the supported Node.js runtime.
- Validate all external data at runtime.
- Apply compatible schema migrations separately and observably.
- Configure timeouts, cancellation, pools, and concurrency bounds.
- Protect source maps and redact sensitive telemetry.
- Expose meaningful liveness and readiness checks.
- Run as a non-root user with minimal permissions.
- Roll out gradually and watch errors, latency, and saturation.

TypeScript removes many preventable mistakes before deployment. Production
engineering handles the failures its erased types cannot see.
