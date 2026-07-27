# Docker Containers

## What Is a Container?

A container is a running instance of an image. It adds a writable layer on top of the read-only image layers, giving the process its own filesystem, network, and process space — all isolated from the host and other containers.

```
┌──────────────────────────────┐
│         Container            │
│  ┌────────────────────────┐  │
│  │   Writable Layer       │  │
│  ├────────────────────────┤  │
│  │   Image Layers (RO)    │  │
│  └────────────────────────┘  │
│  Process │ Network │ Mounts  │
└──────────────────────────────┘
```

## Running Containers

```bash
# Run in foreground (attached)
docker run nginx

# Run in background (detached)
docker run -d nginx

# Run with a name
docker run -d --name web nginx

# Run and auto-remove when stopped
docker run -d --rm nginx

# Run interactively
docker run -it ubuntu bash
```

## Port Mapping

```bash
# Map host:8080 → container:80
docker run -d -p 8080:80 nginx

# Map to random host port
docker run -d -P nginx

# Bind to specific interface
docker run -d -p 127.0.0.1:8080:80 nginx

# Multiple ports
docker run -d -p 8080:80 -p 8443:443 nginx
```

## Environment Variables

```bash
# Single variable
docker run -d -e POSTGRES_PASSWORD=secret postgres

# From a file
docker run -d --env-file .env postgres

# Multiple files
docker run -d --env-file .env --env-file .secrets postgres
```

## Managing Containers

```bash
docker ps                  # Running containers
docker ps -a               # All containers (including stopped)
docker stop web            # Graceful stop (SIGTERM then SIGKILL)
docker start web           # Restart stopped container
docker restart web         # Restart running container
docker rm web              # Remove stopped container
docker rm -f web           # Force remove (even running)
docker container prune     # Remove all stopped containers
```

## Exec — Running Commands Inside Containers

```bash
# Open a shell
docker exec -it web bash

# Run a one-off command
docker exec web cat /etc/nginx/nginx.conf

# Run as specific user
docker exec -u root web apk add curl

# Set environment for exec session
docker exec -e DEBUG=true web python debug.py
```

## Logs

```bash
# View logs
docker logs web

# Follow (tail -f equivalent)
docker logs -f web

# Show last 100 lines
docker logs --tail 100 web

# Show logs since timestamp
docker logs --since 2024-01-01T12:00:00 web

# Show timestamps
docker logs -t web
```

## Resource Limits

```bash
# Memory limit
docker run -d --memory=512m --memory-swap=512m nginx

# CPU limit (1.5 cores)
docker run -d --cpus=1.5 nginx

# CPU shares (relative weight)
docker run -d --cpu-shares=512 nginx

# Disk I/O limit
docker run -d --device-read-bps /dev/sda:10mb nginx

# Restart policy
docker run -d --restart=unless-stopped nginx
```

## Health Checks

```dockerfile
# In Dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:80/ || exit 1
```

```bash
# Override at runtime
docker run -d \
  --health-cmd="curl -f http://localhost/ || exit 1" \
  --health-interval=15s \
  --health-timeout=5s \
  --health-retries=3 \
  nginx

# Check health status
docker inspect --format='{{.State.Health.Status}}' web
```

## Useful Inspect Commands

```bash
docker inspect web                    # Full JSON metadata
docker inspect --format='{{.State.Pid}}' web   # Container PID
docker top web                        # Processes inside container
docker stats web                      # Live resource usage
docker diff web                       # Changed files in writable layer
```

---

## Interview Questions

**Q: What happens when you run `docker stop` vs `docker kill`?**
A: `docker stop` sends SIGTERM, waits a grace period (default 10s), then sends SIGKILL. `docker kill` sends SIGKILL immediately (or a custom signal). Use `stop` for graceful shutdown; use `kill` only when a process ignores SIGTERM.

**Q: How do resource limits work in Docker?**
A: Docker uses cgroups (Linux kernel feature) to enforce limits. `--memory` caps RAM usage; exceeding it triggers OOM kill. `--cpus` limits CPU time. `--memory-swap` controls total memory+swap. Without limits, a single container can starve the host or other containers.

**Q: What's the difference between `docker exec` and `docker attach`?**
A: `docker exec` starts a new process inside a running container (like SSH). `docker attach` connects your terminal to the container's main (PID 1) process — if that process exits, the container stops. Use `exec` for debugging; avoid `attach` in production.
