# Testing and Observability

Next.js combines browser UI, server rendering, caching, server functions, and
HTTP endpoints. Use different test levels for each responsibility and verify
critical behavior in the actual production rendering mode.

## Test Layers

| Layer | Best use |
| --- | --- |
| Unit | Parsers, validators, reducers, DTO mappers, cache-key helpers, and domain rules |
| Component | Client interaction, forms, accessibility, and visible state |
| Integration | Data access, Route Handlers, actions, session logic, and database behavior |
| End-to-end | Routing, Server Components, streaming, hydration, caching, and complete user flows |
| Contract | External APIs, webhooks, generated clients, and durable payloads |

Do not mock the framework deeply to make every file a unit test. Async Server
Components and framework routing are often more reliably tested through
integration or end-to-end tests.

## Unit and Component Tests

Keep business rules and validation in ordinary modules that run without Next.js.
Client Components can be tested with DOM-based tools using role, label, and text
queries.

Mock the network or adapter boundary rather than mocking a component's internal
hook. Cover loading, empty, validation, permission, failure, and success states.

## Data Access Tests

Run authorization and repository integration tests against the production
database engine. Verify tenant isolation, missing resources, permission changes,
transactions, and DTO field selection.

Test that cached and uncached wrappers call the same authorized core function.
Do not let a test-only fake omit the most important security behavior.

## Server Action Tests

Test the action's underlying validation and service functions directly, then
exercise representative actions through the browser or framework request path.

Cover:

- missing and malformed form values;
- unauthenticated and unauthorized calls;
- duplicate submission and idempotency;
- transaction rollback;
- cache invalidation and redirected destination;
- public error state without internal detail.

## Route Handler Tests

Construct realistic Web `Request` objects or run the handler through an
integration server. Verify methods, authentication, body and upload limits,
content types, CORS, CSRF, status codes, and error schemas.

Webhook tests should use real signature fixtures and raw request bytes. Include
duplicate and expired events.

## End-to-End Tests

Run critical journeys against a production build:

- direct navigation and client navigation;
- refresh on dynamic and intercepted routes;
- authenticated redirects and forbidden data;
- form submission before and after hydration;
- loading, error, and not-found boundaries;
- back and forward navigation;
- mobile and keyboard interaction;
- deployment base paths and asset URLs.

Development mode has different caches and diagnostics. It cannot validate the
production rendering and cache model.

## Cache Tests

Cache behavior deserves explicit integration coverage:

- first miss and subsequent hit;
- time-based stale and expiration behavior;
- tag and path invalidation;
- read-your-own-writes after actions;
- user and tenant isolation;
- behavior across multiple application instances;
- fallback when the cache backend fails.

Use a controllable clock or short test profile rather than long real sleeps.

## Instrumentation

An `instrumentation.ts` file initializes server observability once per server
instance:

```ts
export async function register() {
  if (process.env.NEXT_RUNTIME === "nodejs") {
    await import("./instrumentation-node");
  }
}
```

Runtime-specific imports avoid loading incompatible SDKs into another runtime.
The request-error instrumentation hook can forward captured server failures to
an observability provider.

Client instrumentation and error boundaries cover browser startup and rendering
failures. Avoid reporting the same error repeatedly at several layers.

## Logging and Tracing

Include stable fields such as request ID, trace ID, route, action or handler,
release, deployment region, and cache outcome. Redact cookies, tokens, form
values, server function payloads, and personal data.

Trace database and external HTTP spans so a slow Server Component can be
connected to its dependency. Record queue and cache time separately from source
latency.

## Operational Metrics

Monitor:

- request rate, status, and latency by route;
- server render and data-source latency;
- cache hit, stale, miss, and invalidation behavior;
- server function and Route Handler failures;
- client errors, hydration errors, and chunk load failures;
- Core Web Vitals by route and release;
- instance CPU, memory, concurrency, and restarts.

## Testing Checklist

- Pure logic remains easy to unit test.
- Security and storage use real integration boundaries.
- Async Server Component behavior is covered end to end.
- Cache freshness and isolation are verified explicitly.
- Production builds receive browser tests.
- Server and client observability share release and trace context.
