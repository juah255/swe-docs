# Security Headers

Useful headers:

- `Content-Security-Policy`.
- `Strict-Transport-Security`.
- `X-Content-Type-Options`.
- `Referrer-Policy`.
- `Permissions-Policy`.

Headers are supporting controls. They do not replace safe rendering, correct
authorization, or secure session handling.

## Purpose

- `Content-Security-Policy`: restricts which resources a page can load (see
  [Content Security Policy](csp.md)).
- `Strict-Transport-Security`: forces browsers to use HTTPS and prevents
  downgrade attacks.
- `X-Content-Type-Options`: stops browsers from MIME-sniffing a response and
  misinterpreting its type.
- `Referrer-Policy`: controls how much referrer information is sent in requests
  to other origins.
- `Permissions-Policy`: restricts which browser features the page and its frames
  can use.
- `X-Frame-Options`: prevents the page from being framed by other origins (see
  [Clickjacking](clickjacking.md)).

Cross-links:

- [Content Security Policy](csp.md)
- [Clickjacking](clickjacking.md)
- [HTTPS and TLS](../cryptography/https-and-tls.md) for `Strict-Transport-Security`.
