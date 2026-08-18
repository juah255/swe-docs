# Request & Response Handling

Headers, cookies, forms, file uploads, streaming, custom responses, and error handling.

## Headers

Read request headers by declaring a parameter with `Header()`:

```python
from fastapi import Header

@app.get("/items")
def read_items(user_agent: str | None = Header(default=None)):
    return {"user-agent": user_agent}
```

Header names are converted automatically (`user-agent` → `user_agent`). Multiple values use `list[str]`.

## Cookies

Read cookies with `Cookie()`:

```python
from fastapi import Cookie

@app.get("/me")
def read_me(session_id: str | None = Cookie(default=None)):
    return {"session": session_id}
```

Set cookies on the response:

```python
from fastapi import Response

@app.post("/login")
def login(resp: Response):
    resp.set_cookie(
        key="session_id",
        value="abc123",
        httponly=True,
        samesite="lax",
        secure=True,
    )
    return {"ok": True}
```

Use `httponly=True` so JavaScript cannot read the cookie, reducing XSS risk.

## Forms

HTML form data (URL-encoded or multipart) uses `Form()`:

```bash
pip install python-multipart
```

```python
from fastapi import Form

@app.post("/login")
def login(username: str = Form(...), password: str = Form(...)):
    return {"username": username}
```

`Form` and `JSON` bodies are mutually exclusive per endpoint; use forms for
traditional web forms, JSON for APIs.

## File uploads

Single file with `UploadFile`:

```python
from fastapi import UploadFile

@app.post("/upload")
async def upload(file: UploadFile):
    contents = await file.read()
    return {"filename": file.filename, "size": len(contents)}
```

`UploadFile` streams the file and exposes `filename`, `content_type`, `read()`,
`seek()`, and `write()`. Prefer `await file.read()` over blocking reads. Use
`File()` for raw `bytes` when you want the whole file in memory:

```python
from fastapi import File

@app.post("/upload")
async def upload(file: bytes = File(...)):
    return {"size": len(file)}
```

## Multiple file uploads

```python
from fastapi import File, UploadFile

@app.post("/upload-multiple")
async def upload_many(files: list[UploadFile] = File(...)):
    return [{"filename": f.filename} for f in files]
```

Use `list[UploadFile]` (or `list[bytes]`) to accept multiple files.

## Streaming responses

Stream data without buffering the whole response - useful for large files, logs, or generated content:

```python
from fastapi.responses import StreamingResponse

@app.get("/download")
def download():
    def iter_file():
        with open("big.csv", "rb") as f:
            yield from f
    return StreamingResponse(iter_file(), media_type="text/csv")
```

`StreamingResponse` with an async generator:

```python
import asyncio
from fastapi.responses import StreamingResponse

@app.get("/stream")
async def stream():
    async def gen():
        for i in range(10):
            await asyncio.sleep(0.1)
            yield f"data: {i}\n\n"
    return StreamingResponse(gen(), media_type="text/event-stream")
```

## JSON responses

The default. Use `JSONResponse` directly for fine control:

```python
from fastapi.responses import JSONResponse

@app.get("/custom")
def custom():
    return JSONResponse(content={"hello": "world"}, status_code=200)
```

Return a dict/Pydantic model and FastAPI handles serialization automatically. `JSONResponse` bypasses `response_model` filtering, so prefer returning plain values.

## Custom responses

Other built-in responses:

```python
from fastapi.responses import (
    HTMLResponse,
    PlainTextResponse,
    RedirectResponse,
    FileResponse,
)

@app.get("/page", response_class=HTMLResponse)
def page():
    return "<h1>Hello</h1>"

@app.get("/redirect")
def go():
    return RedirectResponse("/page")

@app.get("/file")
def file():
    return FileResponse("report.pdf")
```

Set `response_class=` on the decorator or return the response object directly.

## Response headers

```python
from fastapi import Response

@app.get("/items")
def items(resp: Response):
    resp.headers["X-Request-Id"] = "abc"
    resp.headers["Cache-Control"] = "max-age=60"
    return {"items": []}
```

## Error handling

`HTTPException` is the standard way to raise HTTP errors:

```python
from fastapi import HTTPException

@app.get("/items/{id}")
def get_item(id: int):
    item = find(id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item
```

FastAPI returns `{"detail": "Item not found"}` with status 404. Add headers for
rate-limit or auth error metadata:

```python
raise HTTPException(
    status_code=401,
    detail="Invalid token",
    headers={"WWW-Authenticate": "Bearer"},
)
```

## Custom exception handlers

Handle your own exception types:

```python
from fastapi import Request, FastAPI
from fastapi.responses import JSONResponse

class AppError(Exception):
    def __init__(self, code: str, status: int, detail: str):
        self.code = code
        self.status = status
        self.detail = detail

app = FastAPI()

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    return JSONResponse(
        status_code=exc.status,
        content={"detail": exc.detail, "code": exc.code},
    )
```

Customize the default validation error response:

```python
from fastapi.exceptions import RequestValidationError

@app.exception_handler(RequestValidationError)
async def validation_error_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={"detail": "Validation failed", "errors": exc.errors()},
    )
```

Always return structured JSON for errors: `{"detail": "...", "code": "..."}`.

## Mid/Senior Interview Questions and Answers

### 1. How do you read and set headers in FastAPI?

**Answer:** Declare a parameter with `Header()` to read headers (names are
underscored and case-insensitive). To set response headers, add a `Response`
parameter to the endpoint and assign `resp.headers["X-Name"] = "value"`, or use
`response.headers` inside an exception handler. Middleware can also set headers
for every response.

### 2. What is the difference between `UploadFile` and `bytes` for file uploads?

**Answer:** `UploadFile` wraps a spooled file and streams contents, so large
files never fully load into memory and you can read them incrementally. `bytes`
reads the entire file into memory before the endpoint runs - fine for small
files, dangerous for large ones. Use `UploadFile` and read asynchronously for
production uploads.

### 3. When would you use `StreamingResponse`?

**Answer:** When the response should not be fully buffered in memory: large file
downloads, generated CSV/PDFs, or SSE/event streams. It sends chunks as they are
produced, improving memory use and time-to-first-byte. Streaming also lets the
client consume data before the source finishes.

### 4. How do you customize error responses globally?

**Answer:** Register handlers with `@app.exception_handler` for `HTTPException`,
`RequestValidationError`, and your own exception classes. Return `JSONResponse`
with a consistent structure (`detail`, `code`, `errors`). Middleware can act as a
catch-all for unhandled exceptions and logging.

### 5. What is the difference between `Response`, `JSONResponse`, and returning a dict?

**Answer:** Returning a dict or Pydantic model lets FastAPI apply `response_model`
filtering, serialization, and the documented OpenAPI schema. `JSONResponse`
gives explicit control over the exact JSON content and status but bypasses
response-model filtering. A bare `Response` object is the raw interface for
custom media types and streaming.