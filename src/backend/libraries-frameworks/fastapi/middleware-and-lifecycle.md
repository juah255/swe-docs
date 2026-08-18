# Middleware & Request Lifecycle

Understand what happens to a request, and where middleware fits in.

## The request lifecycle

```
Client
  ↓
ASGI Server (Uvicorn)
  ↓
Middleware (outermost first)
  ↓
Router
  ↓
Dependencies (Depends)
  ↓
Endpoint function
  ↓
Service
  ↓
Database
  ↓
Response serialization
  ↓
Response middleware (reverse order)
  ↓
Client
```

Order matters: middleware wraps everything, dependencies resolve before the
endpoint runs, and responses flow back through middleware in reverse.

## Middleware

Middleware is a callable that receives the request, does something, then calls
`call_next` to continue. It wraps every request/response pair.

```python
from starlette.middleware.base import BaseHTTPMiddleware

class TimingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        started = time.perf_counter()
        response = await call_next(request)
        response.headers["X-Process-Time"] = str(time.perf_counter() - started)
        return response
```

Register it:

```python
app.add_middleware(TimingMiddleware)
```

Middleware is the right place for infrastructure concerns that apply to every
request: CORS, request IDs, timing, logging, authentication (transport level),
and rate limiting.

## Custom middleware

Two styles:

```python
# Class-based
class CustomMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        request.state.started = time.perf_counter()
        response = await call_next(request)
        return response
```

```python
# Pure function (older/alternative style)
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    response.headers["X-Process-Time"] = str(time.perf_counter() - start)
    return response
```

Use `request.state` to attach per-request values (user, request ID) readable in
endpoints and dependencies.

## CORS

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://app.example.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

- List explicit origins in production; avoid `allow_origins=["*"]` with
  `allow_credentials=True` (browsers reject this combination).
- CORS must be registered so preflight (`OPTIONS`) responses include the right
  headers before other middleware rejects the request.

## Request/response lifecycle

Inside the ASGI server:

1. Uvicorn parses the HTTP request bytes.
2. The ASGI app (FastAPI) receives `scope`, `receive`, and `send`.
3. Middleware stack runs - each can modify the request or short-circuit.
4. Router matches path + method to an endpoint; no match → 404.
5. Request parsing and validation: path/query/body types and Pydantic models.
   Failure → 422.
6. Dependencies resolve (DB session, auth, config) in graph order.
7. The endpoint executes (`def` in threadpool, `async def` on the loop).
8. Return value is serialized (response_model filtering applied).
9. Response flows back through middleware in reverse; ASGI server sends bytes.

## Logging middleware

```python
import logging

logger = logging.getLogger("api")

class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        started = time.perf_counter()
        response = await call_next(request)
        duration = time.perf_counter() - started
        logger.info(
            "method=%s path=%s status=%s duration_ms=%.1f",
            request.method, request.url.path, response.status_code, duration * 1000,
        )
        return response
```

Attach a request ID and include it in every log line and error response so
traces can be correlated.

## Authentication middleware

Auth middleware validates transport-level credentials (API keys, IP allowlists)
for every request:

```python
class ApiKeyMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        key = request.headers.get("x-api-key")
        if request.url.path.startswith("/public"):
            return await call_next(request)
        if key != settings.api_key:
            return JSONResponse(status_code=401, content={"detail": "Invalid API key"})
        request.state.api_key = key
        return await call_next(request)
```

Prefer dependency-based auth (`get_current_user`) for per-route/role control;
reserve middleware auth for app-wide transport-level rules.

## Timing requests

The `X-Process-Time` middleware above is the standard pattern. For finer
measurements, time inside dependencies or the service layer and log p50/p95.

## Exception middleware

Middleware can catch exceptions and convert them into responses, but the
cleaner pattern is `@app.exception_handler`:

```python
@app.exception_handler(Exception)
async def unhandled_handler(request: Request, exc: Exception):
    logger.exception("Unhandled error", exc_info=exc)
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})
```

Use middleware as a catch-all for logging unhandled errors; use exception
handlers for converting specific exception types into structured responses.

## Mid/Senior Interview Questions and Answers

### 1. What is the order of the request lifecycle in FastAPI?

**Answer:** Client → ASGI server → middleware (outermost first) → router match →
parameter parsing and Pydantic validation → dependency resolution → endpoint
execution (`def` in threadpool, `async def` on loop) → response serialization →
middleware in reverse → ASGI server → client. Errors at any stage produce a
response that flows back through middleware.

### 2. Middleware vs dependencies - when do you use each?

**Answer:** Middleware wraps every request/response and cannot inject values into
endpoint signatures; use it for CORS, request IDs, timing, and transport-level
rules. Dependencies resolve per-route, can inject DB sessions and the current
user, and support overrides for testing. For authentication/authorization, use
dependencies; for global infrastructure, use middleware.

### 3. How do you add a request ID for tracing?

**Answer:** Middleware reads `X-Request-Id` from the header or generates a UUID,
stores it in `request.state.request_id`, sets the response header, and includes
it in logs and error responses. Correlating logs across the app and external
services becomes possible with a single ID per request.

### 4. What is `call_next` and what happens if you don't call it?

**Answer:** `call_next` invokes the next middleware and eventually the endpoint,
returning the response. Not calling it short-circuits the request - the endpoint
never runs and you must return a response yourself. This is used for early
rejection (auth, allowlists, maintenance mode).

### 5. Why does CORS middleware need to run early?

**Answer:** CORS middleware must set `Access-Control-*` headers on preflight
(`OPTIONS`) requests and responses. If it runs after an auth middleware that
rejects the request, browsers never get the CORS headers and report opaque CORS
errors instead of the real 401/403. Register CORS as the outermost middleware.