# FastAPI

FastAPI patterns, routing conventions, and service examples.

## Core Concepts

### What is FastAPI?

FastAPI is a lightweight Python framework for building APIs. It is built on top
of Starlette and Pydantic.

- **Starlette** handles the web/server layer, including routing, requests,
  responses, middleware, WebSockets, and background tasks.
- **Pydantic** handles data validation, parsing, and serialization.

### What is Starlette?

Starlette is a lightweight ASGI web framework used to build async web
applications in Python.

ASGI means **Asynchronous Server Gateway Interface**. It is a standard interface
that connects Python web applications with async web servers.

An async web server can handle many requests efficiently by not waiting idly
while one request is doing slow I/O work, such as database queries, HTTP calls,
or file operations.

### What is `Depends()`?

`Depends()` is FastAPI's dependency injection mechanism. It allows routes to
reuse logic such as database sessions, authentication, permission checks, or
common query parameters.

### FastAPI vs Django

FastAPI is lightweight and mainly focused on APIs. Django is a full-stack
framework with a built-in ORM, admin panel, authentication, forms, and
templating.

FastAPI is often a strong fit for high-performance APIs and microservices.
Django is often a strong fit when a product benefits from built-in full-stack
features and convention-heavy application structure.

### Path, Query, and Body Parameters

FastAPI infers parameter location from function signatures and type hints. Path
parameters appear in the route, query parameters are simple types, and body
parameters are Pydantic models.

```python
@app.get("/items/{item_id}")
def read_item(item_id: int, q: str | None = None):
    return {"item_id": item_id, "q": q}

@app.post("/items")
def create_item(item: Item):
    return item
```

Explicit `Path()`, `Query()`, and `Body()` helpers are used when metadata such as
validation constraints or examples is needed.

### Pydantic Models

Pydantic models define request and response schemas. FastAPI uses them to
validate input, serialize output, and generate the OpenAPI schema.

```python
class Item(BaseModel):
    name: str
    price: float
    is_available: bool = True
```

Separate models are commonly used for input (`ItemCreate`), output (`ItemRead`),
and internal representations to keep boundaries clean.

### Dependency Injection with `Depends()`

Dependencies are functions or callables that FastAPI runs before the endpoint.
They can return values, yield resources with cleanup, or raise exceptions to
short-circuit the request.

```python
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/users/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    return db.query(User).get(user_id)
```

Dependencies can be nested, cached per request, and overridden in tests, which
makes them a strong fit for database sessions, auth, and configuration.

### Middleware and Background Tasks

Middleware wraps every request for cross-cutting concerns such as CORS, request
IDs, or timing. Background tasks run after the response is returned and are
useful for lightweight side effects.

Heavy or long-running work should go to a task queue such as Celery, RQ, or
Arq rather than background tasks.

### Async vs Sync Endpoints

`async def` endpoints run on the event loop and are appropriate when the handler
awaits non-blocking I/O. `def` endpoints run in a threadpool so they do not
block the loop.

Mixing blocking libraries inside `async def` endpoints blocks the entire event
loop and is a common performance mistake.

## Request Cycle

```
Client (browser / service)
│
▼
ASGI Server (Uvicorn / Hypercorn)
│  raw bytes → HTTP request parsed
▼
ASGI App (FastAPI)
│
▼
Middleware stack (outermost first)
│  CORSMiddleware → TrustedHostMiddleware → custom middleware...
│  Each middleware can modify request, short-circuit, or wrap the response
▼
Router
│  Match path + method → select endpoint function
│  No match → 404 from Starlette
▼
Request parsing & validation
│  Path params → type-cast by signature
│  Query params → type-cast by signature
│  Body → JSON decoded → Pydantic model validated
│  Header / cookie params → extracted per annotation
│  Validation failure → 422 response (never reaches endpoint)
▼
Dependency resolution (Depends)
│  Called in dependency graph order (leaf to root)
│  Yield-based deps run setup → endpoint → teardown
│  Auth / DB / config deps inject into endpoint signature
│  Exception in any dep → 401/403/500, endpoint skipped
▼
Endpoint function executes
│  Sync def → run in threadpool (anyio)
│  Async def → run on event loop
│  Returns: dict / Pydantic model / Response / StreamingResponse
▼
Response serialization
│  Pydantic model → JSON bytes
│  Response model validation applied if defined
│  Status code from decorator or Response object
▼
Response middleware (reverse order)
│  Headers set, timing logged, request ID attached
▼
ASGI server sends response bytes to client
```

### Key details at each stage

**Middleware** — Runs on every request. CORS must be outermost so preflight
headers are returned before auth middleware rejects the request. Middleware that
touches headers must run before serialization.

**Routing** — FastAPI uses Starlette's router which supports path converters
(`{item_id:int}`), mounted sub-applications, and prefix groups. Route order
matters: a literal `/users/me` must be defined before `/users/{user_id}`.

**Validation** — Happens at two boundaries. *Input* validation rejects bad
requests before the endpoint runs. *Output* validation (`response_model`) catches
bugs where the endpoint returns data that doesn't match the documented schema.

**Dependencies** — Resolved per-request and cached within that request. A
dependency that yields (e.g. DB session) runs its teardown code after the
response is sent. Dependencies can override each other for testing by replacing
the `Depends()` return value.

**Sync vs Async** — FastAPI detects the endpoint type at registration time.
`def` endpoints are always dispatched to a threadpool. `async def` endpoints
run directly on the event loop — any blocking call inside them blocks all other
concurrent requests on that worker.

