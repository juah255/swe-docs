# Production & Deployment

Learn how to actually deploy your applications: environment configuration, Docker, Nginx, HTTPS, process management, logging, health checks, monitoring, CI/CD, and secrets.

## Environment configuration

Load and validate configuration at startup (see [Pydantic settings](pydantic.md#pydantic-settings)):

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="APP_")

    database_url: str
    redis_url: str
    jwt_secret: str
    environment: str = "development"
    debug: bool = False

settings = Settings()
```

Fail fast on missing required variables. Keep a `.env.example` and never commit
real secrets.

## Docker

A production Dockerfile:

```dockerfile
FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

FROM python:3.12-slim

WORKDIR /app
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/*

COPY . .

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
EXPOSE 8000

CMD ["gunicorn", "main:app", "--worker-class", "uvicorn.workers.UvicornWorker", "--workers", "4", "--bind", "0.0.0.0:8000"]
```

Multi-stage builds keep the runtime image small. Run as a non-root user when
possible.

## Docker Compose

A local stack:

```yaml
services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      APP_DATABASE_URL: postgresql+asyncpg://app:app@db:5432/app
      APP_REDIS_URL: redis://redis:6379/0
    depends_on:
      - db
      - redis

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app
      POSTGRES_DB: app
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

volumes:
  pgdata:
```

## Nginx

Nginx terminates TLS, serves static files, compresses, and proxies to the app:

```nginx
server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate     /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## HTTPS

- Get certificates with **Let's Encrypt** (Certbot) or a provider.
- Auto-renew with `certbot renew`.
- Redirect HTTP → HTTPS.
- Use `HSTS` header and secure TLS settings.
- The app should trust the proxy headers (`trusted_hosts`, forwarded proto) so
  URLs and cookies are correct behind TLS.

## Domain configuration

- Point an A/AAAA record (or CNAME) at the server IP.
- Use a subdomain per environment: `api.example.com`, `staging.example.com`.
- Configure DNS before applying for certificates.

## Uvicorn/Gunicorn

Production command:

```bash
gunicorn main:app \
  --worker-class uvicorn.workers.UvicornWorker \
  --workers 4 \
  --bind 127.0.0.1:8000 \
  --timeout 120 \
  --access-logfile - \
  --error-logfile -
```

See [Performance & Scalability](performance-and-scalability.md) for worker
sizing.

## Process management

Manage the app process with `systemd` (VPS):

```ini
[Unit]
Description=FastAPI app
After=network.target

[Service]
User=app
WorkingDirectory=/opt/app
ExecStart=/opt/app/venv/bin/gunicorn main:app --worker-class uvicorn.workers.UvicornWorker --workers 4 --bind 127.0.0.1:8000
Restart=always
RestartSec=5
EnvironmentFile=/opt/app/.env

[Install]
WantedBy=multi-user.target
```

Or run containers under an orchestrator (Docker Compose, Kubernetes).

## Logging

Structured logs with request IDs:

```python
import logging
import json

class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        return json.dumps({
            "time": self.formatTime(record),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        })

handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logging.getLogger().addHandler(handler)
```

Log at `INFO` in production, include request IDs, and send logs to a central
system (Loki, ELK, Datadog).

## Health checks

Expose `/health` for load balancers and orchestrators:

```python
@app.get("/health")
async def health():
    await db.execute(text("SELECT 1"))
    return {"status": "ok"}
```

Readyness checks should verify the dependencies (DB, Redis). The reverse proxy
and load balancer poll it to route around unhealthy instances.

## Monitoring

- **Metrics**: request latency (p50/p95/p99), error rates, throughput, queue
  depth, DB connection usage, CPU/memory.
- **Tools**: Prometheus + Grafana (`prometheus-fastapi-instrumentator`),
  Sentry for errors, structured logs for debugging.
- **Alerts**: error-rate spikes, high p95, disk/memory pressure, DB saturation.

```bash
pip install prometheus-fastapi-instrumentator
```

```python
from prometheus_fastapi_instrumentator import Instrumentator

Instrumentator().instrument(app).expose(app)
```

## CI/CD

A GitHub Actions workflow:

```yaml
name: CI/CD
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: app_test
          POSTGRES_USER: app
          POSTGRES_PASSWORD: app
        ports: ["5432:5432"]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements-dev.txt
      - run: pytest
        env:
          APP_DATABASE_URL: postgresql+asyncpg://app:app@localhost:5432/app_test
      - run: docker build -t app .
      - uses: docker/build-push-action@v5
        with:
          push: true
          tags: registry.example.com/app:latest

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: ssh deploy@server "cd /opt/app && docker compose pull && docker compose up -d"
```

Deploy after tests pass: build image → push to registry → rolling restart.

## VPS deployment

A simple production layout on a VPS:

1. Install Docker and Nginx.
2. Clone the app, configure `.env` (secrets from a manager).
3. `docker compose up -d` for app + db + redis.
4. Point Nginx (or Caddy) at the app container with Let's Encrypt TLS.
5. Wire CI/CD to build, push, and `docker compose pull && up -d`.
6. Add monitoring (health checks, Prometheus, Sentry) and backups (pg_dump).

## Secrets management

- Never hardcode or commit secrets.
- Use environment variables injected by the platform.
- Use a secrets manager (Vault, AWS Secrets Manager) for rotation.
- Use `SecretStr` for secret fields so they do not leak into logs.
- Rotate JWT signing keys and DB credentials on rotation schedule.

## Mid/Senior Interview Questions and Answers

### 1. How do you deploy a FastAPI app to production?

**Answer:** Build a multi-stage Docker image, run it with Gunicorn +
UvicornWorker (or multiple uvicorn workers) behind Nginx with TLS, front the
database and Redis as services, and set up systemd or an orchestrator for process
management. Add health checks, structured logging, monitoring, CI/CD with tests,
and secret management. Deploy via rolling restarts to avoid downtime.

### 2. Why run the app behind Nginx instead of exposing uvicorn directly?

**Answer:** Nginx terminates TLS, serves static files, compresses responses,
buffers slow clients, rate limits, and load balances across workers/instances.
Exposing uvicorn directly forces the app to handle these concerns and typically
binds to privileged ports without a proxy. The proxy also centralizes security
headers and TLS config.

### 3. How do you handle environment-specific configuration?

**Answer:** Use Pydantic `Settings` with an env file, validate required values
and fail fast at startup. Keep code free of hardcoded values. In production,
inject environment variables/secrets from the platform. Use `.env.example` to
document variables and never commit real values.

### 4. What does a good health check include?

**Answer:** A liveness check that the process responds, plus a readiness check
that verifies dependencies - database connectivity (`SELECT 1`), Redis ping,
external services. Load balancers and orchestrators use readiness to stop
traffic to degraded instances and liveness to restart hung processes. Include
version/commit and uptime metadata if useful.

### 5. How do you monitor a FastAPI app in production?

**Answer:** Export metrics with `prometheus-fastapi-instrumentator` (latency,
error rates, request counts), send errors to Sentry, and use structured JSON
logs with request IDs. Track p95/p99 latency, error rate, throughput, queue
depth, and DB connection usage, with alerts on spikes and resource pressure.
Correlate logs, metrics, and traces with a single request ID.