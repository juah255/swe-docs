# Reverse Proxy

A **reverse proxy** sits in front of backend servers and forwards client requests to them. Unlike a forward proxy (which sits in front of clients), a reverse proxy represents the server side.

## What a Reverse Proxy Does

- **Terminates TLS** -- handles SSL/TLS encryption and decryption, offloading it from backend servers
- **Routes requests** -- forwards to the appropriate backend based on path, headers, or other rules
- **Caches responses** -- serves cached content without hitting the backend
- **Compresses responses** -- reduces bandwidth with gzip or Brotli
- **Terminates HTTP/2** -- translates between HTTP/2 clients and HTTP/1.1 backends
- **Rate limiting** -- enforces request limits before traffic reaches backends
- **Logging and metrics** -- centralizes request logging and performance monitoring

## Reverse Proxy vs Load Balancer

- A **load balancer** distributes traffic across multiple backend instances
- A **reverse proxy** is a broader concept that includes routing, caching, TLS termination, and more
- In practice, most reverse proxies also do load balancing (Nginx, HAProxy, Envoy)
- A load balancer may or may not be a reverse proxy (L4 load balancers often are not)

## Common Reverse Proxies

| Tool | Strengths |
|---|---|
| **Nginx** | High performance, widely used, rich configuration |
| **HAProxy** | Advanced load balancing, TCP/HTTP support |
| **Envoy** | Modern, cloud-native, extensible, built for service mesh |
| **Traefik** | Auto-discovery, Let's Encrypt integration, container-friendly |

## Placement

```text
Client -> CDN -> Reverse Proxy / Load Balancer -> Application Servers
```

The reverse proxy is typically the first point of contact after the CDN. It handles TLS, routing, and initial request processing before traffic reaches application servers.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between a reverse proxy and an API gateway?

**Answer:** A reverse proxy operates at the network level -- it routes
requests, terminates TLS, caches, and compresses. It does not understand
application semantics.

An API gateway operates at the application level -- it handles authentication,
authorization, rate limiting, request transformation, and API versioning. It
understands the API contract.

In practice, the two overlap significantly, and many API gateways are built on
top of reverse proxy technology.

### 2. Why terminate TLS at the reverse proxy instead of each backend?

**Answer:** TLS termination at the proxy centralizes certificate management,
reduces CPU overhead on backend servers (encryption is expensive), and allows
the proxy to inspect, cache, and transform traffic.

Backend servers receive unencrypted traffic on a private network, which is
acceptable if the network is trusted. For untrusted networks, use mutual TLS
between the proxy and backends.
