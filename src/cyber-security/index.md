# Cyber Security

Cyber security notes organized by topic.

- csrf
- CORS (Cross Origin Resource Sharing)

## Mid/Senior Interview Questions and Answers

### 1. What is CSRF?

**Answer:** Cross-site request forgery tricks a logged-in browser into sending a
state-changing request to a site where the user is authenticated.

Defenses include `SameSite` cookies, CSRF tokens, checking origin or referer for
sensitive requests, and avoiding unsafe state changes through `GET`.

### 2. What is CORS, and what does it not protect?

**Answer:** CORS controls whether browser JavaScript from one origin can read
responses from another origin. It is enforced by browsers.

CORS is not authentication, authorization, or server-to-server protection.
Postman, curl, and backend services are not blocked by browser CORS rules.

### 3. How do you prevent XSS?

**Answer:** Escape output by context, sanitize rich HTML, avoid unsafe DOM APIs,
use framework-safe rendering defaults, validate input, and apply a restrictive
content security policy where practical.

Storing untrusted input safely is not enough. Output must be encoded for the
specific context where it appears.

### 4. How do you prevent SQL injection?

**Answer:** Use parameterized queries, prepared statements, query builders, or
ORM APIs that bind values safely. Never concatenate untrusted input into SQL.

Database permissions should also be least-privilege so one injection does not
become full database compromise.

### 5. What is the difference between hashing and encryption?

**Answer:** Hashing is one-way and used for integrity or password verification.
Encryption is reversible with a key and used for confidentiality.

Passwords should be hashed with a password-hashing algorithm and per-password
salt, not encrypted for later recovery.
