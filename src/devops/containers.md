# Containers

Containers package an application and its runtime dependencies into a repeatable unit.

## Core Definitions

Dockerfile: Defines how to build an image

Container: A running instance of an image

docker-compose.yml: Defines how to run containers together

## Docker Fundamentals

- Images, containers, layers, and registries
- Writing and building a `Dockerfile`
- Build context and `.dockerignore`
- Container commands, entrypoints, and exit codes
- Port publishing and container networks
- Volumes and persistent data
- Environment variables and secrets
- Logs and resource limits

## Image Design

- Small, trusted base images
- Layer caching
- Multi-stage builds
- Running as a non-root user
- Reproducible image tags and immutable digests
- Image vulnerability scanning

## Docker Compose

- Defining multiple services
- Service dependencies and health checks
- Networks and volumes
- Development overrides
- Starting, stopping, rebuilding, and inspecting a stack

## Questions to Answer

- What is the difference between an image and a container?
- Why does a container stop when its main process exits?
- When should data be stored in an image, a volume, or an external service?
- How do container networking and host networking differ?
