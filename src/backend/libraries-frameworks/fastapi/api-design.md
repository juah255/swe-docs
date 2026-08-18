# API Design

This is where FastAPI knowledge becomes backend engineering knowledge. REST design, pagination, filtering, sorting, versioning, error formats, idempotency, and rate limiting.

## REST API design

- Use nouns for resources, not verbs: `POST /users`, not `/createUser`.
- Use the HTTP methods for their meaning: `GET` read, `POST` create, `PUT`
  full replace, `PATCH` partial update, `DELETE` remove.
- Keep paths consistent and nested for owned resources.

Example:

```
GET    /users            list users
GET    /users/{id}       get one user
POST   /users            create a user
PATCH  /users/{id}       update a user
DELETE /users/{id}       delete a user
```

## Resource naming

- Plural nouns: `/users`, `/orders`, `/products`.
- Nest sub-resources: `/users/{id}/orders`.
- Use IDs that cannot be enumerated when privacy matters (UUIDs).
- Keep names consistent between the URL, models, and docs.

## HTTP methods and status codes

| Method | Meaning | Success status |
|--------|---------|----------------|
| GET | Read | 200 |
| POST | Create | 201 |
| PUT | Full replace | 200 |
| PATCH | Partial update | 200 |
| DELETE | Remove | 204 |

Errors: 400 bad request, 401 unauthenticated, 403 forbidden, 404 not found,
409 conflict, 422 validation failed, 429 rate limited, 500 server error.

## Pagination

```python
from fastapi import Query

@app.get("/users")
def list_users(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
):
    offset = (page - 1) * limit
    total, users = service.paginate(offset=offset, limit=limit)
    return {
        "data": users,
        "meta": {"page": page, "limit": limit, "total": total},
    }
```

Cursor pagination is more stable for live data:

```python
@app.get("/events")
def list_events(cursor: str | None = None, limit: int = 20):
    items, next_cursor = service.paginate_cursor(cursor=cursor, limit=limit)
    return {"data": items, "next_cursor": next_cursor}
```

Return `next_cursor` when more results exist.

## Filtering

Validate and whitelist filter parameters:

```python
@app.get("/products")
def list_products(
    category: str | None = None,
    min_price: float | None = Query(None, ge=0),
    in_stock: bool | None = None,
):
    return service.filter(category=category, min_price=min_price, in_stock=in_stock)
```

Never pass raw filter strings into SQL; use the ORM and typed parameters.

## Sorting

Whitelist sortable fields:

```python
SORTABLE = {"created_at", "name", "price"}

@app.get("/products")
def list_products(sort: str = "created_at", order: Literal["asc", "desc"] = "desc"):
    if sort not in SORTABLE:
        raise HTTPException(status_code=400, detail="invalid sort field")
    ...
```

## Searching

Simple search uses ORM `ilike`:

```python
@app.get("/products/search")
def search_products(q: str, limit: int = 20):
    return service.search(q, limit)
```

For typo tolerance, relevance ranking, and full text, move to Postgres
full-text search or a dedicated engine (Meilisearch, OpenSearch).

## Versioning

- URI versioning: `/v1/users` - most common and visible.
- Header versioning: `Accept: application/json; version=1`.
- Keep old versions during a deprecation period.

```python
# v1 router keeps old behavior, v2 router has breaking changes
app.include_router(users_v1, prefix="/v1/users")
app.include_router(users_v2, prefix="/v2/users")
```

Version only when breaking changes happen, not on every release.

## Error response format

Return consistent, structured errors everywhere:

```json
{
  "detail": "User not found",
  "code": "USER_NOT_FOUND"
}
```

```python
class ApiError(Exception):
    def __init__(self, status: int, detail: str, code: str):
        self.status = status
        self.detail = detail
        self.code = code

@app.exception_handler(ApiError)
async def api_error_handler(request: Request, exc: ApiError):
    return JSONResponse(status_code=exc.status, content={"detail": exc.detail, "code": exc.code})
```

Include `errors` details for validation failures (422). Never leak stack traces
or database internals.

## Idempotency

An idempotent operation can be applied multiple times with the same result.

- `GET`, `PUT`, `DELETE` should be naturally idempotent.
- `POST` creates - make it idempotent with an idempotency key for critical
  resources (payments, orders):

```python
@app.post("/checkout")
def checkout(req: Request, payload: CheckoutPayload):
    key = req.headers.get("Idempotency-Key")
    existing = service.find_by_idempotency_key(key)
    if existing:
        return JSONResponse(status_code=200, content=existing)
    result = service.process(payload)
    service.store_idempotency(key, result)
    return result
```

The key should be unique per operation; store the response so retries return
the same result instead of double-processing.

## Rate limiting

`slowapi` is the common library:

```bash
pip install slowapi
```

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)

@app.get("/users")
@limiter.limit("100/minute")
def list_users(request: Request):
    ...
```

Apply stricter limits to auth and public endpoints. Use a Redis-backed storage
when running multiple workers so limits are shared.

## API documentation

FastAPI generates OpenAPI automatically. Enrich it:

```python
app = FastAPI(
    title="My API",
    description="User management service",
    version="1.0.0",
    openapi_tags=[{"name": "users", "description": "User operations"}],
)

@app.get("/users", tags=["users"], summary="List users", response_model=list[UserOut])
def list_users(...): ...
```

Keep the docs in sync with the code - FastAPI derives them from schemas and
annotations, so well-typed schemas produce accurate docs.

## Mid/Senior Interview Questions and Answers

### 1. What makes an API RESTful?

**Answer:** REST uses resources addressed by URLs, HTTP methods for operations,
status codes for outcomes, and stateless requests. Resource names are nouns,
representations are JSON, and clients navigate with links. Pragmatic "REST"
APIs follow the resource/method/status conventions without every HATEOAS
constraint.

### 2. Offset vs cursor pagination - which should you use?

**Answer:** Offset pagination (`page`/`limit`) is simple and supports random
access to any page, but is unstable when rows are inserted/deleted between
requests. Cursor pagination is stable and fast on large tables but cannot jump
to arbitrary pages. Use cursor for feeds and live data; offset for admin lists.

### 3. How do you make a create endpoint idempotent?

**Answer:** Accept an `Idempotency-Key` header, look up the key before
processing, and return the stored result if the operation already ran. Store the
key + response atomically (same DB transaction). This prevents double-charging
or duplicate orders when clients retry after a timeout.

### 4. How do you structure error responses consistently?

**Answer:** Use a custom exception class with status/detail/code, register a
global handler with `@app.exception_handler`, and always return
`{"detail": ..., "code": ...}` (plus `errors` for 422). Handle `HTTPException`,
`RequestValidationError`, and unhandled exceptions so every response follows the
same shape. Never leak stack traces.

### 5. When and how do you version an API?

**Answer:** Version when a breaking change is unavoidable - changed field
semantics, removed endpoints, incompatible types. Prefer additive changes first
(new fields, new endpoints) so clients keep working. When breaking changes
ship, use `/v1`/`/v2` prefixes and keep the old version during a deprecation
window with clear migration docs.