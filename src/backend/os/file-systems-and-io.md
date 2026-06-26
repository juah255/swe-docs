# File Systems and I/O

Backend services live and die by I/O: reading config, writing logs, talking to
databases, and serving thousands of network connections. The OS exposes all of
this through a small set of file and I/O abstractions worth understanding deeply.

## Files and Inodes

On Unix-like systems, file content and metadata are tracked by an **inode**: it
holds size, ownership, permissions, timestamps, and pointers to data blocks — but
not the filename. **Directories** map names to inode numbers. This is why a single
file can have multiple names (**hard links**) and why deleting a name does not
free space until the last link and last open handle are gone.

```text
filename -> directory entry -> inode -> data blocks
```

Running out of **inodes** is its own failure mode: a disk can show free space yet
refuse new files because every inode is used (often millions of tiny files).

## File Descriptors

A **file descriptor (fd)** is a small integer the kernel gives a process to refer
to an open file, socket, pipe, or device. Every process starts with three:

- `0` — standard input
- `1` — standard output
- `2` — standard error

Each open resource consumes an fd. They are a per-process (and system-wide)
limited resource.

## Permissions

Unix permissions control access via three classes — **owner**, **group**,
**other** — each with read (`r`), write (`w`), execute (`x`) bits:

```text
-rwxr-x---   owner: rwx   group: r-x   other: ---
```

For services this decides whether the process can read its config, write logs,
execute binaries, and access mounted volumes. Run with least privilege; avoid
root unless the workload genuinely requires it.

## Blocking vs Non-Blocking I/O

- **Blocking**: a `read()`/`write()` call suspends the thread until data is ready
  or the operation completes. Simple, but one slow connection ties up a thread.
- **Non-blocking**: the call returns immediately; if no data is ready it reports
  "would block" and the program checks again later (usually via a readiness API).

Non-blocking I/O lets a single thread juggle many connections, which is the basis
of high-concurrency servers.

## Synchronous vs Asynchronous I/O

These are related but distinct from blocking/non-blocking:

- **Synchronous**: the caller waits for the result of the operation.
- **Asynchronous**: the caller starts the operation and is notified later
  (callback, future, completion event) when it finishes.

```text
Blocking      : ask, and sleep until done
Non-blocking  : ask, get "not ready", poll again
Asynchronous  : ask, get notified when it completes
```

Async models scale better for I/O-bound work because threads are never parked
waiting on a single slow operation.

## Buffering

The OS and libraries **buffer** I/O to reduce syscall and disk overhead: small
writes accumulate and flush in larger chunks. This boosts throughput but means
data may not be durable until **flushed** (`fsync`). Crash-safety-sensitive code
must flush explicitly; debugging output can be lost if a process dies before its
buffer flushes.

## The "Too Many Open Files" Problem

Each connection, file, and pipe holds an fd. When a process exceeds its fd limit
(`ulimit -n`), new `accept()`/`open()` calls fail with `EMFILE` — surfacing as
"too many open files" and dropped connections under load. Causes and fixes:

- **Leaked descriptors**: connections or files never closed — fix the leak.
- **Limit too low**: raise `ulimit -n` / systemd `LimitNOFILE` for high-concurrency
  servers.
- **Connection churn**: use pooling and keep-alive instead of opening per request.

## I/O Models: select / poll / epoll

To watch many descriptors with one thread, the OS provides readiness APIs:

| API      | How it scales        | Notes                                         |
| -------- | -------------------- | --------------------------------------------- |
| `select` | O(n) per call        | Old, portable, capped fd set size             |
| `poll`   | O(n) per call        | No fd cap, still scans all fds each call       |
| `epoll`  | O(active) events     | Linux; scales to many idle connections        |

`select` and `poll` rescan every descriptor on each call, so cost grows with the
total connection count. `epoll` (Linux) and `kqueue` (BSD/macOS) register
interest once and return only the descriptors that are actually ready, which is
why event-driven servers handling tens of thousands of mostly-idle connections
rely on them.

## Mid/Senior Interview Questions and Answers

### 1. What causes "too many open files" and how do you fix it?

**Answer:** It means the process hit its file-descriptor limit because open
sockets, files, or pipes were not closed, or the limit is too low for the
concurrency level. New connections then fail with `EMFILE`.

Fix it by closing descriptors reliably (defer/finally/with), pooling connections
instead of opening per request, and raising `ulimit -n` or `LimitNOFILE` for
legitimately high-concurrency services. Monitor open-fd count to catch leaks
early.

### 2. How do blocking, non-blocking, and async I/O differ?

**Answer:** Blocking parks the thread until the operation completes.
Non-blocking returns immediately and signals "not ready" so the caller retries
via a readiness check. Asynchronous starts the operation and delivers a
completion notification later.

The practical impact is concurrency: blocking I/O needs a thread per in-flight
operation, while non-blocking and async models let one thread manage many
connections, which is essential for I/O-bound servers.

### 3. Why is epoll preferred over select for high-concurrency servers?

**Answer:** `select` and `poll` rescan the entire set of watched descriptors on
every call, so cost grows linearly with total connections even when few are
active. With tens of thousands of mostly-idle sockets, that dominates CPU.

`epoll` registers interest once and returns only ready descriptors, scaling with
the number of active events rather than total connections. That efficiency is why
event-driven servers use epoll (or kqueue on BSD).

### 4. Why might logs or written data be lost after a crash?

**Answer:** I/O is buffered for performance, so writes sit in application or OS
buffers and are not durable until flushed to disk. If the process or machine
crashes before a flush, buffered data is lost.

For durability-critical writes, flush explicitly (`fsync`/`flush`) and design for
it; for logs, accept some loss or use a logging pipeline that flushes promptly.
Understand that "write returned" is not the same as "on disk."

### 5. A disk shows free space but new files fail to create. Why?

**Answer:** The filesystem likely ran out of inodes even though data blocks are
free. Each file consumes an inode, and a workload with millions of tiny files can
exhaust them while leaving space unused.

Check inode usage (`df -i`), then clean up or consolidate small files, or
recreate the filesystem with more inodes. It is a classic surprise on cache and
session directories full of tiny files.
