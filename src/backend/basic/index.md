# Basic

**Business Logic:** It is the set of rules and processes that determine how an application handles data and fulfills business requirements.

**Business Requirements:** It is a specific goal or need that the software must fulfill to solve a business problem or deliver value to users.

what happens when you enter a url in the browser?

The browser performs a DNS lookup, establishes a TCP connection with the server, performs a TLS handshake if HTTPS is used, sends the HTTP request, receives the HTTP response, downloads additional resources, and renders the page.

## Mid/Senior Interview Questions and Answers

### 1. What happens when a backend receives an HTTP request?

**Answer:** The server accepts the connection, parses the request, applies
middleware, authenticates and authorizes where needed, validates input, runs
application logic, accesses dependencies such as databases or caches, and
returns a response.

Production systems also log, trace, measure latency, enforce timeouts, and
handle errors consistently.

### 2. What is the difference between validation and sanitization?

**Answer:** Validation decides whether input is acceptable. Sanitization cleans
or normalizes input before storage or processing.

Escaping is separate and should happen when output is rendered into a specific
context such as HTML, SQL, JSON, or a shell command.

### 3. Why are environment variables used in backend services?

**Answer:** Environment variables provide deployment-specific configuration such
as ports, database URLs, feature flags, and service endpoints without changing
the application artifact.

Secrets should come from a secret manager or protected runtime environment, not
from committed files.

### 4. What makes a backend endpoint production-safe?

**Answer:** It validates input, enforces authorization, uses timeouts, handles
errors without leaking internals, logs useful context, avoids unbounded work,
and protects shared data with transactions or constraints.

Correctness, security, and operability matter as much as returning the happy
path response.
