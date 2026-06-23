# Injection and Input Validation

Injection happens when untrusted input is interpreted as code, commands, query
syntax, file paths, or internal instructions.

## SQL Injection

SQL injection occurs when untrusted input changes the meaning of a SQL query.

Defenses:

- Use parameterized queries or prepared statements.
- Use query builders or ORM APIs that bind values safely.
- Avoid concatenating untrusted input into SQL.
- Use least-privilege database accounts.
- Validate sort fields, column names, and table names with allowlists.

## Command Injection

Command injection occurs when input reaches an operating system command.

Defenses:

- Avoid shell execution for user-controlled input.
- Prefer library APIs over command-line calls.
- Pass arguments as structured arrays when execution is required.
- Validate inputs with allowlists.
- Run processes with least privilege.

## Server-Side Request Forgery

Server-side request forgery (`SSRF`) occurs when an attacker controls a server's
outbound request target.

Defenses:

- Allowlist destinations.
- Block private and metadata IP ranges where appropriate.
- Resolve and validate hostnames carefully.
- Disable redirects or revalidate redirected targets.
- Use network egress controls.

## Path Traversal

Path traversal occurs when input changes a filesystem path outside the intended
directory.

Defenses:

- Use object storage IDs instead of raw paths.
- Normalize and validate paths.
- Restrict access to an allowed base directory.
- Avoid serving files based directly on user-provided paths.

## Validation Strategy

- Validate input at system boundaries.
- Prefer allowlists over denylists.
- Enforce type, length, range, enum, and format constraints.
- Validate again before sensitive operations if data has crossed trust
  boundaries.
