# Authentication & Authorization

Very important for real-world APIs. Password hashing, OAuth2, JWT, tokens, cookies, sessions, role/permission-based authorization, and protecting routes.

## Password hashing

Never store plain-text passwords. Use `passlib` + `bcrypt` (or `argon2`):

```bash
pip install passlib[bcrypt] bcrypt
```

```python
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)
```

Bcrypt is slow by design, which makes brute force expensive. Add rate limiting
on the login endpoint.

## OAuth2

FastAPI ships `OAuth2PasswordBearer` and `OAuth2PasswordRequestForm` for the
password flow:

```python
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

@app.post("/auth/login")
def login(form: OAuth2PasswordRequestForm = Depends()):
    user = authenticate(form.username, form.password)
    token = create_access_token({"sub": str(user.id)})
    return {"access_token": token, "token_type": "bearer"}
```

`OAuth2PasswordBearer` automatically parses the `Authorization: Bearer <token>`
header and is documented in the OpenAPI security scheme.

## JWT

```bash
pip install python-jose[cryptography]
```

```python
from jose import jwt, JWTError
from datetime import datetime, timedelta, timezone

SECRET_KEY = settings.jwt_secret
ALGORITHM = "HS256"

def create_access_token(subject: str, expires_minutes: int = 15) -> str:
    payload = {
        "sub": subject,
        "exp": datetime.now(timezone.utc) + timedelta(minutes=expires_minutes),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def decode_token(token: str) -> dict:
    return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
```

JWT = `header.payload.signature`. Use a long random secret, prefer `RS256` for
multi-service systems, and keep tokens short-lived.

## Access tokens

The access token authenticates API requests. It is sent as
`Authorization: Bearer <token>` and verified by the auth dependency:

```python
from fastapi import Depends, HTTPException, status

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
):
    credentials_exc = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_token(token)
        user_id = int(payload["sub"])
    except (JWTError, KeyError):
        raise credentials_exc

    user = await db.get(User, user_id)
    if user is None:
        raise credentials_exc
    return user
```

## Refresh tokens

Refresh tokens are long-lived and used only to mint new access tokens:

```python
def create_refresh_token(subject: str) -> str:
    return create_token(subject, expires_minutes=60 * 24 * 7)

@app.post("/auth/refresh")
def refresh(refresh_token: str = Form(...)):
    payload = decode_token(refresh_token)
    return {"access_token": create_access_token(payload["sub"])}
```

Production best practices: store refresh tokens hashed in the database, rotate
them on every refresh, and revoke on logout.

## Bearer authentication

Use `HTTPBearer` when you need manual control over the scheme:

```python
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

def require_token(creds: HTTPAuthorizationCredentials = Depends(security)):
    return decode_token(creds.credentials)
```

`OAuth2PasswordBearer` is simpler for the standard flow; `HTTPBearer` gives the
raw credentials for custom verification.

## HTTP-only cookies

Store the refresh token (or even the access token) in an HttpOnly cookie to
reduce XSS exposure:

```python
from fastapi import Response

@app.post("/auth/login")
def login(resp: Response, form: OAuth2PasswordRequestForm = Depends()):
    user = authenticate(form.username, form.password)
    access = create_access_token(str(user.id))
    refresh = create_refresh_token(str(user.id))
    resp.set_cookie(
        key="access_token", value=access,
        httponly=True, secure=True, samesite="lax", max_age=900,
    )
    resp.set_cookie(
        key="refresh_token", value=refresh,
        httponly=True, secure=True, samesite="lax", max_age=604800,
    )
    return {"message": "ok"}
```

Read cookies with `Cookie()` and attach the user from the cookie token.

## Session authentication

Server-side sessions store state and send only an opaque session ID:

- Store session data in Redis/Postgres, keyed by a random ID.
- The ID goes in an HttpOnly cookie.
- Verify by looking up the session on each request.

Sessions are easy to revoke but require a lookup per request. JWTs are stateless
but harder to revoke. Many systems combine a short-lived JWT with a revocable
refresh token.

## Role-based authorization

Check the user's role in a dependency:

```python
def require_roles(*roles: str):
    async def checker(user: User = Depends(get_current_user)):
        if user.role not in roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return user
    return checker

@app.get("/admin")
def admin_panel(user: User = Depends(require_roles("admin"))):
    return {"secret": True}
```

Apply per-route or per-router:

```python
admin_router = APIRouter(
    prefix="/admin",
    dependencies=[Depends(require_roles("admin"))],
)
```

## Permission-based authorization

Finer-grained than roles:

```python
def require_permission(permission: str):
    async def checker(user: User = Depends(get_current_user)):
        if permission not in user.permissions:
            raise HTTPException(status_code=403, detail="Missing permission")
        return user
    return checker

@app.delete("/users/{user_id}")
def delete_user(
    user_id: int,
    user: User = Depends(require_permission("users:delete")),
):
    ...
```

Prefer permission checks over role checks when permissions evolve, because
permissions survive role renames.

## OAuth/social login

Let users sign in with Google/GitHub. The authorization-code flow:

1. Redirect the user to the provider with `client_id` and `redirect_uri`.
2. The provider redirects back with an authorization `code`.
3. Exchange the code for tokens via the provider's token endpoint.
4. Verify the identity and link it to a local user.
5. Issue your own access/refresh tokens.

Use a library such as `Authlib` or `python-social-auth` instead of hand-rolling
the OAuth dance.

## Protecting routes

The pattern:

```
Client
   ↓
Login
   ↓
Access Token
   ↓
Authentication Dependency (get_current_user)
   ↓
Protected Endpoint
```

- Add `Depends(get_current_user)` to the endpoint signature or to a router's
  `dependencies=[...]`.
- Always return `401` for missing/invalid credentials and `403` for forbidden
  (authenticated but not allowed).
- Set `WWW-Authenticate` on 401s.
- Exclude public routes (login, register, health) from the auth dependency.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between authentication and authorization?

**Answer:** Authentication verifies identity - who you are - via credentials
(password, JWT, session). Authorization decides what that identity may do -
which routes or resources - via roles or permissions. Authentication always runs
first and produces the user that authorization rules inspect.

### 2. Why separate access and refresh tokens?

**Answer:** Short-lived access tokens (minutes) limit the damage if stolen and
are verified locally without a database lookup. Refresh tokens (days/weeks) let
the client obtain new access tokens without re-login. Because refresh tokens are
stored and rotated server-side, they can be revoked - something a stateless JWT
cannot do.

### 3. How does `OAuth2PasswordBearer` work?

**Answer:** It reads the `Authorization: Bearer <token>` header, extracts the
token, and injects it as a string into the dependency. It also documents the
bearer security scheme in OpenAPI so the Swagger UI can authorize requests. It
does not verify the token itself - you verify it in `get_current_user`.

### 4. Cookies vs bearer tokens for storage - what are the trade-offs?

**Answer:** HttpOnly cookies are automatically sent by the browser and cannot be
read by JavaScript, reducing XSS token theft, but they are vulnerable to CSRF
(mitigate with SameSite/CSRF tokens). Bearer tokens in the `Authorization` header
are not auto-sent (no CSRF), but if stored in localStorage they can be stolen by
XSS. SPAs often prefer bearer tokens; server-rendered apps often prefer
HttpOnly cookies.

### 5. How do you implement role-based access control in FastAPI?

**Answer:** Use dependencies: `get_current_user` authenticates, then a
`require_roles(...)` dependency factory checks `user.role` and returns 403 when
it does not match. Apply it per-route with `Depends(...)` or to a whole router
via `dependencies=[...]`. Keep the role/permission check in a dependency so it
is testable and reusable.