# Async and Background Tasks

Async request handling and background job processing solve different problems.
An async view can wait efficiently during one request; a task queue runs durable
work outside that request.

## WSGI and ASGI

Django supports both deployment interfaces:

- **WSGI** is the traditional synchronous interface.
- **ASGI** supports async request handling, long-lived connections through
  compatible components, and efficient I/O concurrency.

An async view provides its full benefit under ASGI with an async-capable server
and middleware stack.

```python
import httpx
from django.http import JsonResponse


async def exchange_rate(request):
    async with httpx.AsyncClient(timeout=2.0) as client:
        response = await client.get("https://example.net/rates/latest")
        response.raise_for_status()
    return JsonResponse(response.json())
```

Async is useful when a request spends time waiting on compatible network I/O.
It does not make CPU-heavy Python work faster. Move CPU-heavy or long-running
work to an appropriate worker.

## Async ORM Usage

QuerySet methods that execute SQL generally have an `a`-prefixed async variant,
and querysets can be consumed with `async for`:

```python
order = await Order.objects.select_related("customer").aget(pk=order_id)

async for item in order.items.all():
    process_item(item)
```

Methods that only build a queryset remain synchronous because they do not issue
I/O. Deferred model fields must not be loaded implicitly from async code.

Django's transaction management does not currently work directly in async mode.
Put the transactional unit in a synchronous function and call it through
`sync_to_async()`:

```python
from asgiref.sync import sync_to_async
from django.db import transaction


@transaction.atomic
def place_order_sync(customer, lines):
    ...


async def place_order_async(customer, lines):
    return await sync_to_async(place_order_sync)(customer, lines)
```

Do not call sync-only Django APIs directly from an async context. Do not disable
async-safety checks as a production workaround.

## Blocking Work and Timeouts

One blocking database driver, HTTP client, filesystem call, or middleware layer
can erase the concurrency advantage of an async path. Use async-compatible
libraries, impose timeouts, and keep concurrency bounded. An unlimited
`gather()` over user-sized input can overload a downstream service.

## Background Jobs

Use a durable job system for email, report generation, media processing,
webhooks, scheduled work, and operations that must survive process restarts.

Django 6.0 introduced a Tasks framework that defines tasks, accepts queue
options, enqueues work, and exposes result metadata. It intentionally does not
provide the production worker mechanism. A production deployment still needs a
compatible backend and infrastructure that executes queued work. Older Django
versions commonly integrate a third-party system such as Celery, RQ, or Dramatiq.

Built-in immediate or dummy task backends are useful for development and tests,
not for production execution.

## Reliable Task Design

Queue a job only after its related database write commits:

```python
from django.db import transaction


with transaction.atomic():
    order = create_order(...)
    transaction.on_commit(lambda: send_confirmation.enqueue(order.id))
```

Design jobs around these properties:

- **Idempotency:** repeating the task does not corrupt state or duplicate an
  external effect.
- **Bounded retries:** retry transient failures with backoff and jitter; do not
  retry permanent validation errors.
- **Timeouts:** every network operation has a deadline.
- **Small payloads:** pass stable identifiers, not serialized model instances.
- **Observability:** record job IDs, attempts, duration, and final failure.
- **Isolation:** route slow or high-risk tasks away from latency-sensitive work.

Starting an in-process thread, using `asyncio.create_task()`, or relying on a
request worker after the response is not durable background processing.

