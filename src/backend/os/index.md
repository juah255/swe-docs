# OS

Operating system notes, shell commands, and environment setup references.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between a process and a thread?

**Answer:** A process has its own memory space and resources. A thread runs
inside a process and shares memory with other threads in that process.

Processes provide stronger isolation. Threads are lighter but require careful
synchronization for shared state.

### 2. What are file descriptors?

**Answer:** File descriptors are integer handles the operating system uses to
represent open files, sockets, pipes, and other I/O resources.

Backend services can fail under load if they leak descriptors or exceed limits.
This often appears as "too many open files."

### 3. How do signals affect server processes?

**Answer:** Signals are OS notifications sent to processes. Common examples
include `SIGTERM` for graceful shutdown and `SIGKILL` for immediate termination.

Production services should handle termination by stopping new work, completing
in-flight requests where possible, closing resources, and exiting before the
orchestrator force-kills them.

### 4. What is virtual memory?

**Answer:** Virtual memory gives each process its own address space and lets the
OS map virtual addresses to physical memory or swap.

It improves isolation and memory management, but excessive memory pressure can
cause paging, latency spikes, or out-of-memory kills.

### 5. How do permissions affect deployed applications?

**Answer:** File ownership and permissions determine whether a service can read
configuration, write logs, execute binaries, bind ports, or access volumes.

Run services with least privilege and avoid using root unless the workload
requires it.