**Error handling** — Exceptions bubble up through dependencies → middleware →
ASGI server. `HTTPException` is caught and turned into a JSON response.
Unhandled exceptions become 500. Custom exception handlers registered with
`@app.exception_handler` intercept specific types before they reach the server.

## Mid/Senior Interview Questions and Answers

### 1. What makes FastAPI different from many older Python web frameworks?

**Answer:** FastAPI is built around type hints, automatic request validation,
OpenAPI generation, dependency injection, and ASGI support for async workloads.

The senior detail is that type hints improve developer tooling and schema
generation, but runtime validation still depends on request models and boundary
checks.

### 2. When should a FastAPI endpoint be `async`?

**Answer:** Use `async` when the endpoint awaits non-blocking I/O such as async
database drivers, HTTP clients, or queues. A route that calls blocking libraries
inside `async` can still block the event loop.

For blocking CPU work, use worker processes, task queues, or thread/process
offloading depending on workload.

### 3. How should dependencies be used in FastAPI?

**Answer:** Dependencies should provide reusable request-scoped behavior such as
database sessions, authentication, authorization, configuration, and service
objects.

Keep dependencies focused. A deeply nested dependency graph can make request
flow hard to understand and test.

### 4. How do you structure a production FastAPI app?

**Answer:** Separate routers, schemas, services, repositories, configuration,
database setup, and external integrations. Keep route functions thin and move
business logic into testable services.

Production concerns include ASGI server configuration, timeouts, connection
pooling, migrations, structured logging, metrics, and health checks.

### 5. Explain the request lifecycle in FastAPI.

**Answer:** The lifecycle runs roughly in this order:

1. Client sends an HTTP request.
2. ASGI server (e.g. Uvicorn) receives it.
3. Starlette middleware runs (CORS, auth, logging, request ID).
4. Router matches the URL to an endpoint function.
5. Path/query/body parameters are parsed and validated by Pydantic.
6. Dependencies are resolved (`Depends()` calls run: DB session, auth check, etc.).
7. Endpoint function executes (business logic).
8. Return value is serialized to JSON by Pydantic.
9. Response middleware runs (headers, timing).
10. ASGI server sends the response to the client.

For async endpoints, steps 5–8 run on the event loop. For sync endpoints, they
run in a threadpool managed by Starlette.

### 6. What is dependency injection in FastAPI?

**Answer:** DI is a pattern where dependencies (services, DB sessions, auth) are
provided to endpoints rather than created inside them. FastAPI's `Depends()`
mechanism:

- Resolves function dependencies automatically from the function signature.
- Supports nested dependencies (e.g. auth depends on DB).
- Can yield resources with cleanup (context-manager style).
- Caches resolved dependencies per request (same dependency = same instance).
- Easy to override in tests by passing a mock to `Depends()`.

```python
def get_current_user(token: str = Header(...)) -> User:
    return verify_token(token)

@app.get("/me")
def read_me(user: User = Depends(get_current_user)):
    return user
```

### 7. What is the difference between Middleware, Dependency, and Background Tasks?

**Answer:**

- **Middleware** wraps every request/response pair. It runs before and after the
  endpoint. Good for CORS, logging, request IDs, and timing.

- **Dependency** runs before the endpoint to provide resources (DB session, auth,
  config). Resolved per-request, can be cached, and scoped to specific routes.

- **Background Task** runs after the response is sent. Good for lightweight side
  effects (send email, log event). Not suited for heavy or long-running work.

```python
@app.post("/orders", response_model=OrderRead)
async def create_order(
    order: OrderCreate,
    db: Session = Depends(get_db),
    bg: BackgroundTasks = BackgroundTasks(),
):
    new_order = process_order(db, order)
    bg.add_task(send_confirmation_email, new_order.id)
    return new_order
```

### 8. How do you validate request data in FastAPI?

**Answer:**

- Pydantic models for request bodies (automatic validation, type coercion,
  helpful error messages).
- `Path()` and `Query()` for path/query parameters with constraints (min, max,
  regex, description).
- `Annotated` types for modern inline validation:
  `Annotated[int, Field(ge=0)]`.
- Custom validators with `@field_validator` or `@model_validator` in Pydantic
  models.
- FastAPI returns `422 Unprocessable Entity` automatically when validation fails.

```python
from pydantic import BaseModel, Field, field_validator

class CreateUser(BaseModel):
    username: str = Field(min_length=3, max_length=32)
    age: int = Field(ge=0, le=150)

    @field_validator("username")
    @classmethod
    def username_alphanumeric(cls, v: str) -> str:
        if not v.isalnum():
            raise ValueError("must be alphanumeric")
        return v

@app.post("/users", status_code=201)
def create_user(user: CreateUser):
    return {"id": 1, **user.model_dump()}
```

### 9. How do you handle exceptions globally in FastAPI?

**Answer:**

- `@app.exception_handler(ExceptionType)` to register custom handlers.
- Custom exception classes for domain-specific errors.
- `HTTPException` for standard HTTP errors (404, 403, 500, etc.).
- `RequestValidationError` to customize Pydantic validation error responses.
- Middleware for catch-all error handling and logging.
- Always return structured JSON: `{"detail": "message", "code": "ERROR_CODE"}`.

```python
from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse

class AppError(Exception):
    def __init__(self, code: str, status: int, detail: str):
        self.code = code
        self.status = status
        self.detail = detail

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    return JSONResponse(
        status_code=exc.status,
        content={"detail": exc.detail, "code": exc.code},
    )

@app.exception_handler(RequestValidationError)
async def validation_error_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={"detail": "Validation failed", "errors": exc.errors()},
    )
```
