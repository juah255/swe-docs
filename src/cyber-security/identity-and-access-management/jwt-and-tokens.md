# JWT and Tokens

JSON Web Tokens (`JWTs`) are signed tokens that can carry claims.

Use JWTs carefully:

- Validate signature, issuer, audience, expiration, and algorithm.
- Keep token lifetime short.
- Avoid storing sensitive data in token payloads.
- Plan revocation behavior before using long-lived tokens.
- Do not accept unsigned tokens.

Opaque tokens are random values looked up server-side; they are easy to
revoke and inspect. Stateless JWTs carry their own claims and make sense
when the receiver cannot call a token store, such as in service-to-service
authorization.

JWTs are useful for stateless authorization between services, but
traditional server-side sessions are often simpler for web applications.

Related: [Sessions and Cookies](sessions-and-cookies.md),
[OAuth 2.0](oauth-2.0.md).
