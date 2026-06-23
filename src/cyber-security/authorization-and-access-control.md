# Authorization and Access Control

Authorization decides what an authenticated user or service is allowed to do.

## Access Control Models

- **RBAC**: role-based access control. Permissions come from roles such as
  admin, manager, or viewer.
- **ABAC**: attribute-based access control. Decisions use attributes such as
  department, tenant, owner, region, or data sensitivity.
- **ReBAC**: relationship-based access control. Decisions use relationships
  such as owner, member, parent, or collaborator.

Most real systems combine these models.

## Object-Level Authorization

Insecure direct object reference (`IDOR`) happens when a user can access an
object by changing an ID in the request.

Defenses:

- Check authorization against the actual object, not only the endpoint.
- Include tenant and owner filters in database queries.
- Do not trust client-provided role, tenant, or owner fields.
- Test access across users, tenants, teams, and roles.

## Tenant Isolation

Multi-tenant systems need consistent tenant boundaries.

- Store tenant IDs with tenant-owned data.
- Add tenant filters to every query path.
- Avoid shared caches without tenant-aware keys.
- Log tenant context for sensitive actions.
- Test that one tenant cannot read or modify another tenant's data.

## Privilege Changes

Privilege changes should be auditable and carefully controlled.

- Require explicit permission to grant permissions.
- Re-authenticate for high-risk changes.
- Log actor, target, before state, after state, and reason.
- Review dormant admin accounts.
- Remove access when users leave a team or organization.
