# Authorization

**Authorization** is the process of determining what an authenticated user is allowed to do. It answers the question: "What are you allowed to access?"

## Roles (RBAC)

**Role-Based Access Control (RBAC)** assigns permissions to roles, and users are assigned to roles.

```
User -> Role -> Permissions
```

Example:

```json
{
  "user": "alice",
  "roles": ["editor", "viewer"]
}
```

- Simple to understand and implement
- Works well for most applications
- Can become rigid when permissions grow complex
- Role explosion is a common problem (too many fine-grained roles)

## Permissions

**Permissions** are granular actions that can be performed on resources.

```text
articles:create
articles:update
articles:delete
orders:read
```

- Permissions are the building blocks of authorization
- Roles are collections of permissions
- Should be defined at the resource-action level
- Checked at the API or service layer, not just the UI

## Claims

**Claims** are key-value pairs in a token (JWT) that carry identity and authorization information.

Common claims:

- `sub` -- subject (user ID)
- `role` -- user role
- `email` -- user email
- `iat` -- issued at time
- `exp` -- expiration time

Custom claims can carry permissions, tenant ID, or any application-specific data. Claims should be minimal -- store only what is needed for authorization decisions.

## Scopes

**Scopes** define the extent of access that a token grants. They are commonly used in OAuth2 flows.

```text
read:users
write:orders
admin:*
```

- Scopes are requested by the client during the OAuth2 flow
- The user (or authorization server) grants a subset of requested scopes
- Scopes control **what** the application can do, not what the user can do
- Fine-grained scopes improve security by limiting token power

## ACL (Access Control Lists)

An **ACL** is a list of permissions attached to a resource, specifying which users or groups can perform which actions.

```text
File: report.pdf
  - Alice: read, write
  - Bob: read
  - Group admins: read, write, delete
```

- Simple and intuitive for file systems and small-scale systems
- Does not scale well for complex applications
- Hard to audit across many resources
- Often used at the infrastructure or OS level

## ABAC (Attribute-Based Access Control)

**ABAC** makes authorization decisions based on attributes of the user, resource, action, and environment.

```text
IF user.department == "finance"
   AND resource.classification == "confidential"
   AND action == "read"
   AND time.hour BETWEEN 9 AND 17
THEN allow
```

- Very flexible and fine-grained
- Can express complex policies that RBAC cannot
- More complex to implement and audit
- Policies are usually stored in a policy engine (Open Policy Agent, Casbin)

## Policy-based Authorization

**Policy-based authorization** centralizes authorization logic into externalized, reusable policies. Policies are evaluated at runtime to make access decisions.

Tools and frameworks:

- **Open Policy Agent (OPA)** -- general-purpose policy engine using Rego
- **Casbin** -- policy enforcement library with multiple model support
- **AWS Cedar** -- policy language for application authorization

Benefits:

- Separation of authorization logic from application code
- Policies can be versioned, tested, and audited independently
- Supports RBAC, ABAC, and custom models in a unified framework

## Comparison

| Model | Granularity | Complexity | Scalability | Best For |
|---|---|---|---|---|
| RBAC | Medium | Low | High | Most applications |
| Permissions | High | Low | High | Building blocks |
| Claims | Medium | Low | High | Token-based auth |
| Scopes | Medium | Low | High | OAuth2 APIs |
| ACL | Low | Low | Low | File systems |
| ABAC | High | High | High | Complex enterprises |
| Policy-based | High | Medium | High | Large-scale systems |

## Mid/Senior Interview Questions and Answers

### 1. When should you choose RBAC over ABAC?

**Answer:** RBAC works well when authorization follows clear organizational
roles and does not change based on context. It is simpler to implement, audit,
and explain to stakeholders.

ABAC is better when decisions depend on multiple attributes such as resource
classification, time, location, or department. If policies cannot be expressed
as simple role checks, ABAC or policy-based authorization is a better fit.

### 2. What is role explosion and how do you prevent it?

**Answer:** Role explosion happens when fine-grained permissions lead to an
excessive number of roles, each representing a specific combination of
permissions. This makes roles hard to manage and audit.

Prevent it by separating permissions from roles, using attribute-based or
policy-based models for fine-grained access, and keeping roles at a
coarse-grained level while evaluating details at the permission or policy layer.

### 3. How do scopes differ from roles?

**Answer:** Scopes define what an application or token is allowed to do. Roles
define what a user is allowed to do. Scopes are requested during token creation
and limit the token's power. Roles are attributes of the user and determine
their permissions regardless of which application is acting on their behalf.

In OAuth2, a client might request `read:users` scope, but the user's role
determines whether that scope is granted.

### 4. What is the principle of least privilege in authorization?

**Answer:** Grant only the minimum permissions needed to perform a task. Users,
services, and tokens should not have more access than required.

This limits the blast radius of compromised accounts, reduces the impact of
misconfigurations, and makes security audits easier. Permissions should be
reviewed and revoked when no longer needed.

### 5. How do you implement authorization in a microservices architecture?

**Answer:** Each service should validate tokens and enforce its own
authorization rules. Use a centralized policy engine (OPA, Cedar) or
service-specific RBAC/ABAC checks.

Claims or scopes from the token should carry enough information for each service
to make independent authorization decisions. Avoid relying on a single
authorization service as a bottleneck or single point of failure.

### 6. What are the trade-offs of externalizing authorization with OPA or Cedar?

**Answer:** Externalized policy engines centralize authorization logic, make
policies versionable and testable, and separate security concerns from business
logic.

Trade-offs include added operational complexity, latency from policy evaluation,
the need for policy expertise, and the risk of a misconfigured policy affecting
the entire system. For most applications, a well-structured RBAC system is
sufficient. Externalized engines shine at scale or with complex, multi-tenant
policy requirements.
