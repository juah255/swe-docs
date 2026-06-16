# Go

Go is commonly used for backend services, CLIs, distributed systems, and
network-heavy applications. Senior-level Go interviews usually focus on
concurrency, memory behavior, interfaces, error handling, and production
service design.

## Questions and Answers

### 1. What is the difference between a goroutine and an OS thread?

**Answer:** A goroutine is a lightweight unit of execution managed by the Go
runtime. An OS thread is managed by the operating system. Many goroutines can
run on a smaller number of OS threads.

Go uses an `M:N` scheduler:

- `G`: goroutine;
- `M`: machine, or OS thread;
- `P`: processor, which owns a runnable goroutine queue.

Goroutines are cheaper to create than OS threads and start with small stacks
that grow as needed. This makes them useful for high-concurrency backend work,
such as handling many network requests.

### 2. How do buffered and unbuffered channels differ?

**Answer:** An unbuffered channel requires the sender and receiver to meet at
the same time. The send blocks until another goroutine receives the value.

A buffered channel can hold a fixed number of values. Sending blocks only when
the buffer is full, and receiving blocks only when the buffer is empty.

Use unbuffered channels when synchronization is important. Use buffered
channels when you need limited queueing, backpressure, or worker pools.

### 3. How should `context.Context` be used in backend services?

**Answer:** `context.Context` carries deadlines, cancellation signals, and
request-scoped values across API boundaries.

Common uses:

- cancel database queries when the HTTP request is canceled;
- enforce request timeouts;
- stop child goroutines when the parent operation ends;
- pass trace IDs or request IDs.

Do not store `Context` in a struct for long-lived use. Pass it explicitly as
the first parameter to functions that perform work.

### 4. What is a common interface pitfall in Go?

**Answer:** A common pitfall is a typed `nil` inside an interface.

An interface value contains both a dynamic type and a dynamic value. If the
dynamic type is set but the dynamic value is `nil`, the interface itself is not
`nil`.

This often appears with errors:

```go
var err *MyError = nil
return err // returns a non-nil error interface
```

Return a plain `nil` when there is no error. Also keep interfaces small and
define them near the consumer, not always near the implementation.

### 5. How does Go handle errors, and how should errors be wrapped?

**Answer:** Go treats errors as values. Functions usually return an `error`
value as the last return value.

Use wrapping when adding context:

```go
return fmt.Errorf("load user %s: %w", id, err)
```

Use `errors.Is` to check sentinel errors and `errors.As` to extract typed
errors. Avoid losing the original error because callers may need to inspect it.

### 6. What causes data races in Go, and how do you prevent them?

**Answer:** A data race happens when multiple goroutines access the same memory
at the same time, at least one access is a write, and there is no
synchronization.

Prevent races with:

- channels for ownership transfer;
- `sync.Mutex` or `sync.RWMutex` for shared state;
- `sync.Once` for one-time initialization;
- atomic operations for simple counters or flags.

Use `go test -race` to detect many race conditions during testing.

### 7. How do slices work internally?

**Answer:** A slice is a small descriptor containing a pointer to an underlying
array, a length, and a capacity.

Appending may reuse the same underlying array if capacity is available. If not,
Go allocates a new array and copies elements.

Pitfalls:

- modifying one slice can affect another slice sharing the same array;
- keeping a small slice of a huge array can keep the huge array alive in memory;
- appending to a shared slice from multiple goroutines is unsafe.

### 8. What is escape analysis?

**Answer:** Escape analysis is the compiler process that decides whether a
value can stay on the stack or must be allocated on the heap.

A value may escape to the heap if it is returned by reference, captured by a
closure, stored in an interface, or used beyond the current stack frame.

Heap allocation is not always bad, but excessive allocation increases garbage
collector work. Use benchmarks and profiles before changing code for allocation
reasons.

### 9. How would you design a worker pool in Go?

**Answer:** A typical worker pool uses:

- a jobs channel;
- a fixed number of worker goroutines;
- a results or errors channel if output is needed;
- a `context.Context` for cancellation;
- a `sync.WaitGroup` to wait for completion.

The key senior-level detail is backpressure. The jobs channel should usually be
bounded so producers cannot enqueue unlimited work and exhaust memory.

### 10. What production settings matter for Go HTTP servers?

**Answer:** Always configure timeouts. The default `http.Server` can be unsafe
for public services if timeouts are missing.

Important settings:

- `ReadHeaderTimeout`;
- `ReadTimeout`;
- `WriteTimeout`;
- `IdleTimeout`;
- request body limits;
- graceful shutdown with context cancellation.

Also propagate request contexts to database calls and external HTTP clients.
