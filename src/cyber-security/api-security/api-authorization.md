# API Authorization

- Enforce authorization on every sensitive endpoint.
- Check object-level access, not only route-level access.
- Do not trust client-provided role or tenant fields.
- Use scoped tokens for limited access.
- Return minimal information on authorization failure.

Scopes vs roles:

- Scopes limit what a token may do (e.g. `read:orders`); roles group
  permissions for a user (e.g. `admin`, `billing`).
- Apply both: map roles to permissions and keep tokens scoped to the narrowest
  set of actions they need.
- Always enforce server-side. Client-side checks or hidden UI buttons are not
  access control.
