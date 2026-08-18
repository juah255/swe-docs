# Advanced FastAPI

Once everything above is comfortable: WebSockets, Server-Sent Events, streaming, custom OpenAPI, advanced dependencies, lifespan management, async generators, and microservices.

## WebSockets

FastAPI supports WebSockets natively via Starlette:

```python
from fastapi import WebSocket, WebSocketDisconnect

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            await websocket.send_text(f"echo: {data}")
    except WebSocketDisconnect:
        pass
```

Broadcast to many clients:

```python
class ConnectionManager:
    def __init__(self):
        self.active: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active.remove(websocket)

    async def broadcast(self, message: str):
        for ws in self.active:
            await ws.send_text(message)
```

WebSockets need authentication - validate tokens on connect (`websocket.headers`
or query params) and reject invalid connections.

## Server-Sent Events

SSE pushes one-way events over HTTP:

```python
import asyncio
import json
from fastapi.responses import StreamingResponse

@app.get("/events")
async def events():
    async def event_stream():
        while True:
            await asyncio.sleep(1)
            yield f"data: {json.dumps({'time': 'now'})}\n\n"

    return StreamingResponse(
        event_stream(),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )
```

Use SSE for one-way notifications (news feeds, job progress); use WebSockets
for bidirectional real-time interaction.

## Streaming

Stream large responses chunk by chunk:

```python
from fastapi.responses import StreamingResponse

@app.get("/export.csv")
async def export():
    async def gen():
        async for row in db.stream_rows():
            yield row.to_csv() + "\n"
    return StreamingResponse(gen(), media_type="text/csv")
```

Streaming reduces memory usage and time-to-first-byte. For request streaming,
read `await request.stream()`.

## Custom OpenAPI

Customize the generated schema:

```python
app = FastAPI(
    title="My API",
    version="2.0.0",
    description="...",
    servers=[{"url": "https://api.example.com"}],
)

# custom security scheme
from fastapi.security import APIKeyHeader

api_key = APIKeyHeader(name="X-API-Key")
```

Access the schema programmatically:

```python
schema = app.openapi()
```

Add metadata per operation with tags, summaries, descriptions, and response
examples. Use `openapi_tags` to group endpoints.

## Advanced dependency patterns

Factory dependencies for parameterized behavior:

```python
def require_roles(*roles: str):
    async def checker(user: User = Depends(get_current_user)):
        if user.role not in roles:
            raise HTTPException(status_code=403, detail="Forbidden")
        return user
    return checker

@app.get("/admin")
def admin(user: User = Depends(require_roles("admin"))):
    return user
```

Generator (yield) dependencies for lifecycle:

```python
async def get_redis():
    client = redis.from_url(settings.redis_url)
    try:
        yield client
    finally:
        await client.aclose()
```

## Middleware architecture

- Compose middleware in layers: security headers, CORS, auth, request ID,
  timing, logging.
- Use `BaseHTTPMiddleware` for class-based middleware; use the pure
  `@app.middleware("http")` form for simple ones.
- Keep middleware stateless; store per-request data in `request.state`.

## Lifespan management

Full startup/shutdown lifecycle:

```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # startup
    app.state.db_engine = await create_engine(settings.database_url)
    app.state.redis = redis.from_url(settings.redis_url)
    await warm_up_caches()
    yield
    # shutdown
    await app.state.redis.aclose()
    await app.state.db_engine.dispose()

app = FastAPI(lifespan=lifespan)
```

Use `app.state` for shared resources; access them via `request.app.state`.

## Async generators

Yield-based dependencies and streaming both rely on async generators:

```python
async def db_session():
    async with AsyncSessionLocal() as session:
        yield session
```

Async generators lazily produce values, are awaited incrementally, and run
cleanup when closed - the backbone of database and streaming patterns.

## Large application architecture

For large codebases:

```
app/
├── main.py
├── core/          # config, security, logging
├── api/
│   ├── deps.py    # shared dependencies
│   └── routers/   # v1/, v2/ per feature
├── models/
├── schemas/
├── services/
├── repositories/
├── workers/       # Celery tasks
└── tests/
```

- Features in their own modules with routers per resource.
- Schemas vs models kept separate; services orchestrate repositories.
- Dependencies centralized and overridable.
- Versioned routers under `api/routers/v1`, `v2`.

## Microservices with FastAPI

FastAPI services communicate over:

- **HTTP/REST** - simple, each service is a FastAPI app.
- **Message brokers** - Redis/RabbitMQ/Kafka for event-driven async work.
- **gRPC** - typed, high-performance RPC.

Common patterns: API gateway that fans out, sagas for distributed transactions,
and the outbox pattern for reliable event publishing.

## gRPC integration

FastAPI is a web/ASGI framework, not a gRPC framework, but you can run both:

- Define `.proto` contracts and generate Python stubs with `grpcio` tools.
- Run a separate gRPC server process alongside the FastAPI app, or mount both.
- Use gRPC for internal service-to-service calls and REST/HTTP for external
  clients.

```proto
syntax = "proto3";
service Users {
  rpc GetUser (GetUserRequest) returns (User);
}
message GetUserRequest { int64 id = 1; }
message User { int64 id = 1; string email = 2; }
```

## Event-driven architecture

Decouple services with events:

- Publish events to a broker (Redis Streams, RabbitMQ, Kafka) after a domain
  change.
- Consumers subscribe and react (notifications, projections, analytics).
- Use the outbox pattern to publish events reliably within the same transaction
  as the database change.
- Make consumers idempotent for at-least-once delivery.

## Mid/Senior Interview Questions and Answers

### 1. WebSockets vs Server-Sent Events - when do you use each?

**Answer:** WebSockets are full-duplex (client and server can push at any time),
suited to chat, collaborative editing, and games. SSE is one-way (server to
client) over plain HTTP with auto-reconnect, suited to notifications, feeds, and
progress updates. Use SSE when you only need server push; use WebSockets when
the client must also send frequent real-time data.

### 2. How do you authenticate WebSocket connections?

**Answer:** Validate the token during the connection handshake - from the query
string, the `Sec-WebSocket-Protocol` header, or a cookie - before calling
`websocket.accept()`. Reject invalid connections by closing. Never accept
unauthenticated connections and only then check, because the connection is
persistent and bypasses normal HTTP auth.

### 3. What is the outbox pattern?

**Answer:** The outbox pattern writes the domain change and the event to the
same database transaction. A relay process publishes the event and marks it
sent. This avoids the dual-write problem (commit DB then fail to publish) and
gives at-least-once delivery, so consumers must be idempotent.

### 4. How do you structure a large FastAPI application?

**Answer:** Organize by feature with routers per resource, keep schemas (API
contract) separate from models (storage), centralize services and repositories,
and version routers. Dependencies are shared and overridable. This keeps code
testable, boundaries clear, and avoids the monolith of one large `main.py`.

### 5. How do you integrate gRPC with FastAPI?

**Answer:** FastAPI serves HTTP/ASGI; run a separate gRPC server (generated from
`.proto` files) alongside it in the same process or as a separate service. Use
gRPC for typed internal service-to-service calls and keep FastAPI for external
REST clients. Both can share the same services and repository layer.