# Load Balancing

A **load balancer** distributes incoming requests across multiple servers, improving throughput and availability. It also performs health checks and removes unhealthy nodes from rotation.

## Where Load Balancing Happens

- **L4 (transport layer)** -- routes by IP address and port. Fast, but cannot inspect request content.
- **L7 (application layer)** -- routes by HTTP path, headers, cookies, or body. More flexible, enables content-based routing.

Most production setups use L7 load balancers for HTTP traffic.

## Algorithms

| Algorithm | How It Works | Best For |
|---|---|---|
| **Round robin** | Rotate through servers in order | Equal-capacity servers |
| **Least connections** | Send to the server with fewest active requests | Variable request durations |
| **Weighted** | Bias toward more powerful nodes | Heterogeneous hardware |
| **Consistent hashing** | Map a key to a node, minimize reshuffling on node change | Stateful sessions, caches |
| **IP hash** | Hash client IP to pick a server | Session affinity |

## Health Checks

Load balancers periodically probe backend servers:

- **Active health checks** -- send requests to a `/health` endpoint
- **Passive health checks** -- detect failures from real traffic (timeouts, 5xx errors)
- Unhealthy servers are removed from rotation until they recover

## Types of Load Balancers

- **Hardware** -- dedicated appliances (F5, Citrix). Expensive, high performance.
- **Software** -- Nginx, HAProxy, Envoy. Flexible, runs on commodity hardware.
- **Cloud-managed** -- AWS ALB/NLB, GCP Cloud Load Balancing, Azure Load Balancer. Managed, auto-scaling, integrated with cloud ecosystems.

## Load Balancer as a Single Point of Failure

- Deploy load balancers in pairs (active-passive or active-active)
- Use DNS failover or floating IPs for automatic switchover
- Cloud-managed load balancers are typically highly available by default

## Mid/Senior Interview Questions and Answers

### 1. When do you choose L4 over L7 load balancing?

**Answer:** L4 is faster and simpler when you only need IP/port-based routing
and cannot inspect request content. L7 is more flexible when you need
content-based routing (URL path, headers, cookies), TLS termination, request
 rewriting, or protocol-specific optimizations.

Most web applications use L7 because the routing flexibility outweighs the
slight overhead.

### 2. How does consistent hashing help with load balancing?

**Answer:** Consistent hashing maps keys (user IDs, URLs, cache keys) to
specific nodes using a hash ring. When a node is added or removed, only a
small fraction of keys are remapped, unlike modular hashing which remaps
everything.

This is critical for caches and stateful services where reshuffling all keys
on every node change would cause stampedes and hotspots.

### 3. What happens when a load balancer itself fails?

**Answer:** The load balancer becomes a single point of failure. Mitigate with
active-passive or active-active pairs, DNS failover, and cloud-managed load
balancers that are redundant by design.

For active-active pairs, both instances handle traffic simultaneously, and a
floating IP or DNS record points to the healthy one. Health checks trigger
automatic failover.
