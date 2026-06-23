# Web Security

Web security focuses on browser behavior, HTTP, cookies, scripts, cross-origin
requests, and user-controlled content.

## Cross-Site Scripting

Cross-site scripting (`XSS`) happens when untrusted content runs as JavaScript in
a user's browser.

Defenses:

- Escape output by context: HTML, attribute, URL, JavaScript, or CSS.
- Use framework-safe rendering defaults.
- Sanitize rich HTML with a trusted sanitizer.
- Avoid unsafe DOM APIs such as direct HTML insertion with untrusted strings.
- Use a restrictive content security policy where practical.
- Validate input, but do not rely on input validation alone.

Stored input must still be safely encoded when it is rendered.

## Cross-Site Request Forgery

Cross-site request forgery (`CSRF`) tricks a logged-in browser into sending a
state-changing request to another site.

Defenses:

- Use `SameSite` cookies.
- Use CSRF tokens for state-changing form requests.
- Check `Origin` or `Referer` for sensitive requests.
- Avoid unsafe state changes through `GET`.
- Require re-authentication or confirmation for high-risk actions.

## CORS

Cross-origin resource sharing (`CORS`) controls whether browser JavaScript from
one origin can read responses from another origin.

CORS is not authentication or authorization. It is enforced by browsers, not by
tools such as backend services, `curl`, or Postman.

Common mistakes:

- Reflecting arbitrary origins.
- Combining wildcard origins with credentials.
- Assuming CORS blocks server-to-server requests.
- Allowing sensitive APIs without proper authentication and authorization.

## Cookies

Important cookie flags:

- `HttpOnly`: blocks JavaScript access to the cookie.
- `Secure`: sends the cookie only over HTTPS.
- `SameSite`: reduces cross-site cookie sending.
- `Path` and `Domain`: limit where the cookie is sent.

Session cookies should be scoped narrowly and rotated after login or privilege
changes.

## Security Headers

Useful headers:

- `Content-Security-Policy`.
- `Strict-Transport-Security`.
- `X-Content-Type-Options`.
- `Referrer-Policy`.
- `Permissions-Policy`.

Headers are supporting controls. They do not replace safe rendering, correct
authorization, or secure session handling.
