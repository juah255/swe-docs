# Dependency Injection

Learn FastAPI's dependency system deeply. It is one of the framework's strongest features and the backbone of database sessions, authentication, and testability.

## Depends()

`Depends()` is FastAPI's dependency injection mechanism. It allows routes to reuse logic such as database sessions, authentication, permission checks, or common query parameters.

```python
from fastapi import Depends

def get_common_params():
    return {"page": 1, "limit": 20}

@app.get("/items")
def list_items(common: dict = Depends(get_common_params)):
    return common
```

The dependency function runs before the endpoint, and its return value is injected into the parameter declared with `Depends()`.

## Dependency functions

Dependencies are plain Python callables:

```python
def verify_token(token: str) -> str:
    if not token:
        raise HTTPException(status_code=401, detail="missing token")
    return token

@app.get("/me")
def read_me(token: str = Depends(verify_token)):
    return {"token": token}
```

Dependencies can:

- take their own parameters (headers, query params, other dependencies)
- return values to be injected
- `yield` resources with setup/teardown
- raise exceptions to short-circuit the request (401/403/422...)

## Nested dependencies

Dependencies can depend on other dependencies. FastAPI resolves the whole graph:

```python
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(db: Session = Depends(get_db), token: str = Header(...)):
    user = db.query(User).filter(User.token == token).first()
    if not user:
        raise HTTPException(status_code=401, detail="invalid token")
    return user

@app.get("/me")
def read_me(user: User = Depends(get_current_user)):
    return user
```

Nested dependencies run from the deepest (leaf) dependency outward. The same dependency used twice in one request is cached (resolved once) by default.

## Class-based dependencies

A dependency can be a class; FastAPI calls `__call__`:

```python
class CommonQueryParams:
    def __init__(self, q: str | None = None, skip: int = 0, limit: int = 100):
        self.q = q
        self.skip = skip
        self.limit = limit

@app.get("/items")
def list_items(common: CommonQueryParams = Depends()):
    return {"q": common.q, "skip": common.skip, "limit": common.limit}
```

Class-based dependencies group related parameters and logic together. With `Depends()` and no callable argument, FastAPI infers it from the type annotation.

## Database dependencies

The standard pattern is a `yield` dependency that provides a session and guarantees cleanup:

```python
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

```python
@app.get("/users/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    return db.query(User).get(user_id)
```

The `finally` block runs after the response is sent, guaranteeing the session is closed even when the endpoint raises.

## Authentication dependencies

Auth dependencies validate credentials and inject the current user:

```python
def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    token = credentials.credentials
    payload = decode_jwt(token)  # raises if invalid/expired
    user = db.query(User).get(payload["sub"])
    if not user:
        raise HTTPException(status_code=401, detail="user not found")
    return user
```

Apply auth at router level to protect every route:

```python
router = APIRouter(dependencies=[Depends(get_current_user)])
```

## Dependency scopes

- **Per-request (default)** - a dependency is resolved once per request; if two
  routes or nested deps use the same dependency, FastAPI caches the result for
  that request.
- **`use_cache=False`** - disables caching so the dependency runs each time.
- **Router/global scope** - declaring a dependency at the router or app level
  applies it to every route below it without touching each signature.

Yield-based dependencies also give a clear "before/after" scope around the request.

## Dependency overrides for testing

The killer feature: replace a dependency during tests without touching production code.

```python
from fastapi.testclient import TestClient

def fake_get_current_user():
    return User(id=1, username="test")

app.dependency_overrides[get_current_user] = fake_get_current_user

client = TestClient(app)
res = client.get("/me")  # uses the fake user
```

Clean up between tests:

```python
def test_me(client):
    app.dependency_overrides[get_current_user] = fake_get_current_user
    ...
    app.dependency_overrides.clear()
```

This is how you test authenticated endpoints, swap databases for a test database, and mock external services.

## Mid/Senior Interview Questions and Answers

### 1. How does FastAPI dependency injection work under the hood?

**Answer:** FastAPI builds a dependency graph at route registration time by
inspecting function signatures. `Depends()` marks a parameter as a dependency;
FastAPI resolves each dependency recursively, runs them in dependency order, and
caches results within the request scope. `yield` dependencies wrap the endpoint
so teardown runs after the response.

### 2. What is the difference between a dependency and a middleware?

**Answer:** A dependency runs just before the endpoint (and after, for `yield`
dependencies) and can inject values into the endpoint signature. Middleware wraps
the entire request/response cycle and cannot inject into endpoint parameters.

Dependencies are the right tool for request-scoped data (DB session, current
user, config); middleware is for cross-cutting infrastructure (CORS, logging,
request IDs).

### 3. When do dependencies get called, and how is caching handled?

**Answer:** Dependencies are resolved per request, in dependency-graph order
(deepest first). By default the result is cached for the duration of the
request, so a dependency used by both a router and an endpoint runs only once.
Pass `use_cache=False` to `Depends()` when the same dependency must run multiple
times.

### 4. How do you use dependency overrides in testing?

**Answer:** Set `app.dependency_overrides[some_dep] = fake_dep` to replace a real
dependency (DB session, current user, payment client) with a test double for the
duration of the test, then clear it. This lets you test endpoints with fake auth,
an in-memory database, or mocked external services without changing app code.

### 5. What is the difference between `yield` dependencies and normal dependencies?

**Answer:** A normal dependency returns a value. A `yield` dependency also runs
teardown code after the endpoint completes - the code before `yield` runs as
setup, and the code after `yield` runs in `finally`, whether the endpoint
succeeded or raised. Use `yield` for resources with lifecycle: database sessions,
locks, and clients that must be closed.