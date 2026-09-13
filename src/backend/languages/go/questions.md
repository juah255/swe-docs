# Go Questions

These questions review the Go concepts most relevant to backend services.

## 1. What is the difference between a goroutine and an OS thread?

**Answer:** A goroutine is a lightweight unit scheduled by the Go runtime. An
operating-system thread is scheduled by the kernel. The runtime multiplexes
goroutines over threads and can grow goroutine stacks as needed. Goroutines are
cheap, not free; every one still needs ownership, cancellation, and bounded
resource use.

## 2. How do buffered and unbuffered channels differ?

**Answer:** An unbuffered send waits until a receiver participates. A buffered
channel permits sends until its fixed buffer is full and receives until it is
empty. Buffers can provide limited decoupling and backpressure, but they do not
solve an indefinitely faster producer.

## 3. Who should close a channel?

**Answer:** The sending side that knows no more values will be produced should
usually close it. Receivers can use closure as a completion signal. A channel
does not need to be closed for garbage collection, and closing from the wrong
owner risks panics from later sends or duplicate closes.

## 4. How should `context.Context` be used?

**Answer:** Pass context as the first parameter to operations that may block or
spawn child work. Propagate deadlines and cancellation to database, HTTP, and
queue calls. Do not store context in long-lived structs or use its values for
ordinary optional parameters. Always call derived cancel functions.

## 5. What is the typed-nil interface pitfall?

**Answer:** An interface contains a dynamic type and value. It compares equal to
`nil` only when both are absent. Assigning a nil `*MyError` to an `error` gives
the interface a dynamic type, so it is non-nil. Return a plain `nil` when no
error exists.

## 6. How should Go errors be wrapped and inspected?

**Answer:** Add operation context with `%w` when callers need the cause. Inspect
wrapped chains with `errors.Is` for a target and `errors.As` for a type. Expose
only error categories callers can act on, and do not parse message text for
control flow.

## 7. When should panic and recover be used?

**Answer:** Panic is for unrecoverable programmer errors or impossible startup
states, not ordinary validation or dependency failures. Recover belongs at a
deliberate goroutine, request, or process boundary that can record the failure
and choose a safe outcome. It works only from a deferred function in the same
goroutine.

## 8. How do slices work internally?

**Answer:** A slice is a descriptor containing a pointer to an underlying array,
a length, and a capacity. Slices can share storage. `append` may reuse that
storage or allocate a new array, depending on capacity. Copy at an ownership
boundary when later mutation must be isolated.

## 9. What is the difference between a nil and empty slice?

**Answer:** Both have length zero and support append, but only the nil slice
compares equal to `nil`, and encoders may represent them differently—for
example, `null` versus `[]`. Normalize according to the external contract.

## 10. What is escape analysis?

**Answer:** Escape analysis is the compiler's decision about whether storage can
stay on a goroutine stack or must outlive that frame. Captures, returned
pointers, and interface calls can influence it, but it is not a fixed language
rule. Use compiler diagnostics and profiles before optimizing around escape.

## 11. What causes a data race?

**Answer:** A data race occurs when goroutines access the same memory
concurrently, at least one access writes, and synchronization is absent. Use
ownership transfer, mutexes, channels, or appropriate atomics, and run the race
detector. Race-free code can still have higher-level logical races.

## 12. How would you design a worker pool?

**Answer:** Use a fixed number of worker goroutines, a bounded job channel,
context cancellation, defined result or error ownership, and a wait mechanism
for shutdown. The job queue and downstream calls must be bounded so overload
does not become unlimited memory and latency.

## 13. When should you use an interface versus a generic?

**Answer:** Use an interface for runtime behavior shared by different
implementations. Use a generic when reusable code should preserve relationships
between input, element, and output types. Do not introduce either when a
concrete function or type is simpler.

## 14. Why should interfaces usually be small and consumer-owned?

**Answer:** A consumer knows the minimum behavior it needs. Defining that small
contract near the use case avoids coupling it to every method of a provider and
makes alternate adapters and test fakes easier to implement.

## 15. Why can a small slice keep a large amount of memory alive?

**Answer:** The slice still references its underlying array, even if it exposes
only a short range. If that slice is retained, the full array may remain
reachable. Copy the needed segment when its lifetime will greatly exceed the
source's.

## 16. Why can too many goroutines make a service slower?

**Answer:** Goroutines consume stack memory and scheduling work and often compete
for pools, locks, sockets, and downstream capacity. Excess concurrency increases
queueing and contention. Size it from the workload and dependency limits, then
measure saturation and latency.

## 17. What production settings matter for Go HTTP servers?

**Answer:** Configure header, read, write, idle, request, and shutdown deadlines
according to endpoint behavior. Limit request bodies, propagate context, reuse
configured HTTP clients, close response bodies, expose health signals, and test
graceful shutdown.

## 18. What makes a Go service production-ready?

**Answer:** It needs bounded goroutines, queues, and pools; finite deadlines;
input validation; secure configuration; structured logs and metrics; race-tested
concurrency; reproducible builds; health signals; dependency management; and a
tested shutdown path.
