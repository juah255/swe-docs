# Orchestration

Orchestrators schedule containers, maintain desired state, and provide primitives for networking, scaling, and recovery.

## Kubernetes Fundamentals

- Clusters, control plane, and worker nodes
- Pods
- Deployments, ReplicaSets, and StatefulSets
- Services and Ingress
- ConfigMaps and Secrets
- Namespaces
- Persistent volumes
- Requests and limits
- Liveness, readiness, and startup probes
- Jobs and CronJobs

## Application Operations

- Declarative manifests
- Rolling updates and rollbacks
- Horizontal and vertical scaling
- Scheduling and affinity
- Service discovery
- Autoscaling
- Package management with Helm
- Policy and role-based access control (`RBAC`)

## Other Orchestrators

- HashiCorp Nomad
- Managed container platforms
- Cloud-specific container services

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between a Pod, Deployment, and Service?

**Answer:** A Pod is the smallest Kubernetes workload unit and runs one or more
containers together. A Deployment manages replicated Pods and rolling updates. A
Service provides stable networking and load balancing to a set of Pods.

Pods are ephemeral. Deployments and Services provide the operational behavior
needed to run applications reliably.

### 2. Why are readiness and liveness probes separate?

**Answer:** Readiness determines whether a Pod should receive traffic. Liveness
determines whether the container should be restarted.

Keeping them separate prevents bad behavior. A temporarily overloaded app may
need to stop receiving traffic without being restarted. A deadlocked app may
need a restart.

### 3. How do resource requests differ from resource limits?

**Answer:** Requests tell the scheduler how much CPU or memory a container needs
for placement. Limits cap how much it can use.

Incorrect requests cause poor scheduling. Incorrect limits can cause throttling
or out-of-memory kills. Production tuning should use real metrics.

### 4. When is Kubernetes unnecessary for an application?

**Answer:** Kubernetes may be unnecessary for a small app with simple traffic,
few services, limited scaling needs, and a team that does not need the added
operational complexity.

Managed containers, serverless platforms, virtual machines, or PaaS offerings
can be better when they meet the reliability and deployment requirements with
less overhead.
