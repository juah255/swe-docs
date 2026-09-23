# Authentication, Authorization, and Sessions

Authentication establishes who the user is. Authorization decides what that
identity may do. They are related but separate checks.

## Use a Custom User Model Early

For a new project, define a custom user model before the first migration, even
if it initially extends Django's default implementation without extra fields.

```python
# accounts/models.py
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    pass
```

```python
# settings.py
AUTH_USER_MODEL = "accounts.User"
```

Changing `AUTH_USER_MODEL` after tables and foreign keys exist is complex. Other
models should refer to `settings.AUTH_USER_MODEL`; runtime code can use
`get_user_model()`.

## Logging In and Out

`authenticate()` asks configured authentication backends to verify credentials.
`login()` stores the chosen backend and user identifier in the session, while
`logout()` clears the session.

```python
from django.contrib.auth import authenticate, login

user = authenticate(request, username=username, password=password)
if user is None:
    form.add_error(None, "Invalid credentials")
else:
    login(request, user)
```

Use Django's password hashing APIs; never store or compare raw passwords. Apply
rate limiting or throttling to login, password-reset, and verification flows.
Django's core authentication does not provide comprehensive login throttling.

## Permissions and Groups

Django creates add, change, delete, and view permissions for each model. Users
can receive permissions directly or through groups.

```python
from django.contrib.auth.decorators import permission_required


@permission_required("orders.refund_order", raise_exception=True)
def refund(request, order_id):
    ...
```

Model permissions do not automatically implement object-level authorization.
An application must check ownership, tenant membership, or policy for the
specific row, or use a package that provides object permissions.

Centralize important policies so HTML views, API endpoints, admin actions, and
background jobs apply the same rules. Hiding a button is not authorization.

## Sessions

Session middleware associates a browser cookie with server-side or signed
session data, depending on the configured backend. Store small identifiers and
workflow state, not large objects or secrets.

Security-sensitive settings include:

- `SESSION_COOKIE_SECURE` and `CSRF_COOKIE_SECURE` for HTTPS deployments;
- `SESSION_COOKIE_HTTPONLY` to reduce script access;
- an appropriate `SESSION_COOKIE_SAMESITE` policy;
- session expiry and renewal behavior;
- cache or database durability when using those backends.

The signed-cookie backend signs data but does not encrypt it. A user can read
the cookie contents, and stolen signing keys can compromise all such sessions.

## Common Authorization Rules

- Deny access by default and grant the minimum required capability.
- Filter querysets by tenant or owner before fetching objects.
- Recheck authorization on every write, not only when rendering a page.
- Avoid accepting a tenant, role, price, or owner directly from user input.
- Audit privileged actions and permission changes.
- Test anonymous, ordinary, cross-tenant, and privileged cases separately.

For APIs, remember that authentication classes identify callers and permission
classes authorize requests. A valid token does not imply access to every object.

