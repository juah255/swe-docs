# Docker Networks

## How Docker Networking Works

Docker creates virtual networks that containers attach to. Each container gets its own network namespace with its own IP, ports, and routing table. Containers on the same network can communicate; isolation exists across networks.

```
┌─ Bridge Network (default) ─────────────┐
│  Container A (172.17.0.2)              │
│  Container B (172.17.0.3)              │
│  ──────────── can reach each other ─── │
└────────────────────────────────────────┘
         │
    Port published
         │
    Host (0.0.0.0:8080)
```

## Default Bridge Network

Every container joins `docker0` (the default bridge) unless specified otherwise:

```bash
# Containers on default bridge can communicate by IP only
docker run -d --name api nginx
docker run -d --name util alpine ping 172.17.0.2

# But NOT by container name (no DNS on default bridge)
docker run alpine ping api  # ✗ fails
```

## User-Defined Bridge Networks (Recommended)

Provides automatic DNS resolution between containers:

```bash
# Create a custom network
docker network create app-net

# Run containers on it
docker run -d --name api --network app-net nginx
docker run -d --name db --network app-net postgres

# Now api can reach db by name
docker exec api ping db  # ✓ works

# DNS resolves to container's IP on that network
docker exec api getent hosts db
```

```bash
# Connect an existing container to a network
docker network connect app-net api

# Disconnect
docker network disconnect app-net api
```

## Host Network

Container shares the host's network stack directly — no port mapping needed:

```bash
docker run -d --network host nginx
# Nginx listens on host's port 80 directly

# Faster performance (no NAT overhead)
# But port conflicts with host services are possible
# Only works on Linux (not macOS/Windows Docker Desktop)
```

## None Network

Completely isolated — no network access:

```bash
docker run -d --network none alpine
# Container has no eth0, no internet, no inter-container communication
# Useful for security-sensitive workloads
```

## Overlay Networks (Swarm Mode)

Span multiple Docker hosts in a swarm cluster:

```bash
# Initialize swarm
docker swarm init

# Create overlay network
docker network create -d overlay app-overlay

# Services on different hosts can communicate
docker service create --network app-overlay --name api nginx
docker service create --network app-overlay --name db postgres
```

## Container DNS Resolution

```bash
# Custom bridge: containers resolve each other by name and alias
docker network create --driver bridge \
  --subnet 10.10.0.0/24 \
  --gateway 10.10.0.1 \
  custom-net

# Custom DNS server
docker run -d --dns 8.8.8.8 nginx

# Custom DNS search domain
docker run -d --dns-search internal.company.com nginx
```

## Port Exposure vs Publishing

```dockerfile
# EXPOSE documents which ports the container uses (metadata only)
EXPOSE 80
EXPOSE 443
```

```bash
# -P publishes ALL exposed ports to random host ports
docker run -d -P nginx

# -p publishes specific ports
docker run -d -p 8080:80 nginx
#         host:container

# Publish to localhost only (security!)
docker run -d -p 127.0.0.1:8080:80 nginx

# UDP ports
docker run -d -p 5353:53/udp dns-server
```

## Network Isolation Patterns

```bash
# Frontend network — only public-facing containers
docker network create frontend
# API gateway, load balancer

# Backend network — internal services
docker network create backend
# App server, database, cache

# Connect API gateway to both networks
docker run -d --name gateway --network frontend nginx
docker network connect backend gateway

# Database only on backend — unreachable from frontend
docker run -d --name db --network backend postgres
```

## Managing Networks

```bash
docker network ls                              # List networks
docker network inspect app-net                 # Network details
docker network rm app-net                      # Remove a network
docker network prune                           # Remove unused networks
docker network create --subnet 10.1.0.0/16 custom  # Custom subnet
```

---

## Interview Questions

**Q: Why use user-defined bridge networks over the default bridge?**
A: User-defined bridges provide automatic DNS resolution between containers by name, better isolation, and the ability to connect/disconnect containers at runtime. The default bridge only allows IP-based communication and has security limitations (all containers share the default bridge and can communicate freely).

**Q: What's the difference between `EXPOSE`, `-p`, and `-P`?**
A: `EXPOSE` is documentation-only — it declares which ports the container uses but doesn't publish them. `-p host:container` publishes a specific port to the host. `-P` publishes all `EXPOSE` ports to random host ports. Only `-p` and `-P` make ports accessible from outside Docker.

**Q: How do you secure inter-container communication?**
A: Use multiple Docker networks to create isolation zones. Put databases on a backend-only network, frontend services on a separate network, and only connect bridge services (like API gateways) to both. No Dockerfile `EXPOSE` is needed for internal-only services. Additionally, use `--internal` networks to prevent internet access, and encrypt overlay networks for swarm mode.
