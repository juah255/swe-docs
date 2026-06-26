# OS Questions

A quick reference of common operating-system questions for backend engineers.

## What does an operating system do?

It manages a machine's shared resources — processes, memory, files, I/O, and the
CPU — and isolates programs from each other. Applications request privileged
operations through **system calls** rather than touching hardware directly.

## What is the difference between kernel space and user space?

**Kernel space** runs the kernel with full hardware privileges. **User space**
runs application code with restricted access. Crossing the boundary (a syscall)
has a cost, which is why high-throughput servers minimize and batch syscalls.

## What is a system call?

A **system call** is the controlled entry point for user code to ask the kernel
to do something privileged — open a file, read a socket, allocate memory, spawn a
process. Examples: `read`, `write`, `open`, `fork`, `mmap`.

## Process vs thread?

A **process** has its own memory and resources; a **thread** runs inside a
process and shares its memory. Processes isolate failures; threads are lighter
but require synchronization for shared state.

## What is a context switch?

The kernel saving one thread's CPU state and restoring another's. It enables
multitasking but costs cycles plus cache/TLB penalties, so excessive switching
(too many threads) wastes CPU.

## What is virtual memory?

A per-process private address space mapped to physical RAM or swap by the MMU. It
provides isolation and lets the system overcommit memory and allocate lazily.

## What is paging?

Dividing memory into fixed-size **pages** mapped to physical **frames** via a
page table. Pages can live in RAM or swap; accessing a page not in RAM triggers a
**page fault**.

## What is the difference between the stack and the heap?

The **stack** holds call frames and locals, is fast, and frees automatically on
return. The **heap** holds longer-lived, dynamically sized data and is managed
manually or by a garbage collector.

## What is swapping and thrashing?

**Swapping** moves inactive pages to disk to free RAM. **Thrashing** is when the
working set exceeds RAM and the system spends most of its time paging instead of
executing — fixed with more RAM or a smaller working set, not more swap.

## What is the OOM killer?

A Linux mechanism that kills a process (with `SIGKILL`) when memory is exhausted
and cannot be reclaimed. OOM-killed processes show exit code 137. Container memory
limits trigger the same behavior per container.

## What are file descriptors?

Integer handles for open files, sockets, and pipes. They are a limited per-process
resource; leaking them or exceeding `ulimit -n` causes "too many open files."

## What is an inode?

A filesystem structure holding a file's metadata and data-block pointers — but not
its name. Directories map names to inodes. A disk can run out of inodes while
still having free space.

## How do file permissions affect a service?

Owner/group/other read-write-execute bits decide whether a process can read
config, write logs, run binaries, and access volumes. Run services with least
privilege and avoid root unless required.

## Blocking vs non-blocking vs asynchronous I/O?

**Blocking** parks the thread until done. **Non-blocking** returns immediately
with "not ready." **Asynchronous** starts the operation and notifies on
completion. Non-blocking and async let one thread serve many connections.

## What are select, poll, and epoll?

Readiness APIs for watching many descriptors. `select` and `poll` rescan all
descriptors each call (O(n)); `epoll` (Linux) and `kqueue` (BSD) register interest
once and return only ready descriptors, scaling to many idle connections.

## What are signals?

Asynchronous notifications to a process. `SIGTERM` requests graceful shutdown,
`SIGKILL` forces immediate termination, `SIGHUP` often triggers reload. Services
should handle `SIGTERM` to drain in-flight work before exiting.

## Concurrency vs parallelism?

**Concurrency** is structuring overlapping tasks (possible on one core);
**parallelism** is running them simultaneously on multiple cores. Async servers
are concurrent without being parallel.

## Mid/Senior Interview Questions and Answers

### 1. How would you debug a service that gets slow only under load?

**Answer:** Separate the resource dimensions: CPU (run-queue length, scheduling
latency, throttling), memory (RSS growth, page faults, swap), and I/O (open fds,
blocking calls, disk/network wait). The symptom usually maps to one of these.

High latency with low CPU often means scheduling contention or blocking I/O
exhausting a thread pool; steady memory growth points to a leak; rising major
faults point to memory pressure. Measure before changing anything.

### 2. Why is "the write succeeded" not the same as "the data is safe"?

**Answer:** Writes are buffered in application and OS layers for performance, so a
successful `write()` only means the data was accepted into a buffer, not flushed
to durable storage. A crash before flush loses it.

For durability you must `fsync`/flush and understand your storage stack's
guarantees. This is central to database design and to not losing logs on crash.

### 3. How do you keep a slow dependency from taking down a service?

**Answer:** Isolate it: give it its own bounded thread pool or connection pool
(bulkheading), apply timeouts so calls cannot block forever, and add circuit
breakers to fail fast when it is unhealthy.

Without isolation, blocking calls to one slow dependency consume all workers and
stall unrelated requests — a common cascading-failure pattern.

### 4. What OS-level limits do you check before a high-concurrency deploy?

**Answer:** File-descriptor limits (`ulimit -n` / `LimitNOFILE`), available
memory and container memory limits, CPU quotas/throttling settings, and ephemeral
port range for outbound connections. Any of these can cap concurrency invisibly.

Set them deliberately for the expected connection count, and monitor open fds,
RSS, and run-queue length so you see the ceiling approaching before it causes
errors.

### 5. Why does adding more threads sometimes reduce throughput?

**Answer:** Beyond the point where threads exceed useful parallelism, extra
threads add context-switch overhead, lock contention, and cache pressure without
doing more real work — especially for CPU-bound tasks.

Size concurrency to the workload: near core count for CPU-bound work, larger or
async for I/O-bound work, and tune by measuring where throughput plateaus and
latency rises.
