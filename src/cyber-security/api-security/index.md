# API Security

API security covers how APIs authenticate callers, authorize actions, resist
abuse, and protect data across a variety of protocol styles, from REST and
GraphQL to gRPC and webhooks.

A secure API validates identity, authorization, input, output, and usage
patterns, and applies the same controls no matter which protocol carries the
requests.

## Topics

- [Secure API Design](secure-api-design.md): request/response design and abuse
  resistance for APIs.
- [API Authentication](api-authentication.md): cookies, bearer tokens,
  OAuth/OIDC, API keys, and mTLS.
- [API Authorization](api-authorization.md): scopes, roles, and object-level
  enforcement.
- [Rate Limiting](rate-limiting.md): why and how to limit request rates.
- [API Keys](api-keys.md): identifying callers, risks, and defenses.
- [HMAC Signatures](hmac-signatures.md): keyed request signing and replay
  protection.
- [Webhook Security](webhooks-security.md): verifying and safely delivering
  callbacks.
- [GraphQL Security](graphql-security.md): guarding single-endpoint abuse.
- [REST Security](rest-security.md): authentication, validation, and safe HTTP
  usage.
- [gRPC Security](grpc-security.md): securing service-to-service calls.
