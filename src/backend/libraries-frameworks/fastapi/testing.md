# Testing

Learn to properly test APIs: pytest, the FastAPI TestClient, dependency overrides, mocking, database tests, and integration tests.

## pytest

FastAPI pairs naturally with pytest:

```bash
pip install pytest httpx
```

A minimal structure:

```
tests/
├── conftest.py       # fixtures: client, db, auth
├── test_users.py
├── test_auth.py
└── integration/
```

Run with `pytest` or `pytest -v`.

## FastAPI TestClient

`TestClient` wraps the ASGI app and lets you send requests without a server:

```python
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_read_root():
    res = client.get("/")
    assert res.status_code == 200
    assert res.json() == {"message": "Hello World"}
```

The test client runs the full stack: middleware, routing, validation,
dependencies, and serialization.

## Async testing

For async code, use `httpx.AsyncClient` with an ASGI transport (or `pytest-asyncio`):

```bash
pip install pytest-asyncio httpx
```

```python
import pytest
import httpx
from app.main import app

@pytest.mark.asyncio
async def test_async_endpoint():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        res = await client.get("/items")
        assert res.status_code == 200
```

With TestClient, sync test functions can also call async endpoints directly -
TestClient manages the loop for you.

## Testing endpoints

```python
def test_create_user():
    res = client.post("/users", json={"email": "a@b.com", "name": "A"})
    assert res.status_code == 201
    body = res.json()
    assert body["email"] == "a@b.com"

def test_validation_error():
    res = client.post("/users", json={"email": "not-an-email"})
    assert res.status_code == 422
```

Test the happy path, validation failures, missing data, and error responses.

## Testing dependencies

Test dependencies in isolation by calling them directly:

```python
def test_get_current_user(mock_db):
    user = get_current_user(token="valid", db=mock_db)
    assert user.id == 1

def test_missing_token():
    with pytest.raises(HTTPException) as exc:
        get_current_user(token=None, db=mock_db)
    assert exc.value.status_code == 401
```

## Dependency overrides

Replace real dependencies during tests:

```python
from app.dependencies import get_db, get_current_user

def fake_get_db():
    yield test_session

def fake_get_current_user():
    return User(id=1, email="test@example.com")

def test_me():
    app.dependency_overrides[get_db] = fake_get_db
    app.dependency_overrides[get_current_user] = fake_get_current_user
    res = client.get("/me")
    assert res.status_code == 200
    app.dependency_overrides.clear()
```

Use a fixture and `yield` to auto-clean overrides:

```python
@pytest.fixture
def client():
    app.dependency_overrides[get_db] = fake_get_db
    app.dependency_overrides[get_current_user] = fake_get_current_user
    yield TestClient(app)
    app.dependency_overrides.clear()
```

## Mocking

Use `unittest.mock` to replace external calls (HTTP, email, payment):

```python
from unittest.mock import patch

@patch("app.services.payments.charge")
def test_checkout(mock_charge):
    mock_charge.return_value = {"id": "pay_123"}
    res = client.post("/checkout", json={"cart": [1, 2]})
    assert res.status_code == 200
    mock_charge.assert_called_once()
```

Patch at the module level where the callable is imported/used.

## Database testing

- Use a dedicated test database (or SQLite for simple cases).
- Create/drop schema per session with migrations or `Base.metadata.create_all`.
- Truncate or delete rows between tests for isolation.
- Provide it via `dependency_overrides` of `get_db`.

```python
# conftest.py
@pytest.fixture(autouse=True)
def db_session():
    # run migrations once
    from alembic import command
    command.upgrade(alembic_cfg, "head")
    ...
```

For async DB tests, use an `AsyncSession` factory and `pytest-asyncio`.

## Integration tests

Test the app against a real (test) database and real services:

```python
def test_full_flow():
    # create a user
    res = client.post("/users", json={"email": "x@y.com", "name": "X"})
    user_id = res.json()["id"]

    # use the access token to hit a protected endpoint
    token = client.post("/auth/login", data={"username": "x@y.com", "password": "pw"}).json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    res = client.get(f"/users/{user_id}", headers=headers)
    assert res.status_code == 200
```

This exercises routing, validation, dependencies, auth, and the database
together - close to production behavior.

## Authentication testing

- Log in through the API to get a real token, then pass it in headers.
- Or override `get_current_user` to inject a fake user and skip auth.
- Test both: valid token, expired token, missing token, and wrong role.

## The testing layers

```
Unit Tests
    ↓
Service Tests
    ↓
API Tests
    ↓
Integration Tests
```

- Unit tests: pure functions, validators, business logic.
- Service tests: services with mocked repositories/db.
- API tests: endpoints with dependency overrides.
- Integration tests: full app + real database.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between TestClient and a real server?

**Answer:** `TestClient` (based on `httpx` + ASGITransport) invokes the ASGI app
in-process without sockets, making tests fast and dependency-overridable. A real
server (uvicorn) tests the network stack, WSGI/ASGI adapters, and deployment
configuration but is slower and harder to control. Start with TestClient; add a
few true server-level smoke tests for deployment.

### 2. How do you test an authenticated endpoint?

**Answer:** Either log in through the API to obtain a real token and pass it in
the `Authorization` header, or override `get_current_user` to inject a fake user.
Real tokens test the auth path end to end; overrides isolate the endpoint logic.
Test both valid and invalid/expired token cases.

### 3. How do you isolate tests from the real database?

**Answer:** Point `get_db` at a dedicated test database via `dependency_overrides`,
run migrations once in a fixture, and clean rows between tests. This makes tests
fast, parallel-safe, and independent of local data. Never let tests touch
development or production data.

### 4. What should you mock and what should you not mock?

**Answer:** Mock external boundaries that are slow, flaky, or expensive: HTTP
calls, email, payments, third-party APIs. Do not mock your own validators,
Pydantic models, or the framework itself - you want those exercised. Over-mocking
hides integration bugs, so cover real wiring with integration tests.

### 5. How do you test async code in FastAPI?

**Answer:** Use `pytest-asyncio` with `@pytest.mark.asyncio` for async tests, or
use `TestClient`/`httpx.ASGITransport` so sync tests can drive async endpoints.
Async database sessions must be awaited; use `AsyncSession` fixtures and clean up
async resources with `asyncio.run` or a `pytest-asyncio` loop fixture.