# Background Tasks & Job Queues

Learn the difference between simple background work and proper distributed jobs.

## BackgroundTasks

`BackgroundTasks` runs lightweight work after the response is sent:

```python
from fastapi import BackgroundTasks

def send_welcome_email(email: str):
    send_email(email)   # runs after the response

@app.post("/users", status_code=201)
def create_user(user: UserCreate, background: BackgroundTasks):
    create_in_db(user)
    background.add_task(send_welcome_email, user.email)
    return user
```

The client gets the response immediately; the task runs after. Only async task
functions are awaited; sync functions run in the threadpool.

## When to use BackgroundTasks

Use `BackgroundTasks` for:

- Sending emails and notifications
- Logging / analytics events
- Light cache warming
- Small webhook payloads

Do **not** use it for:

- Long-running or CPU-heavy work (PDF, video, ML inference)
- Work that must be durable across restarts
- Work that needs retries, priorities, or scheduling

Background tasks live in the request process. If the worker crashes or the
deploy restarts, in-flight tasks are lost, and running many heavy tasks inside
the API process degrades request latency.

## Celery

Celery is a distributed task queue:

```bash
pip install celery redis
```

```python
from celery import Celery

celery_app = Celery(
    "app",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/1",
)

@celery_app.task(bind=True, max_retries=3)
def generate_report(self, user_id: int):
    try:
        build_pdf(user_id)
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)
```

Call from the app:

```python
from app.workers import generate_report

@app.post("/reports")
def create_report(user_id: int):
    task = generate_report.delay(user_id)   # enqueue, return immediately
    return {"task_id": task.id}
```

Run a worker:

```bash
celery -A app.workers.celery_app worker --loglevel=info --concurrency=4
```

## Redis

Redis is the default broker and result backend for Celery, and a high-performance
cache. Tasks are serialized and stored in Redis; workers poll and consume them.
Redis also stores task results for status lookups.

```python
CELERY_BROKER_URL = "redis://localhost:6379/0"
CELERY_RESULT_BACKEND = "redis://localhost:6379/1"
```

## RabbitMQ

RabbitMQ is an alternative message broker with durable queues, exchanges, and
routing:

```python
CELERY_BROKER_URL = "amqp://guest:guest@localhost:5672//"
```

Choose RabbitMQ when you need durable messaging, acknowledgments, and complex
routing; choose Redis when you already run Redis and need simplicity.

## Task queues

A task queue decouples request handling from heavy work:

```
API process                 Worker processes
   │                             │
   │ task.delay(data)            │
   ├─────────────► broker ───────┤
   │  (returns fast)             │  consume → execute → result
   ▼                             ▼
```

Properties of a good task queue:

- **Durability** - tasks survive worker crashes (persisted in the broker).
- **Retries** - `max_retries`, exponential `backoff`.
- **Idempotency** - re-running a task must not corrupt state.
- **Observability** - monitor queue depth, failure rates, task durations.
- **Dead-letter** - permanently failed tasks go to a DLQ for inspection.

## Scheduled jobs

Celery beat schedules periodic tasks:

```python
from celery.schedules import crontab

celery_app.conf.beat_schedule = {
    "cleanup-expired-sessions": {
        "task": "app.workers.cleanup_expired_sessions",
        "schedule": crontab(hour=3, minute=0),   # daily 03:00
    },
}
```

Run:

```bash
celery -A app.workers.celery_app beat
```

For simple in-process scheduling, `asyncio` timers or APScheduler work, but
Celery beat survives restarts and works across workers.

## Long-running jobs

For tasks that run minutes or hours:

- Keep tasks idempotent and resumable.
- Store progress in the result backend or a database.
- Use worker time limits and soft time limits.
- Scale dedicated worker pools per queue.
- Consider job steps / chunked work for huge batches.

## Why not BackgroundTasks for everything?

- Background tasks are not durable - crash or deploy loses them.
- They run inside the API process - heavy work hurts request latency.
- No retries, priorities, or concurrency control.
- They cannot scale independently from the API.

Use Celery (or RQ/Arq) when work must be reliable, retryable, or long-running.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between `BackgroundTasks` and Celery?

**Answer:** `BackgroundTasks` runs lightweight side effects after the response in
the same process - fast, but not durable, retryable, or scalable. Celery is a
distributed queue with a broker (Redis/RabbitMQ), workers, retries, scheduling,
and priorities. Use BackgroundTasks for simple side effects; use Celery for
reliable, long-running, or CPU-heavy work.

### 2. How do you make background tasks reliable?

**Answer:** Use a task queue with a durable broker, configure `max_retries` and
exponential backoff, make tasks idempotent, and route permanently failed tasks
to a dead-letter queue. Monitor queue depth, task duration, and failure rates.
Background tasks in-process cannot offer these guarantees.

### 3. What happens if a worker crashes mid-task?

**Answer:** With a durable broker, the task is not lost - it can be re-queued or
acknowledged only on completion (Celery tasks are acknowledged after success by
default with `acks_late=True`). The task may run again, so handlers must be
idempotent. With in-process `BackgroundTasks`, a crash loses the work entirely.

### 4. How do you schedule periodic jobs?

**Answer:** Use Celery beat with `crontab` schedules for distributed, durable
cron. For simple in-process timing, use asyncio timers or APScheduler. Prefer
Celery beat when jobs must run reliably, retry, or be visible across workers.

### 5. How do you handle long-running tasks like PDF generation?

**Answer:** Enqueue the job to Celery and return a task ID; the client polls the
task status or is notified via webhook/WebSocket. Store progress and results in
the result backend, set time limits, scale dedicated workers for that queue, and
make the task resumable/idempotent so retries do not duplicate work.