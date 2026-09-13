# Concurrency

Go makes concurrent execution accessible through goroutines, channels, and the
`sync` package. These tools do not remove the need for ownership, cancellation,
backpressure, and a clear policy for errors.

## Goroutines and Runtime Scheduling

A goroutine is a lightweight unit of execution managed by the Go runtime. The
runtime schedules goroutines across operating-system threads and available
processors, multiplexing many runnable goroutines as execution and blocking
conditions change.

The scheduler is often described with:

- **G**: a goroutine;
- **M**: an operating-system thread;
- **P**: a runtime processor that holds resources needed to run Go code.

This is an implementation model, not an application API. Application design
should focus on goroutine lifetime and resource bounds.

Starting a goroutine transfers responsibility for stopping it and observing its
failure:

```go
go func() {
    if err := consume(ctx); err != nil {
        errors <- err
    }
}()
```

Do not start background goroutines without an owner, shutdown path, and error
policy.

## Channels

Channels communicate typed values and synchronize goroutines.

- An unbuffered send waits for a receiver.
- A buffered send waits only when the buffer is full.
- A receive waits when no value is available.
- Receiving from a closed and drained channel returns the element type's zero
  value immediately, with `ok == false` in the two-value form.

```go
job, ok := <-jobs
if !ok {
    return
}
```

The sender that knows no more values will be produced should close the channel.
Closing is not required for garbage collection, and a receiver should not close
a channel merely to signal that it is finished consuming.

Sending on a closed channel or closing an already closed channel panics.

## Channel Direction

Directional types document ownership:

```go
func produce(ctx context.Context, output chan<- Job) error
func consume(ctx context.Context, input <-chan Job) error
```

They prevent accidental receives or sends but do not enforce which goroutine
closes a channel. Keep that lifecycle visible in the surrounding design.

## `select`

`select` waits until a channel operation can proceed:

```go
select {
case job, ok := <-jobs:
    if !ok {
        return nil
    }
    return process(job)
case <-ctx.Done():
    return ctx.Err()
}
```

A `default` case makes the select non-blocking and can create a busy loop. Use
it only when dropping or polling is an intentional policy.

A nil channel case never becomes ready. This can be useful for enabling and
disabling cases, but accidental nil channels cause goroutines to wait forever.

## Context

`context.Context` carries cancellation, deadlines, and limited request-scoped
metadata across API boundaries.

Conventions:

- accept it as the first parameter, usually named `ctx`;
- do not store it in a long-lived struct;
- pass it to database, HTTP, queue, and child operations;
- call the cancel function returned by derived contexts;
- use context values only for request-scoped metadata, not optional parameters;
- never pass `nil`; use `context.Background()` when no parent exists.

Cancellation is cooperative. A goroutine must observe `ctx.Done()` directly or
call an API that does.

## Mutexes and Shared State

Use a mutex when several goroutines need coordinated access to shared state:

```go
type Counter struct {
    mu    sync.Mutex
    value int64
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}
```

Do not copy a value containing a mutex after it has been used. Keep the protected
fields and mutex together, and make the lock scope as small as correctness
allows.

`sync.RWMutex` helps only when read concurrency outweighs its extra overhead
and write contention. Measure before replacing a regular mutex.

## Data Races and Logical Races

A data race occurs when goroutines access the same memory concurrently, at least
one access writes, and there is no synchronization. Use the race detector in
tests and representative integration workloads.

Race-free code can still have logical races. For example, checking an account
balance and then updating it in separate locked operations may allow another
goroutine to change the balance between them. Protect the entire invariant or
move it into an atomic storage transaction.

## Worker Pools and Backpressure

A worker pool bounds active work:

```go
func worker(ctx context.Context, jobs <-chan Job, results chan<- Result) {
    for {
        select {
        case <-ctx.Done():
            return
        case job, ok := <-jobs:
            if !ok {
                return
            }
            result := process(ctx, job)
            select {
            case results <- result:
            case <-ctx.Done():
                return
            }
        }
    }
}
```

Bound the input queue as well as the worker count. An unbounded queue only moves
overload from execution to memory and latency.

## Goroutine Leaks

A leaked goroutine waits forever because no event can release it. Common causes
include:

- sending when no receiver remains;
- receiving from a channel that is never closed;
- waiting on I/O without a deadline;
- losing the cancel function;
- returning before a child goroutine reports its result.

Monitor goroutine counts, write tests that cancel operations, and capture
goroutine profiles when counts grow unexpectedly.

## Concurrency Design Rules

- Start no goroutine without knowing how it stops.
- Prefer ownership transfer over uncontrolled shared mutation.
- Propagate cancellation and deadlines.
- Bound goroutines, queues, connections, and fan-out.
- Close channels from the producing side when closure conveys completion.
- Use synchronization around complete invariants, not individual statements.
