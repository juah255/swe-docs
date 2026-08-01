# OpenID Connect

OpenID Connect (`OIDC`) adds authentication and identity claims on top of
OAuth 2.0. It is used to log users in and tell the client who they are.

## Key Components

- ID token: a JWT carrying identity claims about the user.
- Userinfo endpoint: returns additional profile claims for the access
  token.
- Discovery: the provider publishes endpoints and supported options.

## Validation

- Verify the ID token signature, issuer, and audience.
- Validate the nonce to tie the token to the original request.
- Use established libraries for OIDC flows.

## Why Use OIDC for Login

- Enables single sign-on (`SSO`) across applications.
- The client never sees the user's password.
- Identity is managed in one place.

Related: [OAuth 2.0](oauth-2.0.md),
[Authentication](authentication.md).
