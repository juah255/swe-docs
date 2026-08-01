# Authentication

Authentication verifies who a user or service is. It answers the question
"who is making this request?" and establishes an identity that later
requests carry.

Common methods:

- Password: verifies something the user knows.
- MFA: combines multiple factors to reduce account takeover risk.
- Tokens: signed or opaque tokens carry a verified identity across requests.
- SSO via OpenID Connect: lets one identity provider log users in.
- Client certificates: bind identity to a device or service.
- API keys: identify services and integrations.

Choose the method based on risk and context: humans, services, and internal
integrations have different needs.

Related: [Password Security](password-security.md),
[MFA](mfa.md), [JWT and Tokens](jwt-and-tokens.md),
[OAuth 2.0](oauth-2.0.md).
