# FastAPI Fundamentals

Start with the core framework: what FastAPI is, the ASGI/Starlette/Pydantic stack, path operations, parameters, responses, and the automatic OpenAPI docs.

## What is FastAPI and why use it?

FastAPI is a lightweight Python framework for building APIs. It is built on top of Starlette and Pydantic.

Why teams choose it:

- **Type-hint driven** - validation, serialization, and docs are derived from Python type annotations
- **Automatic OpenAPI/Swagger** - interactive docs with zero extra code
- **Async support** - ASGI native, handles high concurrency well
- **Dependency injection** - reusable, testable request-scoped logic
- **Fast to write** - less boilerplate than many other Python frameworks
- **Production ready** - used by many large companies; strong ecosystem

## ASGI, Starlette, Pydantic

- **ASGI** (Asynchronous Server Gateway Interface) is the standard interface that connects Python async web applications with async web servers. An async server handles many requests efficiently by not waiting idly during slow I/O (database queries, HTTP calls, file operations).
- **Starlette** handles the web/server layer: routing, requests, responses, middleware, WebSockets, and background tasks.
- **Pydantic** handles data validation, parsing, and serialization.

```
Uvicorn (ASGI server)
    ↓
FastAPI application (Starlette core)
    ├── routing / middleware / WebSockets / background tasks  (Starlette)
    └── validation / serialization / OpenAPI schema            (Pydantic)
```

## FastAPI vs Django

FastAPI is lightweight and mainly focused on APIs. Django is a full-stack
framework with a built-in ORM, admin panel, authentication, forms, and
templating.

FastAPI is often a strong fit for high-performance APIs and microservices.
Django is often a strong fit when a product benefits from built-in full-stack
features and convention-heavy application structure.

## Creating your first application

```bash
pip install fastapi uvicorn
```

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello World"}
```

Run with:

```bash
uvicorn main:app --reload
```

- `main` = module, `app` = FastAPI instance
- `--reload` = dev auto-reload on code changes

## Path operations: GET, POST, PUT, PATCH, DELETE

A path operation pairs an HTTP method with a URL path.

```python
@app.get("/items")          # read a list
def list_items(): ...

@app.get("/items/{id}")     # read one
def get_item(id: int): ...

@app.post("/items", status_code=201)   # create
def create_item(item: Item): ...

@app.put("/items/{id}")     # full replace
def replace_item(id: int, item: Item): ...

@app.patch("/items/{id}")   # partial update
def update_item(id: int, item: Item): ...

@app.delete("/items/{id}", status_code=204)  # delete
def delete_item(id: int): ...
```

## Path parameters

Parameters declared inside the route `{...}` are path parameters.

```python
@app.get("/items/{item_id}")
def read_item(item_id: int):
    return {"item_id": item_id}
```

FastAPI converts `item_id` to the declared type. A non-integer value returns a `422` validation error automatically. Order matters: declare literal routes like `/users/me` before dynamic ones like `/users/{user_id}`.

## Query parameters

Parameters that are not part of the path become query parameters.

```python
@app.get("/items")
def list_items(
    skip: int = 0,
    limit: int = 10,
    q: str | None = None,
):
    return {"skip": skip, "limit": limit, "q": q}
```

Defaults make parameters optional. Required query params have no default. Types are validated and converted (`?skip=5` → `int 5`). Booleans accept `true/false/1/0/on/off`.

## Request body

Use a Pydantic model as the body parameter type.

```python
class Item(BaseModel):
    name: str
    price: float

@app.post("/items")
def create_item(item: Item):
    return item
```

FastAPI validates the JSON body against the model and returns `422` on invalid data.

## Response body

Return a dict, a Pydantic model, or any serializable object. FastAPI serializes it to JSON automatically.

```python
@app.post("/items", response_model=ItemRead)
def create_item(item: ItemCreate):
    created = create_in_db(item)
    return created  # validated against ItemRead before sending
```

## HTTP status codes

Set the default status code with `status_code`, using `fastapi.status` constants for readability:

```python
from fastapi import status

@app.post("/items", status_code=status.HTTP_201_CREATED)
def create_item(item: Item): ...

@app.delete("/items/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(id: int): ...
```

Return a specific code at runtime with `Response` or `JSONResponse(status_code=...)`.

## Response models

`response_model` declares the output schema:

- Filters fields: only declared fields are sent (extra keys stripped)
- Validates output: wrong return data raises an error instead of leaking
- Documents the response in OpenAPI

```python
class UserOut(BaseModel):
    id: int
    email: str

@app.get("/users/{id}", response_model=UserOut)
def get_user(id: int):
    user = db_query(id)   # may have extra fields like password
    return user           # password is filtered out
```

Use separate input/output models (`UserCreate`, `UserOut`) so sensitive fields never leak.

## Automatic OpenAPI/Swagger documentation

FastAPI generates the OpenAPI schema from path operations, types, and Pydantic models.

- Interactive docs: `http://localhost:8000/docs` (Swagger UI)
- Alternative docs: `http://localhost:8000/redoc`
- Raw schema: `http://localhost:8000/openapi.json`

The docs include request bodies, parameters, response models, and error schemas, all generated from type hints.

## uvicorn

Uvicorn is the reference ASGI server.

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
uvicorn main:app --reload          # development
uvicorn main:app --loop asyncio --log-level info
```

For production, run uvicorn behind Gunicorn (or use multiple uvicorn workers) - see [Performance & Scalability](performance-and-scalability.md).

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between FastAPI, Starlette, and Pydantic?

**Answer:** FastAPI is a web framework that adds developer experience - type-hint
driven validation, OpenAPI generation, dependency injection, and a security
layer - on top of Starlette. Starlette is the ASGI web toolkit handling routing,
middleware, and request/response. Pydantic is the validation library that powers
request/response validation and schema generation.

FastAPI does not reimplement the HTTP layer; it layers its API and data features
over the two libraries.

### 2. How does FastAPI generate documentation automatically?

**Answer:** FastAPI inspects route decorators and function signatures at
registration time, reads Python type hints, and converts Pydantic models and
parameter metadata into the OpenAPI specification. No separate schema file or
code generation is needed.

### 3. Why are type hints important to FastAPI?

**Answer:** Type hints are the single source of truth for validation, parsing,
serialization, and documentation. They give editors autocomplete and static
analysis, and FastAPI derives runtime behavior (validation, OpenAPI) from them.
Consistency between the annotation and the Pydantic model matters.

### 4. How do path, query, and body parameters differ?

**Answer:** Path parameters come from URL segments (`/items/5`), query
parameters from the query string (`?limit=10`), and the body from the request
payload. FastAPI infers each from the signature: Pydantic models and singular
`Body()` → body, path-declared names → path, everything else with simple types →
query.