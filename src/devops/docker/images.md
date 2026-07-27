# Docker Images

## What Is an Image?

A Docker image is a read-only template containing application code, runtime, libraries, and filesystem changes. Images are built in **layers** — each instruction in a Dockerfile creates a new layer stacked on top of the previous one. Docker caches layers, so rebuilding skips unchanged steps.

```
┌─────────────────────┐
│   Application Code  │  ← Layer 4
├─────────────────────┤
│   Dependencies      │  ← Layer 3
├─────────────────────┤
│   Runtime (e.g. JDK)│  ← Layer 2
├─────────────────────┤
│   Base OS (e.g. alpine)│ ← Layer 1 (base image)
└─────────────────────┘
```

## Base Images

Base images provide the foundation. Choose minimal ones to reduce attack surface:

```dockerfile
# Bad — huge image, ~900MB
FROM ubuntu:22.04

# Good — minimal, ~5MB
FROM alpine:3.19

# Better for Java — JDK included, optimized
FROM eclipse-temurin:21-jre-alpine
```

## Building Images

```bash
# Basic build
docker build -t myapp:1.0 .

# Build with build args
docker build --build-arg NODE_ENV=production -t myapp:prod .

# Build without cache
docker build --no-cache -t myapp:1.0 .
```

## Tagging

Tags identify image versions. Use semantic versioning and `latest` sparingly:

```bash
docker tag myapp:1.0 myrepo/myapp:1.0
docker tag myapp:1.0 myrepo/myapp:latest
```

## Multi-Stage Builds

Multi-stage builds keep final images small by discarding build tools:

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER node
CMD ["node", "dist/index.js"]
```

## Pushing to Registries

```bash
# Docker Hub
docker login
docker tag myapp:1.0 username/myapp:1.0
docker push username/myapp:1.0

# Amazon ECR
aws ecr get-login-password | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
docker tag myapp:1.0 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0
```

## Image Scanning

Scan for vulnerabilities before deploying:

```bash
# Docker Scout (built into Docker Desktop / CLI)
docker scout cves myapp:1.0

# Trivy (open source)
trivy image myapp:1.0

# Snyk
snyk container test myapp:1.0
```

## Useful Commands

```bash
docker images                  # List local images
docker image inspect myapp:1.0 # Detailed metadata
docker image history myapp:1.0 # Show layers and sizes
docker image prune -a          # Remove unused images
docker rmi myapp:1.0           # Remove a specific image
```

---

## Interview Questions

**Q: What are Docker image layers, and why do they matter?**
A: Each Dockerfile instruction creates a read-only layer. Layers are shared across images (two images using `alpine` share that base layer on disk). This makes pulls faster (only missing layers are downloaded) and builds faster (unchanged layers are cached). However, too many layers bloat build time — combine related `RUN` commands to reduce them.

**Q: What is a multi-stage build and when should you use one?**
A: A multi-stage build uses multiple `FROM` statements, where each stage builds independently. You copy artifacts from earlier stages into the final stage. Use it when build tools (compilers, SDKs, dev dependencies) aren't needed at runtime — it can reduce image size by 60-90%.

**Q: What's the difference between `COPY` and `ADD` in a Dockerfile?**
A: `COPY` simply copies files from the build context into the image. `ADD` does the same but also supports URL fetching and automatic tar extraction. Prefer `COPY` — it's explicit and predictable. Use `ADD` only when you specifically need tar extraction.
