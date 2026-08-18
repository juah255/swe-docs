# Routing & Application Structure

Move from small examples to real projects: APIRouter, prefixes, tags, dependencies, and a scalable project layout.

## APIRouter

`APIRouter` groups related routes into one module:

```python
from fastapi import APIRouter

router = APIRouter()

@router.get("/items")
def list_items(): ...

@router.post("/items", status_code=201)
def create_item(): ...
```

Include it in the app:

```python
from fastapi import FastAPI
from .routers import items

app = FastAPI()
app.include_router(items.router)
```

## Router prefixes

Prefixes set a common base path for the whole router:

```python
router = APIRouter(prefix="/items")
# now: GET /items, GET /items/{id}
```

Combined with tags for documentation grouping:

```python
router = APIRouter(prefix="/users", tags=["users"])
```

## Tags

Tags group operations in the OpenAPI docs:

```python
@router.get("/", tags=["users"])
def list_users(): ...
```

Or set them at the router level so every operation inherits the tag.

## Router dependencies

Apply dependencies to every route in a router:

```python
router = APIRouter(
    prefix="/admin",
    tags=["admin"],
    dependencies=[Depends(require_admin)],
)
```

The dependency runs for each route in the router without adding it to every signature. App-level dependencies apply globally:

```python
app = FastAPI(dependencies=[Depends(require_api_key)])
```

## Project/module organization

A typical structure:

```
app/
├── main.py            # creates the FastAPI app, includes routers
├── routers/           # API routes
├── services/          # business logic
├── models/            # SQLAlchemy/ORM models
├── schemas/           # Pydantic request/response models
├── dependencies/      # shared Depends() functions
├── core/              # config, security, logging
└── database/          # session/engine setup
```

`main.py`:

```python
from fastapi import FastAPI
from app.routers import users, items, auth

app = FastAPI(title="My API", version="1.0.0")
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(items.router)
```

Rules of thumb:

- Routers are thin: parse/validate via schemas and delegate to services.
- Services hold business logic and are testable without HTTP.
- Schemas (Pydantic) are the API contract; models (ORM) are the storage layer.
- Dependencies centralize auth, DB sessions, and shared config.

## Configuration management

Use Pydantic `Settings` for typed configuration (see [Pydantic](pydantic.md#pydantic-settings)):

```python
# app/core/config.py
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="APP_")

    database_url: str
    jwt_secret: str
    debug: bool = False

settings = Settings()
```

Provide it through a dependency so it can be overridden in tests:

```python
from fastapi import Depends

def get_settings() -> Settings:
    return settings
```

## Environment variables

- Load from `.env` in development; real environment in production.
- Keep a `.env.example` documenting every variable.
- Never commit `.env` files containing secrets.
- Access through `settings`, not `os.environ` scattered through code.

## Lifespan events

Replace the deprecated `startup`/`shutdown` events with a lifespan context manager:

```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # startup: create engine, pools, queues, warm caches
    engine = await create_engine(settings.database_url)
    app.state.engine = engine
    yield
    # shutdown: close pools, connections, background workers
    await engine.dispose()

app = FastAPI(lifespan=lifespan)
```

Use `app.state` to attach resources created at startup and access them in endpoints via `request.app.state`.

## Mid/Senior Interview Questions and Answers

### 1. Why use `APIRouter` instead of adding all routes to the app?

**Answer:** `APIRouter` organizes routes by feature into modules with their own
prefix, tags, and dependencies. It keeps `main.py` tiny, makes features
self-contained, enables per-feature dependency injection, and scales to large
applications. All routes on one app object become unmanageable past a handful of
endpoints.

### 2. What is the difference between router-level and app-level dependencies?

**Answer:** Router-level dependencies apply to every route included from that
router (e.g. an admin router requiring `require_admin`). App-level dependencies
apply to every route in the application. Route-level dependencies in the
signature apply only to that endpoint. Choose the narrowest scope that works.

### 3. How do you share database sessions across routers?

**Answer:** Define a `get_db` yield dependency in `dependencies/` and declare it
in each route that needs a session. FastAPI caches the dependency per request, so
nested routes and services reuse the same session for one request and the
`finally` block closes it afterward.

### 4. What is the lifespan pattern and why use it instead of `@app.on_event`?

**Answer:** The lifespan context manager runs setup before the app serves
requests and teardown after shutdown in one place. It replaces the deprecated
`startup`/`shutdown` decorators, guarantees resources (engine, pools, queues)
are created once and closed cleanly, and is easier to test - the same context
manager can wrap the test client.

### 5. How do you structure services vs routers vs schemas?

**Answer:** Routers only map HTTP to service calls. Services contain business
logic and orchestrate repositories/models. Schemas are the Pydantic contracts at
the API boundary. Keeping them separate means business logic is testable without
HTTP, schemas can change without touching storage, and routers stay thin.