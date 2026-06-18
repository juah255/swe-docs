# Networking and Web Infrastructure

Networking knowledge is required to deploy applications, expose services, and debug connectivity failures.

## Network Fundamentals

- IP addresses, subnets, routes, and gateways
- Public and private networks
- TCP and UDP
- Ports and sockets
- Network address translation (`NAT`)
- Firewalls and security groups
- Domain Name System (`DNS`)

## Web Traffic

- HTTP methods, status codes, headers, and cookies
- HTTP/1.1, HTTP/2, and HTTP/3
- TLS certificates and HTTPS
- Forward and reverse proxies
- Load balancers and health checks
- Content delivery networks (`CDNs`)
- WebSockets and long-lived connections

## Tools to Learn

- `curl` for HTTP requests
- `dig` or `nslookup` for DNS
- `ping` and `traceroute` for network paths
- `ss` or `netstat` for sockets
- `nc` for testing TCP and UDP connections
- `openssl` for inspecting TLS
- `tcpdump` or Wireshark for packet analysis

## Mid/Senior Interview Questions and Answers

### 1. What happens after entering a URL in a browser?

**Answer:** The browser parses the URL, checks caches, resolves DNS, opens a
TCP or QUIC connection, negotiates TLS for HTTPS, sends an HTTP request, follows
redirects if needed, receives the response, and renders the content.

In production, the request may also pass through a CDN, load balancer, reverse
proxy, service mesh, application server, database, and external services.

### 2. How does DNS map a domain name to an application?

**Answer:** DNS resolves a domain name into records such as `A`, `AAAA`,
`CNAME`, or load-balancer-specific records. The browser or resolver follows the
chain until it gets an address or target.

DNS only gets the client to the next network endpoint. Routing, TLS, proxy
configuration, and application routing still determine whether the request
actually reaches the right service.

### 3. What is the difference between a reverse proxy and a load balancer?

**Answer:** A reverse proxy sits in front of backend services and forwards
requests, often handling TLS, compression, headers, routing, and caching. A load
balancer distributes traffic across multiple backend instances.

Many production tools do both. The interview point is the responsibility:
request mediation versus traffic distribution.

### 4. How do you locate whether a failure is DNS, routing, firewall, TLS, or application?

**Answer:** Test layer by layer. Use DNS tools to confirm resolution, network
tools to confirm connectivity, TLS tools to confirm certificates, HTTP tools to
inspect status and headers, and logs to confirm whether the application saw the
request.

If the application has no logs for the request, the failure is likely before the
app: DNS, route, firewall, load balancer, proxy, or TLS.
