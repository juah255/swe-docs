# Operating Systems

An **operating system (OS)** is the layer between application code and hardware.
For backend engineers it matters because almost every production problem —
latency spikes, memory pressure, connection limits, crashes under load — is
ultimately the OS reacting to how your service uses resources.

## What an OS Does

The kernel manages the shared resources of a machine and arbitrates access
between competing processes:

- **Process management**: creating, scheduling, and tearing down processes and
  threads.
- **Memory management**: giving each process a private virtual address space and
  mapping it to physical memory.
- **File and I/O management**: exposing files, sockets, pipes, and devices
  through a uniform interface.
- **CPU scheduling**: deciding which runnable thread gets the CPU next.
- **Protection and isolation**: enforcing permissions and keeping processes from
  corrupting each other.

## Kernel Space vs User Space

The OS splits execution into two privilege levels:

- **Kernel space** runs the kernel with full hardware access.
- **User space** runs your application code with restricted access.

Application code cannot touch hardware directly. When it needs a privileged
operation — open a file, send bytes on a socket, allocate memory — it asks the
kernel through a **system call**.

```text
your code  ->  read()  ->  [user/kernel boundary]  ->  kernel reads disk/socket
```

System calls are not free. Crossing the user/kernel boundary costs CPU cycles,
which is why high-throughput servers batch I/O and avoid making one syscall per
byte.

## Subtopics

- [Processes and Threads](processes-and-threads.md) — units of execution, IPC,
  and concurrency.
- [Memory Management](memory-management.md) — virtual memory, paging, leaks, and
  the OOM killer.
- [CPU Scheduling](scheduling.md) — how the kernel shares the CPU and what that
  means for latency.
- [File Systems and I/O](file-systems-and-io.md) — files, descriptors,
  permissions, and I/O models.
- [OS Questions](questions.md) — a quick Q&A reference.

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
