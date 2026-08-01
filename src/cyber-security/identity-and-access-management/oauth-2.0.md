# OAuth 2.0

OAuth 2.0 is an authorization framework. It lets an application obtain
scoped access to resources on behalf of a user or service without handling
the user's credentials.

## Roles

- Resource owner: the user or system that owns the protected data.
- Client: the application requesting access.
- Authorization server: issues tokens after authenticating the owner.
- Resource server: serves the protected resource using the token.

## Common Flows

- Authorization code with PKCE: the standard flow for web and native apps;
  PKCE prevents code interception.
- Client credentials: used for server-to-server access where there is no
  user.

## Token Types

- Access token: grants access to resources for a limited time.
- Refresh token: obtains new access tokens without re-authenticating.

## Validation

Use established libraries for OAuth flows. Validate redirect URIs, state,
and audience, and keep access token lifetime short.

Related: [OpenID Connect](openid-connect.md),
[JWT and Tokens](jwt-and-tokens.md).
