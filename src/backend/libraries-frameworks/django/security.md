# Security

Django provides strong defaults, but it cannot determine an application's
authorization rules, deployment topology, data sensitivity, or abuse limits.
Security depends on both framework configuration and application design.

## Production Baseline

- Set `DEBUG = False` and configure precise `ALLOWED_HOSTS` values.
- Load `SECRET_KEY` and credentials from a secret store or protected environment.
- Terminate and enforce HTTPS; use secure session and CSRF cookies.
- Configure HSTS only after verifying HTTPS for every relevant host.
- Keep Django and dependencies on supported, patched versions.
- Run `python manage.py check --deploy` with production settings.
- Return generic error responses while recording safe diagnostic context.

If a trusted reverse proxy terminates TLS, configure forwarded host and scheme
handling narrowly. Set `SECURE_PROXY_SSL_HEADER` only when the named header is
removed and rewritten by infrastructure you control.

## Cross-Site Scripting

Django templates escape variable output in HTML contexts by default. That does
not make arbitrary HTML, JavaScript, CSS, URLs, or DOM manipulation safe.

- Avoid marking user content safe.
- Sanitize rich text with an allowlist-based HTML sanitizer.
- Quote template attributes and validate URL schemes.
- Avoid placing data directly into executable script contexts.
- Use a Content Security Policy as defense in depth.

Django 6.0 includes built-in Content Security Policy support. Projects on older
versions can configure CSP at the proxy or through a maintained package.

## CSRF and Browser Authentication

Django's CSRF middleware protects unsafe requests that rely on browser cookies.
Include the token in forms and eligible JavaScript requests, configure trusted
origins carefully, and do not exempt a view without understanding the complete
authentication path.

`SameSite` cookies help but do not replace CSRF protection. CORS controls whether
a browser exposes cross-origin responses; it is not an authorization mechanism.

## SQL Injection

Normal ORM filters parameterize values. Injection risks return when code builds
raw SQL, table names, `extra()` fragments, or custom expressions from untrusted
strings.

```python
with connection.cursor() as cursor:
    cursor.execute(
        "SELECT id, reference FROM orders_order WHERE reference = %s",
        [reference],
    )
```

Bound parameters protect values, not arbitrary identifiers. Whitelist dynamic
ordering fields, column names, and operations.

## Authentication and Authorization

Use Django's password hashers and session rotation behavior. Rate-limit
credential, reset, and verification endpoints. Require reauthentication for
sensitive changes where appropriate and protect administrator accounts with
stronger controls.

Enforce object and tenant authorization in queries and write workflows. Test
horizontal privilege escalation, not only anonymous access. An authenticated
user is still untrusted.

## Uploads and Request Bodies

Uploads can exhaust memory, disk, parsers, image libraries, and downstream
scanners. Enforce limits at the edge as well as in application code, because an
ASGI server may receive or spool request data before a view rejects it.

Generate storage names, validate content rather than trusting the extension or
declared MIME type, and serve untrusted media away from the application's origin
when possible. Prevent uploaded HTML or SVG from becoming same-origin active
content.

## Other Protections

- Keep clickjacking middleware and an appropriate frame policy unless framing is
  an intentional, constrained feature.
- Prevent open redirects by validating return URLs with Django's URL helpers.
- Avoid exposing secrets, credentials, cookies, or personal data in logs.
- Add request deadlines, rate limits, and body limits outside Django too.
- Secure admin URLs and accounts, but do not rely on a hidden path as the control.
- Back up data, test restoration, and protect backups to the same standard.

Threat-model high-risk features such as payments, webhooks, password resets,
file processing, and multi-tenant access instead of relying on a checklist alone.

