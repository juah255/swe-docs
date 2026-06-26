# Memory Management

The OS gives every process the illusion of a large, private, contiguous memory
while juggling limited physical RAM behind the scenes. Understanding this is how
you diagnose latency spikes, leaks, and out-of-memory kills in production.

## Virtual Memory

Each process sees its own **virtual address space**. The kernel and hardware
**MMU** translate virtual addresses to physical ones on every access. Benefits:

- **Isolation**: one process cannot read or corrupt another's memory.
- **Flexibility**: physical memory can be allocated lazily and moved.
- **Overcommit**: the sum of all virtual allocations can exceed physical RAM.

## Paging

Memory is divided into fixed-size **pages** (commonly 4 KB). The virtual space
maps to physical **frames** through a **page table**. A page can be in RAM, on
disk (swap), or not yet allocated.

```text
virtual page  ->  page table  ->  physical frame  (or swap, or fault)
```

The **TLB** caches recent translations so the MMU does not walk the page table on
every access.

## Segmentation

An older scheme that divides memory into logical **segments** (code, data,
stack) rather than uniform pages. Modern systems are primarily paged, but the
terminology survives in concepts like the "segmentation fault," which is the
hardware/OS rejecting an illegal memory access.

## Stack vs Heap

| Aspect      | Stack                          | Heap                              |
| ----------- | ------------------------------ | --------------------------------- |
| Allocation  | Automatic, LIFO per call frame | Manual or GC-managed              |
| Lifetime    | Until the function returns     | Until freed or garbage collected  |
| Speed       | Very fast (pointer bump)       | Slower (allocator bookkeeping)    |
| Size        | Small and bounded              | Large                             |
| Typical use | Locals, call frames            | Long-lived objects, large buffers |

Deep or infinite recursion overflows the stack; unbounded allocation exhausts
the heap.

## Page Faults

A **page fault** occurs when a process accesses a page not currently in RAM.

- **Minor fault**: the page is in memory but not yet mapped — cheap.
- **Major fault**: the page must be read from disk/swap — slow, on the order of
  milliseconds.

A burst of major faults shows up as sudden latency and high I/O wait.

## Swapping

When RAM is scarce, the OS writes inactive pages to **swap** on disk to free
frames. Light swapping is normal; heavy swapping causes **thrashing**, where the
machine spends most of its time paging instead of executing. Latency-sensitive
services often disable or minimize swap and rely on adequate RAM instead.

## Memory Leaks

A **leak** is memory that is allocated but never released and never reused. In
manual languages it is unfreed allocations; in GC languages it is references kept
alive unintentionally (caches, listeners, static collections). Leaks cause slow,
steady growth in resident memory until the process is killed or degrades.

## The OOM Killer

When Linux cannot satisfy an allocation and cannot reclaim memory, the **OOM
killer** picks a process and terminates it (`SIGKILL`) to save the system. The
victim is chosen by a score weighted toward large memory users. In containers,
hitting the cgroup memory limit triggers the same kill for that container.

## Backend Memory Pressure Symptoms

- Rising **RSS** that never plateaus — likely a leak.
- Latency spikes correlated with **major page faults** or swap-in.
- High **I/O wait** with little disk-related work — thrashing.
- Sudden process exit with code 137 (`128 + 9`) — OOM-killed.
- GC pauses growing as the heap fills — collector working harder.

## Mid/Senior Interview Questions and Answers

### 1. How do you diagnose a suspected memory leak in production?

**Answer:** Confirm the trend first: watch RSS or heap usage over time and check
whether it grows monotonically across a steady workload. A real leak keeps
climbing and does not return after load drops.

Then capture heap profiles or dumps and compare snapshots to find the growing
allocation set. In GC languages, look for unintended references such as caches
without eviction, static collections, or unremoved listeners.

### 2. What does exit code 137 tell you?

**Answer:** It means the process was killed by signal 9 (`128 + 9`), almost
always the OOM killer or a container hitting its memory limit. The application
itself did not choose to exit.

The fix is either reducing memory use (leaks, oversized caches, large buffers) or
raising the memory limit, plus alerting on RSS approaching the cap before the
kill happens.

### 3. Why can a machine have free swap but still thrash?

**Answer:** Thrashing is about the rate of paging, not the amount of swap left.
If the active working set exceeds RAM, the OS constantly evicts and reloads pages
that are about to be used again, so CPU stalls on disk I/O.

Adding swap does not help; you need more RAM or a smaller working set. Many
latency-sensitive deployments minimize swap so pressure surfaces as an OOM
quickly rather than as silent slowness.

### 4. Why is heap allocation slower than stack allocation?

**Answer:** Stack allocation is just moving a pointer within the current frame
and is freed automatically on return. Heap allocation must find a suitably sized
block, update allocator metadata, and later be freed or garbage collected.

This is why hot paths favor stack-friendly or pooled allocations and avoid
churning many short-lived heap objects that pressure the allocator and GC.

### 5. What is memory overcommit and what is the risk?

**Answer:** Overcommit lets the kernel hand out more virtual memory than there is
physical RAM plus swap, betting that processes will not use it all at once. It
improves utilization because allocations are often sparse.

The risk is that if processes actually touch the promised memory, the kernel runs
out and the OOM killer fires. Capacity planning and per-container limits keep
overcommit from turning into surprise kills.
