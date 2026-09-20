# Security and Production

React escapes text values before inserting them into HTML, but a React
application is still exposed to browser, API, authentication, dependency, and
deployment risks. Client code is public and untrusted by definition.

## Cross-Site Scripting

Rendering a string in JSX escapes it:

```tsx
return <p>{comment.body}</p>;
```

Avoid `dangerouslySetInnerHTML`. When the product must render user-authored
HTML, sanitize it with a maintained allowlist-based sanitizer at a trusted
boundary and keep sanitization policy under security review.

Do not build HTML, script, style, or event-handler strings from untrusted data.
A Content Security Policy adds defense in depth but does not make unsafe DOM
insertion acceptable.

## URLs and Navigation

Validate user-controlled URLs before placing them in links, image sources, or
redirects. Allow known protocols and expected origins. Prevent open redirects
and unsafe schemes.

When opening an untrusted external page in a new tab, apply the appropriate
opener isolation. Prefer framework link primitives for internal routes while
preserving normal anchor semantics.

## Authentication and Authorization

Client-side route guards and hidden buttons improve experience; they do not
enforce permissions. Every protected backend read and mutation must authenticate
the requester and authorize the resource and action.

Treat roles, prices, ownership IDs, and hidden form values from the browser as
untrusted. Server Functions and Actions are server endpoints even when their
call syntax looks local.

## Sessions, Tokens, and CSRF

Prefer session designs that limit script access to credentials. If
authentication uses cookies, apply appropriate `HttpOnly`, `Secure`, and
`SameSite` attributes and implement CSRF protection according to the request and
origin model.

Do not store long-lived sensitive tokens in browser storage without a threat
model. XSS can read script-accessible storage and act as the user.

## Secrets and Client Bundles

Anything included in browser JavaScript, HTML, source maps, or network requests
is visible to users. Build-time environment variables substituted into client
code are not secrets.

Keep database credentials, private API keys, signing keys, and privileged
service tokens on trusted servers. Expose only narrowly scoped public
configuration to the client.

## API Boundaries

- Validate response shapes before security-sensitive client behavior depends on
  them.
- Apply request and upload size limits on the server.
- Use idempotency for retryable important mutations.
- Avoid leaking internal errors or personal data into notifications.
- Do not rely on a TypeScript type as runtime validation.
- Define cache policy carefully for authenticated responses.

The browser should display backend decisions, not recreate authorization policy
as the source of truth.

## Error Handling and Reporting

Use route and feature Error Boundaries to contain render failures and offer a
safe recovery path. Configure root-level caught, uncaught, and recoverable error
reporting where the rendering setup supports it.

Attach application version, route, release, and correlation identifiers. Redact
tokens, form values, user content, and personal data. Upload source maps to the
error platform securely rather than exposing them publicly when policy forbids
it.

## Observability

Monitor:

- client errors and affected sessions;
- route and data-request latency;
- user-centric performance metrics;
- hydration and recoverable-render errors;
- failed or abandoned form submissions;
- bundle and chunk loading failures;
- release adoption and rollback signals.

Trace identifiers returned by APIs can connect browser failures to backend logs,
but never expose internal trace payloads or secrets.

## Build and Deployment

- Pin and review resolved dependencies.
- Run type checks, linting, tests, and accessibility checks.
- Build in production mode and inspect bundle output.
- Test deep links, refreshes, redirects, and cache headers.
- Serve hashed assets with long-lived immutable caching.
- Keep the HTML shell and deployment metadata fresh enough to reference valid
  chunks after a release.
- Configure fallbacks differently for an SPA and for real server routes.
- Roll out gradually and retain a fast rollback path.

Old HTML pointing at deleted chunks can break users during deployment. Keep
prior assets available long enough or use an atomic release strategy.

## Server Rendering Safety

Server rendering and Server Components add server responsibilities:

- isolate request-specific identity and tenant data;
- prevent private output from entering a shared public cache;
- avoid module-level mutable request state;
- serialize only data intended for the browser;
- apply backend timeouts and cancellation;
- keep server-only modules out of the client dependency graph.

Hydration data embedded in HTML must be serialized safely so it cannot terminate
the surrounding script or markup context.

## Production Checklist

- Semantic, accessible UI works with keyboard and assistive technology.
- Error and Suspense boundaries match recoverable product regions.
- Client bundles contain no secrets or server-only dependencies.
- Backend authorization protects every sensitive operation.
- HTML insertion and external URLs are sanitized or validated.
- Sessions and mutations have an intentional CSRF model.
- Performance, errors, and hydration are observable by release.
- Caches distinguish public from user-specific content.
- Deployments preserve referenced assets and support rollback.
