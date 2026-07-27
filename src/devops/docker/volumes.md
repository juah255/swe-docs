# Docker Volumes & Storage

## Why Volumes?

Containers are ephemeral — their writable layer is deleted when removed. Volumes provide **persistent storage** that survives container restarts and removals.

```
Container A ──→ Volume (persistent)
Container B ──→ Bind Mount (host path)
Container C ──→ tmpfs (in-memory, ephemeral)
```

## Volume Types

### Named Volumes (Recommended for data)

Docker manages storage location. Best for databases and app data:

```bash
# Create a volume
docker volume create pgdata

# Use in container
docker run -d \
  -v pgdata:/var/lib/postgresql/data \
  --name db \
  postgres

# Inspect volume location
docker volume inspect pgdata
# → /var/lib/docker/volumes/pgdata/_data
```

### Bind Mounts (Host path mapping)

Mount a specific host directory into the container. Best for development:

```bash
# Mount host directory
docker run -d \
  -v $(pwd)/src:/app/src \
  --name dev \
  node:20-alpine

# With read-only mount
docker run -d \
  -v $(pwd)/config:/etc/app/config:ro \
  nginx

# With named volume + bind mount
docker run -d \
  -v pgdata:/var/lib/postgresql/data \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql:ro \
  postgres
```

### tmpfs Mounts (In-memory only)

Data lives in RAM — gone when container stops. Use for secrets or temp files:

```bash
docker run -d \
  --tmpfs /tmp:rw,size=100m,mode=1777 \
  nginx

# Use case: secrets that should never touch disk
docker run -d \
  --tmpfs /run/secrets:rw,noexec,nosuid \
  myapp
```

## When to Use Each

| Type | Use Case | Persistence | Speed |
|------|----------|-------------|-------|
| Named volume | Databases, app data | Survives removal | Fast |
| Bind mount | Development, config files | Tied to host path | Fast |
| tmpfs | Secrets, temp cache | None (RAM only) | Fastest |

## Volumes in Dockerfiles

```dockerfile
# Declare mount points (documentation + runtime defaults)
VOLUME /var/lib/postgresql/data
VOLUME /var/log/app

# Create volume with specific permissions
RUN mkdir -p /data && chown -R appuser:appuser /data
VOLUME /data
```

## Backup & Restore

```bash
# Backup a volume using a temporary container
docker run --rm \
  -v pgdata:/source:ro \
  -v $(pwd):/backup \
  alpine \
  tar czf /backup/pgdata-backup.tar.gz -C /source .

# Restore a volume
docker run --rm \
  -v pgdata:/target \
  -v $(pwd):/backup \
  alpine \
  tar xzf /backup/pgdata-backup.tar.gz -C /target

# Migrate volume to another host
# 1. Backup on host A (as above)
# 2. Transfer pgdata-backup.tar.gz to host B
# 3. Restore on host B (as above)
```

## Database Data Persistence

```bash
# PostgreSQL with named volume
docker run -d \
  -v pgdata:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  --name pg \
  postgres:16

# MySQL with named volume
docker run -d \
  -v mysqldata:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  --name mysql \
  mysql:8

# Always use named volumes for databases — never bind mounts
# Bind mounts can have permission issues and performance problems
# with database I/O on macOS/Windows.
```

## Managing Volumes

```bash
docker volume ls                          # List all volumes
docker volume inspect pgdata              # Volume details
docker volume rm pgdata                   # Remove a volume
docker volume prune                       # Remove unused volumes
docker system df -v                       # Disk usage by volumes
```

## Anonymous Volumes

```bash
# Without a name — harder to manage
docker run -d -v /var/lib/postgresql/data postgres

# Anonymous volumes are removed with docker container prune
# Named volumes persist until explicitly removed
```

---

## Interview Questions

**Q: What's the difference between `-v` and `--mount`?**
A: `-v` (shorthand) combines volume name and options in one string: `-v pgdata:/data:ro`. `--mount` uses explicit key-value pairs: `--mount source=pgdata,target=/data,readonly`. `--mount` is clearer and fails loudly on syntax errors, while `-v` silently creates directories if the source doesn't exist. Prefer `--mount` in production.

**Q: Why use named volumes for databases instead of bind mounts?**
A: Named volumes are managed by Docker and live in `/var/lib/docker/volumes/` with optimized I/O. Bind mounts rely on host filesystem performance, which can be 10-50x slower on macOS/Windows due to Docker Desktop's virtualization layer. Named volumes also handle permissions correctly and are easier to backup and migrate.

**Q: How would you back up a running database's Docker volume without downtime?**
A: Use the database's built-in tools inside the container: `docker exec pg pg_dump -U postgres > backup.sql` for PostgreSQL, or `docker exec mysql mysqldump -u root -p > backup.sql` for MySQL. For file-level backups, use filesystem snapshots (LVM/ZFS/btrfs) or a temporary container with the volume mounted read-only. For zero-downtime backups, use the database's replication + point-in-time recovery.
