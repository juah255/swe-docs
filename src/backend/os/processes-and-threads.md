# Processes and Threads

A **process** is a running program with its own resources. A **thread** is a unit
of execution inside a process. Backend services are built out of both, and most
concurrency bugs and scaling limits trace back to how they are used.

## Process vs Thread

| Aspect          | Process                          | Thread                          |
| --------------- | -------------------------------- | ------------------------------- |
| Memory          | Private address space            | Shares process memory           |
| Isolation       | Strong (crash stays contained)   | Weak (crash can take down all)  |
| Creation cost   | Heavy                            | Light                           |
| Communication   | IPC (pipes, sockets, shared mem) | Shared variables                |
| Context switch  | Expensive                        | Cheaper                         |

A crash or memory corruption in one thread can take down the whole process,
because threads share heap, file descriptors, and global state. Separate
processes contain failures but cost more to create and coordinate.

## Process States

A process moves through a small set of states as the scheduler runs it:

```text
new -> ready -> running -> terminated
              ^         |
              |         v
            (waiting / blocked on I/O)
```

- **Ready**: runnable, waiting for the CPU.
- **Running**: currently executing on a core.
- **Blocked / waiting**: stalled on I/O, a lock, or a signal.
- **Terminated**: finished, but may linger as a **zombie** until the parent
  reaps its exit status.

## Context Switching

A **context switch** is the kernel saving one thread's registers and program
counter, then loading another's. It happens on every preemption, syscall block,
or I/O wait. It is not free: it costs CPU cycles and pollutes CPU caches and the
TLB. A server doing too many switches (often from too many threads) burns time
switching instead of working.

## Inter-Process Communication (IPC)

Separate processes need explicit channels to talk:

- **Pipes**: a unidirectional byte stream between related processes.
- **Shared memory**: a memory region mapped into multiple processes — fastest,
  but you must synchronize access yourself.
- **Sockets**: byte streams or datagrams, works locally (Unix sockets) or across
  the network.
- **Signals**: asynchronous notifications such as `SIGTERM` or `SIGHUP`; useful
  for control, not data.

## Concurrency vs Parallelism

- **Concurrency** is structuring work so multiple tasks make progress in
  overlapping time windows — even on a single core.
- **Parallelism** is literally running tasks at the same instant on multiple
  cores.

```text
Concurrency: one cook switching between several dishes
Parallelism: several cooks, one dish each
```

You can have concurrency without parallelism (an async event loop on one core)
and you need multiple cores for real parallelism.

## Thread Pools

Creating a thread per request does not scale: thread creation is costly and
thousands of threads cause scheduling overhead and memory bloat. A **thread
pool** keeps a fixed set of worker threads pulling from a queue. This bounds
resource use, smooths load, and lets you tune concurrency to the hardware.

Sizing rule of thumb:

- **CPU-bound** work: pool size near the number of cores.
- **I/O-bound** work: larger pools, or an async/event-loop model instead.

## Backend Implications

- Blocking calls inside a fixed pool can exhaust workers and stall the service —
  isolate slow dependencies (separate pools, bulkheads, timeouts).
- Shared mutable state across threads needs locks, and locks introduce
  contention and deadlock risk.
- Forking per request (classic CGI) is simple but costly; long-lived worker
  processes/threads are the norm.

## Mid/Senior Interview Questions and Answers

### 1. When would you choose multiple processes over multiple threads?

**Answer:** Choose processes when you need fault isolation or want to bypass a
runtime's global lock. A worker model with separate processes contains crashes
and memory corruption, and lets each worker use a full core in languages with a
GIL.

Threads are better when tasks must share large in-memory state cheaply and you
can manage synchronization carefully.

### 2. Why can too many threads make a server slower?

**Answer:** Beyond a point, adding threads increases context-switch overhead,
lock contention, and cache misses without adding useful parallelism. The CPUs
spend more time switching and coordinating than doing work.

The fix is bounding concurrency with a pool sized to the workload and using
async I/O for I/O-bound paths rather than one thread per connection.

### 3. What is a zombie process and why does it matter?

**Answer:** A zombie is a terminated child whose exit status has not yet been
collected by its parent. It holds a slot in the process table. If a parent never
reaps children, zombies accumulate and can exhaust the table.

In containers this shows up when PID 1 does not reap children; use an init
process or handle `SIGCHLD` properly.

### 4. How do concurrency and parallelism differ in practice?

**Answer:** Concurrency is a design property — many tasks in flight — while
parallelism is an execution property of running them simultaneously on multiple
cores. An async server is highly concurrent on a single core but not parallel.

This matters when picking a model: CPU-bound work needs parallelism (more
cores/processes); I/O-bound work benefits most from concurrency.

### 5. What happens during a context switch and why care?

**Answer:** The kernel saves the current thread's CPU state, updates scheduling
data, and restores another thread's state, often invalidating cache and TLB
entries. Each switch costs microseconds plus indirect cache penalties.

Under high request rates these add up, so reducing unnecessary threads and
blocking calls keeps more CPU time on real work.
