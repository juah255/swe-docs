# Service Discovery

In a dynamic environment, service instances come and go and their addresses change. **Service discovery** lets services find each other without hardcoded hosts.

## Why Service Discovery Is Needed

- Containers and VMs are ephemeral -- instances get new IPs on restart
- Auto-scaling adds and removes instances dynamically
- Blue-green and canary deployments change the set of available instances
- Hardcoded addresses break immediately when infrastructure changes

## Discovery Patterns

### Client-Side Discovery

The client queries a **service registry** and picks an instance to call.

```text
Client -> Registry (Consul, Eureka) -> gets instance list -> calls instance directly
```

- Client is responsible for load balancing across instances
- More client complexity, but no extra network hop
- Used by: Netflix Eureka, Consul with client libraries

### Server-Side Discovery

A **load balancer or platform** resolves the target service and routes the request.

```text
Client -> Load Balancer / Platform -> resolves service -> routes to instance
```

- Client is simple -- it calls a stable service name
- The platform handles resolution and load balancing
- Used by: Kubernetes Services, AWS ELB, Envoy

## Service Registry

The registry tracks which instances are available:

- **Registry stores** instance addresses, health status, and metadata
- **Registration** happens on service startup (self-registration or platform-managed)
- **Deregistration** happens on shutdown or failed health check
- **Health checks** remove unhealthy instances from the registry

### Registry Implementations

| Tool | Type | Notes |
|---|---|---|
| **Consul** | Self-hosted / cloud | DNS + HTTP API, health checks, KV store |
| **Eureka** | Self-hosted | Netflix OSS, AP model, integrates with Spring |
| **etcd** | Self-hosted | Distributed KV, used by Kubernetes internally |
| **Kubernetes Services** | Platform-native | DNS-based, no separate registry needed |

## DNS-Based Discovery

- Each service gets a DNS name (e.g., `payment-service.default.svc.cluster.local`)
- DNS resolves to the current set of healthy instances
- Simple, works with existing tooling, but DNS has caching and TTL limitations
- Kubernetes uses this approach natively

## Mid/Senior Interview Questions and Answers

### 1. When do you need a dedicated service registry vs DNS-based discovery?

**Answer:** DNS-based discovery (Kubernetes Services) is sufficient for most
containerized workloads where the platform handles resolution. It is simple,
well-understood, and has no additional infrastructure.

A dedicated registry (Consul, Eureka) is useful when you need advanced features
like cross-cluster discovery, rich metadata, health check customization, or
service-to-service access control beyond what DNS provides.

### 2. What happens when the service registry itself fails?

**Answer:** The registry is a critical dependency. If it goes down, new
instances cannot register and clients cannot discover updated instance lists.

Mitigate with replicated registry clusters (Consul with 3-5 nodes), client-side
caching of instance lists, and graceful degradation where clients continue
using cached addresses until the registry recovers.

### 3. How does service discovery work in Kubernetes?

**Answer:** Each service gets a DNS entry (e.g., `my-service.my-namespace.svc.cluster.local`).
Kubernetes DNS resolves the name to the set of pod IPs backing the service.
A kube-proxy or kube-proxy-based mechanism load-balances across the pods.

No separate registry is needed -- the Kubernetes API server is the source of
truth for which pods belong to which services.
