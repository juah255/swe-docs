# Route Handlers, Proxy, and BFF

Next.js can serve as a backend-for-frontend (BFF) through Route Handlers, Server
Functions, and Proxy. These features are public server surfaces, not private
shortcuts around validation and authorization.

## Route Handlers

A `route.ts` file exports HTTP method functions:

```ts
// app/api/orders/[orderID]/route.ts
export async function GET(
  request: Request,
  { params }: { params: Promise<{ orderID: string }> },
) {
  const session = await verifyAPISession(request);
  const { orderID } = await params;
  const order = await getAuthorizedOrder(session, orderID);

  if (!order) {
    return Response.json({ error: { code: "NOT_FOUND" } }, { status: 404 });
  }

  return Response.json(toOrderDTO(order));
}
```

Supported handlers follow Web `Request` and `Response` APIs. Use framework
request helpers only when cookies, URL utilities, or other Next.js extensions
are needed.

A `route.ts` and `page.tsx` cannot own the same route segment because one path
cannot be both an HTTP handler and a UI page convention.

## When to Use a Route Handler

Use Route Handlers for:

- browser or mobile JSON endpoints;
- webhooks and third-party callbacks;
- file or generated non-UI responses;
- OAuth redirects;
- streaming endpoints supported by the deployment;
- a BFF boundary that hides upstream topology or credentials.

Server Components should call shared server functions or data sources directly,
not the application's own Route Handlers.

## Validate the Entire Request

Validate method, authentication, authorization, content type, body size, schema,
and resource identity. Return stable error codes and avoid raw exception text.

Webhook handlers often require the raw body for signature verification. Verify
the signature before parsing or performing side effects, reject old replayed
timestamps where the provider supports them, and make event processing
idempotent.

## CORS and CSRF

Route Handlers do not make cross-origin policy automatic. Add only the allowed
origins, methods, and headers needed by actual consumers.

Cookie-authenticated state-changing requests need a CSRF defense. CORS is not a
complete CSRF solution, and `SameSite` is one layer rather than a universal
replacement for request tokens or origin checks.

## Streaming and Runtime Limits

The Web Streams API can return incremental output, but platform timeouts,
buffering, maximum duration, and connection support vary. Some serverless hosts
cannot provide durable WebSockets or long-running work.

Do not store cross-request state in module memory. A deployment may create many
instances, recycle them, or handle concurrent requests in one process.

## Proxy

`proxy.ts` runs at the request boundary before routing completes:

```ts
import { NextResponse, type NextRequest } from "next/server";

export function proxy(request: NextRequest) {
  if (request.nextUrl.pathname.startsWith("/legacy")) {
    return NextResponse.redirect(new URL("/docs", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/legacy/:path*"],
};
```

Use it for request-dependent redirects, rewrites, headers, experiments, or a
fast optimistic session check. Prefer static configuration redirects when
request data is unnecessary.

Only one Proxy entry file is supported, though its implementation can import
separate modules.

## Proxy Is Not Application Middleware

Proxy runs broadly, including during prefetching depending on its matcher. Keep
it fast and avoid database access or slow network calls. `fetch` cache options
do not provide the usual Next.js caching behavior inside Proxy.

Do not rely on Proxy as the only authorization layer. Verify permissions again
inside the data access function, action, or Route Handler that reaches protected
data.

The older `middleware.ts` convention was renamed and is deprecated in current
Next.js. Use `proxy.ts` for new code and migrate old files with the official
codemod after reviewing runtime differences.

## BFF Boundaries

A Next.js BFF is useful for UI-specific aggregation and protocol translation.
It is not automatically a replacement for:

- long-running job workers;
- durable message consumers;
- shared APIs serving many independent products;
- high-volume WebSocket infrastructure;
- workloads requiring a runtime unavailable on the host.

Keep domain logic in reusable server modules and let Route Handlers adapt HTTP.

## Endpoint Checklist

- Treat every handler and callable action as public.
- Authenticate and authorize at the protected operation.
- Apply schema, size, timeout, and rate limits.
- Verify webhook signatures against raw bytes.
- Configure CORS and CSRF deliberately.
- Avoid self-fetching from Server Components.
- Match streaming and connection designs to host limits.
- Keep Proxy fast and use it only when request interception is necessary.
