# Sessions and Cookies

Session management keeps an authenticated identity attached to later
requests, and cookies are a common way to carry session state.

## Sessions

Session best practices:

- Use random, high-entropy session IDs.
- Store session state server-side when possible.
- Set `HttpOnly`, `Secure`, and appropriate `SameSite` cookie flags.
- Rotate session IDs after login and privilege changes.
- Expire idle and long-lived sessions.
- Revoke sessions after password change or suspected compromise.

## Cookies

Important cookie flags:

- `HttpOnly`: blocks JavaScript access to the cookie.
- `Secure`: sends the cookie only over HTTPS.
- `SameSite`: reduces cross-site cookie sending.
- `Path` and `Domain`: limit where the cookie is sent.

Session cookies should be scoped narrowly and rotated after login or
privilege changes.

Related: [Authentication](authentication.md),
[JWT and Tokens](jwt-and-tokens.md).
