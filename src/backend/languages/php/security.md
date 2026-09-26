# Security

PHP provides safe primitives, but application security depends on using the
right control for each boundary. Validation, escaping, authorization, database
constraints, infrastructure limits, and dependency management solve different
problems.

## SQL and Command Injection

Use prepared database statements for values and allowlists for identifiers. For
operating-system processes, prefer a process API that accepts an argument array.
If a shell is unavoidable, escape each argument for the actual platform and do
not let user input determine the executable or command structure.

Avoid dynamic `include`, `require`, template, or filesystem paths from user
input. Resolve paths beneath an owned root and reject traversal and symlink
escapes as required by the use case.

## Cross-Site Scripting

Escape at output for the actual context. For an HTML text or quoted attribute
context:

```php
echo htmlspecialchars(
    $displayName,
    ENT_QUOTES | ENT_SUBSTITUTE,
    'UTF-8',
);
```

HTML escaping is not sufficient for JavaScript, CSS, URLs, or HTTP headers.
Prefer framework templates with automatic contextual escaping. Sanitize rich
HTML with a maintained allowlist-based sanitizer, and add a Content Security
Policy as defense in depth.

## CSRF and CORS

Unsafe browser requests authenticated by cookies need CSRF protection. Generate
a cryptographically random token, bind it to the session or request strategy,
and compare it with `hash_equals()`.

`SameSite` cookies help but do not replace a complete CSRF design. CORS controls
which cross-origin browser scripts can access responses; it is not authentication
or authorization.

## Passwords and Tokens

Use `password_hash()` and `password_verify()` with a supported adaptive
algorithm. Check `password_needs_rehash()` after successful login so parameters
can evolve.

Generate security tokens with `random_bytes()` and encode them safely. Store a
hash of long-lived reset or API tokens where possible, apply expiry and single
use, and use constant-time comparison for secrets.

Rate-limit login, reset, registration, and verification endpoints. Avoid account
enumeration where it would expose sensitive membership.

## Sessions and Authorization

Use secure, HTTP-only, appropriately scoped cookies and rotate the session ID
after a privilege change. Do not accept a session identifier in a URL.

Authenticate the caller, then authorize every operation and object. Filter
queries by tenant or owner instead of fetching an arbitrary record and checking
later. Never derive trusted roles, prices, owners, or tenant IDs from writable
request fields.

## File Uploads

Treat the filename, extension, MIME declaration, and content as untrusted.

- Enforce body and file-size limits at the proxy and application.
- Inspect content using appropriate libraries or scanning systems.
- Generate storage names and keep uploads outside executable code paths.
- Serve active formats from a separate origin or force safe downloads.
- Protect image and archive processors from decompression bombs.

`move_uploaded_file()` helps confirm PHP-upload provenance; it does not validate
the content.

## Deserialization and SSRF

Never call `unserialize()` on attacker-controlled data. Object injection can
trigger magic methods in available classes. Use a constrained data format such
as JSON and validate the decoded structure.

For server-side HTTP requests, allow expected schemes and destinations, resolve
and check addresses, block loopback and private infrastructure as appropriate,
limit redirects and response size, and apply timeouts. URL syntax validation
alone does not prevent SSRF or DNS rebinding.

## Production Baseline

- Run a supported PHP release and patch extensions and OS packages.
- Keep `display_errors` off and structured error logging on.
- Store secrets outside source and rotate them.
- Set secure session, upload, body, execution, and memory limits.
- Remove unused extensions and disable unnecessary runtime capabilities.
- Run Composer audits and review dependency changes and scripts.
- Protect logs, backups, debug tools, and administrative endpoints.
- Test anonymous, ordinary, privileged, and cross-tenant access.

