# API Gateway

An **API gateway** is a single entry point for clients that routes requests to the right backend service. It centralizes cross-cutting concerns so individual services stay simple.

## What an API Gateway Does

- **Request routing** -- maps external API paths to internal services
- **Authentication and authorization** -- validates tokens before requests reach services
- **Rate limiting** -- enforces per-client or per-endpoint limits
- **Request transformation** -- rewrites paths, headers, or body for backend compatibility
- **Response aggregation** -- combines responses from multiple services into one
- **TLS termination** -- handles SSL/TLS at the edge
- **API versioning** -- routes `/v1/` and `/v2/` to different service versions
- **Logging and metrics** -- centralizes observability at the edge
- **CORS handling** -- manages cross-origin policies in one place

## API Gateway vs Reverse Proxy

| | Reverse Proxy | API Gateway |
|---|---|---|
| Operates at | Network level | Application level |
| Understands | HTTP routing, TLS, caching | API contracts, auth, rate limits |
| Configured by | Path, headers, IP | API routes, consumers, plans |
| Example | Nginx, HAProxy | Kong, AWS API Gateway, Envoy |

Many API gateways are built on reverse proxy technology. The gateway adds application-level intelligence on top.

## Placement

```text
Client -> CDN -> API Gateway -> Service A
                             -> Service B
                             -> Service C
```

The gateway is the single surface area for all clients. Internal services are not directly exposed.

## Gateway as a Single Point of Failure

- Horizontally scale the gateway behind a load balancer
- Keep business logic thin in the gateway -- it should route and enforce, not process
- Use circuit breakers for downstream service calls
- Deploy across multiple availability zones

## BFF Pattern (Backend for Frontend)

Instead of one gateway for all clients, create a gateway per client type:

- **Web BFF** -- optimized for browser clients (聚合, session handling)
- **Mobile BFF** -- optimized for mobile clients (smaller payloads, push notifications)
- **Internal BFF** -- for service-to-service calls

This avoids forcing a single gateway to serve conflicting client needs.

## Mid/Senior Interview Questions and Answers

### 1. What is the role of an API gateway, and what is its risk?

**Answer:** The gateway is a single entry point that handles routing, auth, rate
limiting, TLS, and request aggregation, keeping individual services lean. It
gives clients one stable surface over a changing set of services.

Its risk is becoming a single point of failure and a bottleneck, so it must be
horizontally scaled and highly available, with care taken to avoid putting heavy
business logic in it.

### 2. When would you use the BFF pattern?

**Answer:** When different client types (web, mobile, IoT) have conflicting
needs -- different payload sizes, different auth flows, different aggregation
requirements.

A single gateway would either bloat to serve all clients or force compromises.
A BFF per client type keeps each gateway focused and simple, at the cost of
more gateways to maintain.

### 3. Should business logic live in the API gateway?

**Answer:** No. The gateway should handle cross-cutting concerns (auth, rate
limiting, routing, TLS) and stay thin. Business logic in the gateway makes it
harder to scale, deploy, and maintain independently.

If the gateway starts making domain decisions, it is becoming a monolith. Push
business logic into the services and keep the gateway as a traffic manager.
