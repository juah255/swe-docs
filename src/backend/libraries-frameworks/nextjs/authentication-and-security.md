# Authentication and Security

Authentication establishes identity, session management carries it across
requests, and authorization decides which data and operations are allowed.
Next.js provides server primitives, but a maintained authentication library is
usually safer than building the protocol and session lifecycle from scratch.

## Session Design

A session may be stored entirely in a signed or encrypted cookie or represented
by an opaque ID backed by a database. Choose based on revocation, size,
confidentiality, scaling, and audit requirements.

For cookie sessions, use appropriate attributes:

- `HttpOnly` to block direct script access;
- `Secure` in HTTPS environments;
- an intentional `SameSite` policy;
- a narrow `Path` and domain scope;
- a finite expiration and renewal policy.

Do not place secrets or large user profiles in a client-readable session.

## Centralize Secure Data Access

Create a server-only data access layer that verifies the current session and
authorizes each operation near the data source:

```ts
import { cache } from "react";
import "server-only";

export const verifySession = cache(async () => {
  const session = await readSessionCookie();
  if (!session) redirect("/login");
  return session;
});

export async function getOrder(orderID: string): Promise<OrderDTO | null> {
  const session = await verifySession();
  const order = await database.order.findFirst({
    where: { id: orderID, tenantID: session.tenantID },
  });

  return order ? toOrderDTO(order) : null;
}
```

The React `cache` call deduplicates session verification within a render pass;
it is not permission persistence or a cross-request session cache.

## Do Not Rely on Layout Checks

Layouts can persist and participate in partial navigation. An authorization
check only in a layout is too far from the protected query and may not run for
every client navigation or operation.

Check authorization in:

- data access functions;
- Server Actions;
- Route Handlers;
- server-side resource loaders;
- any independent job or webhook path reaching the same data.

UI checks may hide controls and redirect for user experience, but they are not
the enforcement boundary.

## Proxy Checks Are Optimistic

Proxy can read a session cookie and redirect before a protected route renders.
Keep this check fast and avoid a database round trip on every matched request or
prefetch.

Proxy is defense in depth and navigation policy. Secure authorization still
belongs near the data or mutation.

## Data Transfer Objects

Return only fields the caller may see:

```ts
type AccountDTO = {
  id: string;
  displayName: string;
};
```

Do not pass full ORM records to Client Components. They may contain password
hashes, internal flags, tenant identifiers, or fields added later without a UI
security review.

DTO mapping should happen after authorization and before serialization.

## Server Actions and Route Handlers

Every callable Server Action and Route Handler is a public attack surface.
Repeat authentication and resource authorization inside it. Validate IDs and
form fields even when the UI generated them.

Use CSRF defenses appropriate to the session and origin model. Next.js provides
framework protections for Server Actions, but custom Route Handlers, proxies,
and cross-origin deployments still require deliberate origin, cookie, and token
policy.

Configure allowed action origins only for trusted deployment origins.

## Cache Isolation

Authorization-sensitive output must not enter a cache shared across users or
tenants. Review:

- which identity values are part of a cache key;
- whether a static shell contains private data;
- CDN and reverse-proxy cache headers;
- tag invalidation after permission changes;
- preview and production environment separation.

An authorization check before reading a wrongly shared cache does not repair the
cache entry's contents.

## Secrets and Environment Boundaries

Only use public-prefixed environment variables for values safe to publish in
browser JavaScript. Public values are embedded at build time.

Keep secrets in server-only modules and configure the deployment platform's
secret store. Do not serialize them into props, error messages, logs, source
maps, metadata, or client configuration endpoints.

## Input, HTML, and URLs

React escapes text by default. Sanitize any HTML passed to raw HTML rendering
with a maintained allowlist policy. Validate user-controlled redirect targets
and URL schemes to prevent open redirects and unsafe links.

Apply request body, upload, and query complexity limits before expensive parsing
or rendering. Validate file contents on the server rather than trusting MIME
types or extensions.

## Security Headers

Set headers according to the application's threat model:

- Content Security Policy;
- clickjacking protection through CSP framing policy;
- strict transport security at the HTTPS boundary;
- content type sniffing protection;
- a deliberate referrer policy;
- permissions policy for browser capabilities.

Nonce-based CSP may interact with dynamic rendering and scripts. Test the real
production response rather than copying a policy that breaks framework output.

## Security Checklist

- Use a maintained authentication and session solution.
- Authorize beside every protected data read and write.
- Keep Proxy checks optimistic and fast.
- Return explicit DTOs, not storage records.
- Validate every Action and Route Handler input.
- Prevent private data from entering shared caches.
- Keep secrets in server-only code and out of public environment variables.
- Test CSRF, XSS, redirects, upload limits, and security headers.
