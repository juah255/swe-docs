# Dockerfile Best Practices

## 1. Use Multi-Stage Builds

Separate build dependencies from runtime:

```dockerfile
# Build stage
FROM golang:1.22 AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o server .

# Runtime stage — only the binary
FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/server /server
CMD ["/server"]
# Final image: ~10MB instead of ~800MB
```

## 2. Order Instructions for Maximum Cache Hits

Docker caches layers top-down. Put rarely-changing instructions first:

```dockerfile
# ✗ Bad — changes to source code invalidate npm install
COPY . .
RUN npm install

# ✓ Good — dependencies change less often than source
COPY package*.json ./
RUN npm ci --only=production
COPY . .
```

## 3. Choose Slim Base Images

```dockerfile
# ✗ Bad
FROM ubuntu:22.04       # ~77MB
FROM node:20            # ~1GB
FROM python:3.12        # ~900MB

# ✓ Good
FROM node:20-alpine     # ~170MB
FROM python:3.12-slim   # ~130MB
FROM eclipse-temurin:21-jre-alpine  # ~180MB

# ✓ Best (distroless — no shell, no package manager)
FROM gcr.io/distroless/static
FROM gcr.io/distroless/java21-debian12
```

## 4. Write an Effective .dockerignore

Prevent unnecessary files from entering the build context:

```gitignore
.git
node_modules
*.md
.env
.env.*
docker-compose*.yaml
Dockerfile*
.dockerignore
__pycache__
*.pyc
.vscode
.idea
coverage
dist
```

## 5. Run as Non-Root User

```dockerfile
# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy files with correct ownership
COPY --chown=appuser:appgroup ./dist /app

# Switch to non-root user
USER appuser

# Important: USER must come AFTER file operations that need root
CMD ["node", "dist/index.js"]
```

## 6. Combine Related RUN Commands

Each `RUN` creates a layer — minimize them:

```dockerfile
# ✗ Bad — 4 separate layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN rm -rf /var/lib/apt/lists/*

# ✓ Good — single layer, cleanup in same layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      wget && \
    rm -rf /var/lib/apt/lists/*
```

## 7. Use COPY Instead of ADD

```dockerfile
# ✗ ADD fetches URLs and extracts tarballs automatically
ADD app.tar.gz /app

# ✓ COPY is explicit
COPY app.tar.gz /tmp/
RUN tar -xzf /tmp/app.tar.gz -C /app && rm /tmp/app.tar.gz

# Only use ADD for automatic tar extraction
ADD rootfs.tar.gz /    # Acceptable
```

## 8. CMD vs ENTRYPOINT

```dockerfile
# ENTRYPOINT defines the executable
# CMD provides default arguments (overridable)

ENTRYPOINT ["python", "manage.py"]
CMD ["runserver", "0.0.0.0:8000"]
# → docker run myapp                     → python manage.py runserver 0.0.0.0:8000
# → docker run myapp migrate             → python manage.py migrate

# For scripts, use exec form and handle signals
ENTRYPOINT ["./entrypoint.sh"]
CMD ["npm", "start"]

# Shell form won't forward signals — use exec
# ✗ ENTRYPOINT node server.js    (PID 1 is sh, not node)
# ✓ ENTRYPOINT ["node", "server.js"]  (PID 1 is node, gets SIGTERM)
```

## 9. Security Scanning

```dockerfile
# Scan at build time with Docker Scout
# docker build --sbom=true --provenance=true -t myapp .

# Or scan after building
# docker scout cves myapp:latest

# Scan in CI pipeline
# trivy image --severity HIGH,CRITICAL myapp:latest
```

## 10. Pin Versions

```dockerfile
# ✗ Tags can change unexpectedly
FROM node:20-alpine
RUN apk add --no-cache curl

# ✓ Pin to specific versions
FROM node:20.11.1-alpine3.19
RUN apk add --no-cache curl=8.5.0-r0
```

## Complete Production Dockerfile

```dockerfile
FROM node:20.11.1-alpine3.19 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --production

FROM node:20.11.1-alpine3.19
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/package.json .
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q --spider http://localhost:3000/health
ENTRYPOINT ["node", "dist/index.js"]
```

---

## Interview Questions

**Q: How does Docker layer caching work, and how do you optimize for it?**
A: Each Dockerfile instruction creates a layer. Docker caches layers and reuses them on rebuilds if the instruction and its inputs haven't changed. To optimize: put `COPY package.json` before `RUN npm install`, then `COPY . .` after — so dependencies aren't reinstalled on every code change. Order instructions from least to most frequently changing.

**Q: What's the difference between `CMD` and `ENTRYPOINT`, and when do you use each?**
A: `ENTRYPOINT` sets the main executable. `CMD` provides default arguments that can be overridden at runtime. Use `ENTRYPOINT` when your container has a single purpose (like a CLI tool) and `CMD` for default parameters. Use exec form `["cmd"]` not shell form to ensure PID 1 receives signals properly.

**Q: Why should you run containers as a non-root user?**
A: If an attacker escapes the container or exploits a vulnerability in your app, running as root gives them root access to the container filesystem and potentially the host (depending on kernel vulnerabilities and capabilities). Running as non-root limits the blast radius. It's also a CIS Docker Benchmark requirement.

---

## Python / FastAPI Example

A minimal production Dockerfile for a Python FastAPI service:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Key differences from the Node examples above:
- Use `python:<version>-slim` (not full `python:<version>` which is ~900 MB).
- `pip install --no-cache-dir` avoids storing pip's download cache in the layer.
- Copy `requirements.txt` first and install before copying source code so that dependency installation is cached across code changes (same layer-caching principle as `COPY package*.json`).

**Q: What is the difference between a Docker image and a container?**
A: An image is a static, read-only template composed of filesystem layers. A container is a runtime instance of an image with a writable layer added on top. Multiple containers can run from the same image independently. Each container has its own state, logs, and network configuration. Destroying a container does not destroy the image.
