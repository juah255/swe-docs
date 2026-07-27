# Docker Compose

## What Is Docker Compose?

Docker Compose defines and runs multi-container applications using a YAML file. Instead of long `docker run` commands, you declare your entire stack — services, networks, volumes — in `compose.yaml` and start everything with one command.

```bash
docker compose up -d        # Start all services
docker compose down         # Stop and remove everything
docker compose ps           # List running services
docker compose logs -f api  # Follow logs for one service
```

## Basic Structure

```yaml
# compose.yaml
services:
  api:
    build: ./api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgres://db:5432/mydb
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: secret

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
```

## Build Context

```yaml
services:
  api:
    build:
      context: ./api
      dockerfile: Dockerfile.prod
      args:
        NODE_ENV: production
      target: production    # Multi-stage build target
      cache_from:
        - myapp/api:latest

  worker:
    build:
      context: .
      dockerfile: Dockerfile
      target: worker
```

## Depends On & Health Checks

```yaml
services:
  api:
    build: ./api
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s

  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
```

## Environment Variables

```yaml
services:
  api:
    # Inline
    environment:
      NODE_ENV: production
      DATABASE_URL: postgres://db:5432/mydb

    # From file
    env_file:
      - .env
      - .env.secrets

    # Per-service override
    env_file:
      - path: .env.production
        required: true
```

```bash
# .env file (project-wide defaults)
POSTGRES_PASSWORD=devpassword
REDIS_PORT=6379
```

## Scaling Services

```bash
# Scale a service to 3 instances
docker compose up -d --scale api=3

# Note: you can't map fixed ports when scaling
# Use a load balancer or remove fixed port mappings
```

```yaml
services:
  api:
    build: ./api
    # Don't specify ports when scaling
    expose:
      - "8000"  # Internal only, load balancer handles routing
```

## Profiles

Run subsets of services based on environment:

```yaml
services:
  api:
    build: ./api
    # Always starts (no profile)

  db:
    image: postgres:16-alpine
    # Always starts (no profile)

  debug-tools:
    image: busybox
    profiles:
      - debug
      - dev

  test-runner:
    build: ./tests
    profiles:
      - test
```

```bash
# Default — only api and db start
docker compose up -d

# With debug tools
docker compose --profile debug up -d

# Multiple profiles
docker compose --profile debug --profile test up -d
```

## Network Configuration

```yaml
services:
  api:
    networks:
      - frontend
      - backend

  db:
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No internet access
```

## Volume Configuration

```yaml
services:
  api:
    volumes:
      # Named volume
      - app-data:/app/data
      # Bind mount (development)
      - ./src:/app/src
      # Read-only bind mount
      - ./config:/app/config:ro

volumes:
  app-data:
    driver: local
```

## Restart & Resource Policies

```yaml
services:
  api:
    build: ./api
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "1.5"
        reservations:
          memory: 256M
          cpus: "0.5"
```

---

## Interview Questions

**Q: How does `depends_on` work, and what's the `condition` option?**
A: `depends_on` controls startup order. Without `condition`, it only waits for the container to start (not be ready). With `condition: service_healthy`, it waits until the dependent's health check passes. This prevents your API from starting before the database is actually accepting connections — not just running.

**Q: How do you manage different environments (dev, staging, prod) with Compose?**
A: Use multiple Compose files: `compose.yaml` (base), `compose.override.yaml` (dev defaults), `compose.prod.yaml` (production overrides). Merge them: `docker compose -f compose.yaml -f compose.prod.yaml up`. Use `.env` files for environment-specific variables and profiles to conditionally run services like debug tools or test runners.

**Q: What happens when you scale a service with fixed port mappings?**
A: It fails — only one container can bind to a host port at a time. When scaling, use `expose` (internal ports only) and put a load balancer (like Nginx or Traefik) in front. Alternatively, use dynamic port mapping without the `ports` key.
