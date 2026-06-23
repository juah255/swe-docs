# Authentication and Sessions

Authentication verifies who a user or service is. Session management keeps that
identity attached to later requests.

## Passwords

- Store passwords with a password-hashing algorithm and a unique salt.
- Never store plaintext passwords.
- Never encrypt passwords for later recovery.
- Rate-limit login attempts.
- Support password reset through short-lived, single-use tokens.
- Invalidate reset tokens after use.

Password rules should block known compromised passwords and allow long
passphrases.

## Multi-Factor Authentication

Multi-factor authentication (`MFA`) reduces account takeover risk.

Common factors:

- Something the user knows: password or PIN.
- Something the user has: authenticator app, hardware key, or device.
- Something the user is: biometric factor.

High-risk admin and financial workflows should require stronger factors.

## Sessions

Session best practices:

- Use random, high-entropy session IDs.
- Store session state server-side when possible.
- Set `HttpOnly`, `Secure`, and appropriate `SameSite` cookie flags.
- Rotate session IDs after login and privilege changes.
- Expire idle and long-lived sessions.
- Revoke sessions after password change or suspected compromise.

## JWTs

JSON Web Tokens (`JWTs`) are signed tokens that can carry claims.

Use JWTs carefully:

- Validate signature, issuer, audience, expiration, and algorithm.
- Keep token lifetime short.
- Avoid storing sensitive data in token payloads.
- Plan revocation behavior before using long-lived tokens.
- Do not accept unsigned tokens.

JWTs are useful for stateless authorization between services, but traditional
server-side sessions are often simpler for web applications.

## OAuth and OIDC

- OAuth 2.0 is an authorization framework.
- OpenID Connect (`OIDC`) adds authentication and identity claims on top of
  OAuth 2.0.

Use established libraries for OAuth/OIDC flows. Validate redirect URIs, state,
nonce, issuer, audience, and token lifetime.
