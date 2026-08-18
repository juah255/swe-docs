# Performance & Scalability

After you understand the framework, study how to run it efficiently: servers, workers, connection pooling, caching, N+1, load balancing, and the deployment topology.

## The architecture at scale

```
Internet
   ↓
Nginx (reverse proxy, TLS, static, compression)
   ↓
FastAPI
   ↓
Multiple Workers
   ↓
PostgreSQL / Redis
```

## Uvicorn

Uvicorn is the ASGI server that runs the FastAPI app:

```bash
uvicorn main:app --workers 4 --host 0.0.0.0 --port 8000
```

- `--workers N` spawns N processes (not threads) sharing the load.
- Each worker has its own event loop and runs many concurrent requests.
- `--reload` is development-only; never in production.

## Gunicorn

Gunicorn is a production process manager that can run uvicorn workers:

```bash
pip install gunicorn uvicorn
```

```bash
gunicorn main:app \
  --worker-class uvicorn.workers.UvicornWorker \
  --workers 4 \
  --bind 0.0.0.0:8000 \
  --timeout 120
```

- `UvicornWorker` runs the async event loop per worker.
- Set workers = ~2-4 per CPU core (rule of thumb: 2×cores+1).
- Gunicorn adds worker management, graceful restarts, and timeouts.

## Multiple workers

Multiple worker processes let the app use multiple CPU cores and survive a
single worker crash. Considerations:

- Shared in-memory state is lost - use Redis for caches/sessions/queues.
- Database connection pools must account for total connections across workers.
- Logs should go to a central place, not only per-process stdout.
- Horizontal scaling adds more machines behind a load balancer.

## Connection pooling

- SQLAlchemy pools connections per worker (`pool_size`, `max_overflow`).
- With N workers, total DB connections = N × (pool_size + max_overflow).
- For many workers, front the DB with **PgBouncer** (transaction mode) to share
  a small pool of real connections.
- Use `pool_pre_ping=True` to drop stale connections.
- Redis connections also pool; reuse a single client.

## Database optimization

- Add indexes for every filter/sort/join column; verify with `EXPLAIN ANALYZE`.
- Paginate every list endpoint (no unbounded scans).
- `SELECT` only needed columns; avoid `SELECT *`.
- Keep transactions short.
- Tune `work_mem`, `shared_buffers`, and connection limits for your workload.
- Use read replicas for heavy read traffic (route reads to replicas).

## Redis caching

Cache hot reads to cut database load:

```python
import redis.asyncio as redis

cache = redis.from_url(settings.redis_url, decode_responses=True)

@app.get("/products/{product_id}")
async def get_product(product_id: int):
    cached = await cache.get(f"product:{product_id}")
    if cached:
        return json.loads(cached)
    product = await service.get(product_id)
    await cache.set(f"product:{product_id}", json.dumps(product, default=str), ex=60)
    return product
```

Cache strategies:

- **Cache-aside** - read cache, fall back to DB, write back with TTL.
- **Invalidate on write** - delete keys when the entity changes.
- TTL everything; keep cache keys versioned (`v1:product:{id}`).

## Async performance

- Keep the whole path async: async DB drivers (`asyncpg`), async HTTP
  (`httpx.AsyncClient`), async Redis.
- Avoid blocking calls in `async def` endpoints.
- Use `asyncio.gather` for independent I/O to reduce latency.
- Limit concurrency with semaphores where external services have caps.

## N+1 queries

The N+1 problem: loading a list then issuing one query per row for related
data. Fix with eager loading:

```python
from sqlalchemy.orm import selectinload

stmt = select(User).options(selectinload(User.posts))
users = (await db.execute(stmt)).scalars().all()
```

Batch with `WHERE id IN (...)` when eager loading is not possible. Check query
counts with SQLAlchemy logging (`echo=True` or event listeners).

## Load balancing

Distribute traffic across instances:

- Nginx `upstream` with `least_conn` / `ip_hash`.
- Cloud load balancers (AWS ALB/ELB, GCP LB) for auto-scaling groups.
- Keep health checks on `/health` so the balancer drops unhealthy instances.
- Sessions and WebSockets may need sticky sessions; prefer stateless (JWT).

## Horizontal scaling

Scale by adding instances, not just workers:

- Stateless API (JWT, no in-memory session) scales trivially.
- Shared state moves to Redis/PostgreSQL.
- Auto-scale on CPU, latency, or request count.
- Database becomes the bottleneck - scale reads with replicas, use caching, and
  queue heavy writes.

## Reverse proxy / Nginx

Nginx in front of the app:

```nginx
upstream fastapi {
    least_conn;
    server 127.0.0.1:8000;
    server 127.0.0.1:8001;
}

server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://fastapi;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Benefits: TLS termination, compression, static file serving, request buffering,
rate limiting, and load balancing.

## Docker

Containerize for consistent deployment:

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["gunicorn", "main:app", "--worker-class", "uvicorn.workers.UvicornWorker", "--workers", "4", "--bind", "0.0.0.0:8000"]
```

Run multiple container replicas behind the load balancer to scale horizontally.

## Mid/Senior Interview Questions and Answers

### 1. How would you design a scalable FastAPI app for thousands of concurrent requests?

**Answer:** Run multiple uvicorn/Gunicorn workers behind a reverse proxy and
load balancer. Keep the code async end to end with async DB/HTTP/Redis clients
and connection pooling. Add Redis caching for hot reads, move CPU-heavy and
long-running work to Celery, and add rate limiting, timeouts, and backpressure.
Monitor p95/p99 latency, error rates, throughput, CPU/memory, and DB connection
usage.

### 2. How many workers should you run?

**Answer:** A common rule is 2×CPU cores + 1 for CPU-bound workloads; tune
downward for I/O-bound async apps because each async worker already handles many
concurrent requests. More workers mean more memory and more database
connections, so balance against connection pool limits and memory.

### 3. Why use a reverse proxy in front of uvicorn?

**Answer:** A reverse proxy (Nginx) handles TLS termination, static files,
compression, request buffering, and rate limiting, and can load balance across
multiple uvicorn workers or instances. Uvicorn focuses on serving the app;
production traffic management belongs at the proxy layer.

### 4. How do you prevent N+1 queries?

**Answer:** Eager load relations with `selectinload`/`joinedload` so related
rows come in the same query, or batch with `WHERE id IN (...)`. Profile with
SQLAlchemy query logging to count queries per request. N+1 is the most common
cause of slow list endpoints.

### 5. What is the difference between scaling workers and scaling instances?

**Answer:** Workers are processes within one machine, sharing CPU and memory and
bounded by them; they also multiply database connections. Instances are separate
machines/containers scaled by a load balancer. Stateless apps scale best - put
shared state in Redis/PostgreSQL and let the load balancer distribute traffic
across as many instances as needed.