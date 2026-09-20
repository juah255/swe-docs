# Routing and Rendering Architectures

React does not prescribe routing or where initial rendering happens. The router
or framework determines URL matching, data loading, code splitting, navigation,
server rendering, and deployment behavior.

## Rendering Models

| Model | Initial work | Strength | Main trade-off |
| --- | --- | --- | --- |
| Client-side rendering (CSR) | Browser downloads code and renders | Simple static hosting and rich client navigation | Slower useful first render on weak devices or networks |
| Server-side rendering (SSR) | Server renders HTML per request | Request-specific HTML and faster initial content | Server cost plus hydration complexity |
| Static rendering | Build system generates HTML ahead of time | Fast delivery and cacheability | Content freshness and build-time constraints |
| Streaming SSR | Server sends HTML in stages | Progressive reveal around Suspense boundaries | More complex loading and failure design |
| Server Components | Framework renders selected components outside the client bundle | Direct server data access and less client code | Framework-specific boundaries and serialization rules |

A mature application can combine these per route and component boundary.

## Routing Responsibilities

A production router should coordinate:

- URL parsing and type-safe parameters;
- nested layouts and route ownership;
- route data and mutation lifecycles;
- navigation pending and error UI;
- redirects, not-found behavior, and status codes;
- code and data preloading;
- scroll restoration and focus management;
- authorization response behavior.

Keep shareable page state—filters, search, sort, pagination, and selected
records—in the URL when appropriate.

## Hydration

Hydration attaches React behavior to server-rendered HTML. The initial client
render must produce compatible output with the server render.

Common mismatch causes include:

- reading time, randomness, locale, or browser-only APIs during render;
- rendering different authenticated data on client and server;
- invalid HTML nesting corrected differently by the browser;
- extensions or third-party scripts mutating markup;
- cache and serialization inconsistencies.

Treat hydration warnings as bugs. Suppressing a warning is an escape hatch for
a known, unavoidable one-level difference, not a general fix.

## Server and Client Boundaries

Server Components can read server resources and render output without shipping
their component code to the browser. Interactive Client Components use state,
Effects, event handlers, and browser APIs.

Keep the client boundary as low as practical. A large client-marked subtree
increases JavaScript and can pull otherwise server-only dependencies into the
client graph.

Data crossing from server to client must follow the framework's serialization
contract. Do not pass database connections, request objects, arbitrary class
instances, or secrets.

## Server Components Are Not SSR

The concepts can work together but solve different problems:

- Server Components decide which component code and data processing stay out of
  the client bundle.
- SSR turns a React result into initial HTML.
- Hydration activates Client Components in that HTML.

A Server Component may run at build time or request time. Use a framework that
implements the protocol; low-level bundler integration APIs can evolve.

## Streaming and Suspense

Streaming sends completed UI segments while slower regions remain behind
Suspense fallbacks. Design boundaries with the product's reveal sequence:

- keep stable navigation and page context visible;
- use skeletons sized to reduce layout shift;
- avoid replacing already useful content with a full-page spinner;
- place error handling near independently recoverable segments.

Streaming does not make a slow dependency fast. Parallelize independent server
work and apply backend timeouts.

## Navigation and Accessibility

Client routing must preserve web behavior:

- links should be real links with meaningful destinations;
- opening in a new tab and copying the URL should work;
- back and forward history should restore expected state;
- page titles and document metadata should update;
- focus should move appropriately after navigation;
- route loading and errors should be announced when needed.

Use a button for an action and a link for navigation.

## Authentication and Authorization

Route guards in client code improve user experience but do not enforce
security. The server must authorize every protected data read and mutation.

For server rendering, avoid leaking one user's response through a shared cache.
Define cache keys and private response policy with identity and tenant context.

## Architecture Checklist

- Which routes need search visibility or fast initial content?
- Where does data loading begin, and can independent work run in parallel?
- Which components truly need browser interactivity?
- Are hydration inputs deterministic and serialized safely?
- Do loading and error boundaries match meaningful page regions?
- Does navigation preserve URLs, history, focus, and status codes?
- Are server caches safe for authenticated and tenant-specific data?
