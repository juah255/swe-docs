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

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between an image and a container?

**Answer:** An image is an immutable package containing the application,
runtime, filesystem layers, and default command. A container is a running
instance of that image with its own process, writable layer, network namespace,
and runtime configuration.

The image should be reproducible. The container should be disposable.

### 2. Why does a container stop when its main process exits?

**Answer:** A container is tied to its PID 1 process. When that process exits,
the container has no main workload left, so the runtime marks it as stopped.

Production containers should run one main foreground process and rely on the
orchestrator for restart policy, logs, health checks, and lifecycle management.

### 3. When should data be stored in an image, a volume, or an external service?

**Answer:** Store application code and static runtime dependencies in the image.
Store local persistent runtime data in a volume only when the workload requires
node-local persistence. Store critical shared data in an external service such
as a database, object store, queue, or cache.

Do not store mutable production data in the image. Rebuilding or replacing the
container should not destroy business data.

### 4. How do container networking and host networking differ?

**Answer:** Default container networking gives the container its own network
namespace and usually connects it through a bridge, overlay, or orchestrator
network. Host networking lets the container share the host network namespace.

Host networking can reduce isolation and port-management safety. It is usually
reserved for workloads that need direct host networking or very specific
performance behavior.
