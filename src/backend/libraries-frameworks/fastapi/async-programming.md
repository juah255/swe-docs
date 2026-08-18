# Async Programming

This deserves its own section because FastAPI heavily uses asynchronous programming. Since you have already studied Python async concepts, focus on how async interacts with FastAPI and its ASGI server.

## async / await

`async def` defines a coroutine; `await` suspends it without blocking the event loop.

```python
import asyncio

async def fetch():
    await asyncio.sleep(0.1)   # yield control, other tasks run
    return "data"

async def main():
    result = await fetch()
```

In FastAPI, `async def` endpoints run on the event loop; `def` endpoints run in
a threadpool.

## Event loop

The event loop schedules coroutines and callbacks on a single thread. When a
coroutine awaits I/O, the loop runs other ready work instead of idling. This is
how one process serves thousands of concurrent connections.

```
event loop
 ├── coroutine A (awaiting DB)
 ├── coroutine B (awaiting HTTP)
 ├── coroutine C (running)
 └── timers / callbacks
```

## Coroutines

A coroutine is a function that can suspend and resume. `await` inside it yields
control; the loop resumes it when the awaited operation completes. All
concurrency in a single process shares this one loop, so blocking it stalls
everything.

## Blocking vs non-blocking I/O

- **Blocking I/O** - the calling thread waits for the operation (sync DB driver,
  `requests.get`, `open().read()`). In an async context this freezes the loop.
- **Non-blocking I/O** - the operation signals completion and control returns
  immediately; the caller awaits the result (`asyncpg`, `httpx.AsyncClient`,
  `aiofiles`).

The event loop only stays fast when every awaited operation is non-blocking.

## How FastAPI dispatches endpoints

```python
@app.get("/sync")
def sync_endpoint():       # runs in the threadpool
    ...

@app.get("/async")
async def async_endpoint():  # runs on the event loop
    await ...
```

- `def` endpoints run in a threadpool (via anyio), so blocking code does not
  freeze the loop, but thread switching adds overhead.
- `async def` endpoints run directly on the loop. If they call blocking code,
  the entire loop - and every concurrent request - blocks.

## Async database drivers

Use async drivers end to end:

```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

engine = create_async_engine("postgresql+asyncpg://user:pass@db/mydb")
AsyncSessionLocal = async_sessionmaker(engine)

async def get_user(user_id: int, db: AsyncSession):
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()
```

Async DB code requires `async def` endpoints and `await` on every query.

## Async HTTP clients

```bash
pip install httpx
```

```python
import httpx

async def call_external():
    async with httpx.AsyncClient() as client:
        resp = await client.get("https://api.example.com/data")
        return resp.json()
```

Never use `requests.get` inside an `async def` endpoint - it blocks the loop.

## asyncio

```python
import asyncio

async def worker(name: str):
    await asyncio.sleep(1)
    return name

async def main():
    results = await asyncio.gather(worker("a"), worker("b"))
    return results
```

Key APIs: `asyncio.gather` (run several coroutines), `asyncio.create_task`
(schedule in background), `asyncio.Semaphore` (limit concurrency), `asyncio.timeout`.

## Thread pool

`def` endpoints and sync dependencies run in a threadpool. FastAPI sizes it via
`anyio`. Sync code in the threadpool does not block the loop, but:

- Threads add memory and context-switch overhead.
- The threadpool can become the bottleneck under high concurrency.
- Don't spawn unbounded threads; right-size the pool.

Offload blocking work explicitly when needed:

```python
import anyio

result = await anyio.to_thread.run_sync(blocking_function)
```

## Process pool

Use multiple processes for CPU-bound work:

- `ProcessPoolExecutor` for parallel computation.
- Gunicorn/uvicorn `--workers N` for multiple app processes.
- Task queues (Celery) for heavy batch work.

Processes bypass the GIL but cost memory and IPC overhead.

## When not to use async

- **CPU-bound work** - Python's GIL serializes CPU-bound tasks even in threads;
  async does not help. Use processes or a task queue (Celery).
- **Blocking libraries without async alternatives** - if the ecosystem only has
  sync drivers, keep endpoints `def` so they run in the threadpool.
- **Simple/small apps** - the complexity may not pay off.

```python
# CPU-bound: do NOT run on the event loop
@app.get("/report")
def generate_report():
    result = heavy_cpu_work()   # runs in threadpool, but still ties up a thread
    return result

# Better: offload to a worker process / Celery
```

## CPU-bound vs I/O-bound workloads

- **I/O-bound** (DB queries, HTTP calls, file I/O) - dominated by waiting;
  async shines because the loop interleaves many pending I/O operations.
- **CPU-bound** (PDF generation, image processing, parsing, ML inference) -
  dominated by computation; async does not help, use processes or task queues.

Profile to find the actual bottleneck before optimizing.

## Mid/Senior Interview Questions and Answers

### 1. Why does marking an endpoint `async def` not automatically make it scalable?

**Answer:** `async def` only lets the event loop interleave work while the
handler awaits. If anything inside the handler blocks - a sync database driver,
`requests.get`, file reads - the event loop stalls for that whole duration and
every concurrent request sharing the loop queues behind it.

For real scalability the whole path must be async end to end: async database
drivers (asyncpg, SQLAlchemy `AsyncSession`), async HTTP clients
(`httpx.AsyncClient`), and connection pooling. CPU-bound work should be
offloaded to a task queue such as Celery, not run on the event loop.

### 2. What is the difference between running a `def` and an `async def` endpoint?

**Answer:** `def` endpoints run in a threadpool managed by anyio, so blocking
code inside them does not freeze the event loop but pays thread overhead.
`async def` endpoints run directly on the event loop; they are efficient for
I/O-bound work but any blocking call stalls all concurrent requests on that
worker.

### 3. When should you use `asyncio.gather` vs `create_task`?

**Answer:** Use `gather` to run a fixed set of coroutines and collect their
results together. Use `create_task` to schedule work that continues in the
background while the current coroutine does something else. Both allow concurrent
execution of I/O-bound work; `gather` is simpler for "run these, wait for all".

### 4. How do you handle blocking code in an async app?

**Answer:** Route it to a threadpool with `anyio.to_thread.run_sync` or keep the
endpoint as `def`. If the blocking work is heavy or long-running, move it to a
task queue (Celery) with dedicated workers. Never run blocking code directly on
the event loop inside `async def` endpoints.

### 5. Why does async not help with CPU-bound work?

**Answer:** Async helps when work is I/O-bound - waiting on the database,
network, or disk. CPU-bound work consumes the CPU continuously, and the event
loop has nothing to interleave; concurrency just switches between tasks that are
all using the CPU. Python's GIL further serializes CPU-bound threads. Use
processes or a task queue instead.