# Multi-Tenancy

A **multi-tenant** system serves many customers (**tenants**) from a single
application and infrastructure, while keeping each tenant's data and behavior
isolated. A **single-tenant** system runs a separate instance per customer.

Multi-tenancy is a scaling and cost decision — one codebase, one deployment,
many customers — but every choice trades off **isolation**, **cost**, and
**operational complexity**. The wrong split shows up as noisy neighbors, cross-
tenant data leaks, or migrations that never finish.

## Single-Tenant vs Multi-Tenant

| | Single-Tenant | Multi-Tenant |
| --- | --- | --- |
| Isolation | Strong (physical) | Logical, enforced in code |
| Cost per tenant | High | Low |
| Onboarding | Slow (provision infra) | Fast (row/schema insert) |
| Per-tenant customization | Easy | Constrained |
| Blast radius of a bug | One tenant | Potentially all tenants |
| Compliance story | Easier | Requires proof of isolation |
| Best for | Enterprise, regulated, few large tenants | SaaS, many small/medium tenants |

Most SaaS products start multi-tenant and add single-tenant tiers for
enterprise customers who need dedicated infrastructure.

## Isolation Models: Silo, Pool, Bridge

The AWS SaaS vocabulary names three isolation patterns:

- **Silo**: dedicated resources per tenant (own database, sometimes own
  compute). Strongest isolation, highest cost, slowest onboarding.
- **Pool**: fully shared resources, tenants separated only by application
  logic and a `tenant_id` column. Cheapest and most elastic, weakest
  isolation, noisy-neighbor risk.
- **Bridge**: mixed model — e.g. shared compute but per-tenant schemas or
  databases. A common compromise.

```text
Silo:    [ Tenant A DB ]  [ Tenant B DB ]  [ Tenant C DB ]
Pool:    [ Shared DB, rows keyed by tenant_id                ]
Bridge:  [ Shared app ] -> [ Schema A ] [ Schema B ] [ Schema C ]
```

A single product often uses different models per tier: pool for the free
plan, bridge for pro, silo for enterprise.

## Data Model Strategies

### Database per tenant

Each tenant gets its own database.

- **Strengths**: strong isolation, per-tenant backups and restores, easy
  compliance story, per-tenant tuning.
- **Weaknesses**: expensive at scale, migrations must run across every
  database, connection-pool pressure, harder cross-tenant analytics.
- **Fit**: enterprise or regulated tenants; small number of large tenants.

### Schema per tenant

One database, one schema per tenant, identical table structure.

- **Strengths**: cheaper than database-per-tenant, still reasonably isolated,
  easy to move a tenant to its own database later.
- **Weaknesses**: migrations still fan out across schemas; some databases
  handle thousands of schemas poorly; connection routing must select the
  right schema.
- **Fit**: medium tenant counts (tens to low thousands) with moderate
  isolation needs.

### Shared schema with `tenant_id`

All tenants share the same tables; every row carries a `tenant_id` column and
every query filters by it.

- **Strengths**: cheapest, easiest to operate, one migration path, simple
  cross-tenant analytics.
- **Weaknesses**: isolation is entirely a code concern — one missing
  `WHERE tenant_id = ?` leaks data across customers. Indexes and query plans
  must include `tenant_id` or one tenant can starve the rest.
- **Fit**: SaaS with many small tenants and no strict isolation requirement.

```text
orders(id, tenant_id, user_id, total, ...)   -- shared schema
                ^ every query MUST filter on this
```

### Comparison

| Strategy | Isolation | Cost | Migrations | Onboarding |
| --- | --- | --- | --- | --- |
| Database per tenant | Strong | High | Fan-out | Provisioning step |
| Schema per tenant | Medium | Medium | Fan-out | Create schema |
| Shared schema | Weak (logical) | Low | Single | Insert row |

## Tenant Identification and Routing

Every request needs to be tied to a tenant before it touches data. Common
approaches:

- **Subdomain**: `acme.app.com` — clean and cache-friendly; requires DNS
  wildcards and TLS handling.
- **Path prefix**: `app.com/t/acme` — simplest; ugly URLs for end users.
- **Custom domain**: `app.acme.com` mapped in tenant settings; needs
  automated certificate provisioning.
- **JWT / session claim**: `tenant_id` embedded in the token — authoritative
  and hardest to spoof; usually combined with one of the above for UX.
- **Header**: `X-Tenant-Id` — fine for internal APIs, unsafe on public ones
  unless verified against the auth token.

Rule: the tenant identifier used for **data access** must come from a
**server-verified source** (JWT claim or session), never from a request path
or header the client can forge.

## Enforcing Tenant Isolation in Code

The single most common multi-tenant bug is a query that forgets the tenant
filter. Defenses, from weakest to strongest:

1. **Discipline** — every query includes `tenant_id`. Fails eventually.
2. **Repository layer enforcement** — a base repository injects
   `tenant_id` from a request-scoped context so use-case code cannot forget.
3. **ORM query scopes / global filters** — the ORM automatically appends
   `tenant_id = ?` (e.g. Hibernate `@Filter`, Django managers, Prisma
   extensions).
4. **Row-Level Security (RLS)** in the database — Postgres RLS policies
   enforce `tenant_id = current_setting('app.tenant_id')` regardless of the
   query. Even a buggy application cannot read the wrong tenant.

Combine layers. RLS + repository-level tenant context is the belt-and-braces
setup for shared-schema systems that handle sensitive data.

## Noisy Neighbors and Fair Sharing

In pool models, one heavy tenant can degrade everyone. Mitigations:

- **Per-tenant rate limits** at the API gateway.
- **Per-tenant quotas** on expensive operations (background jobs, exports,
  storage).
- **Bulkheads**: separate worker pools, queues, or connection pools per
  tenant tier so a batch job can't drain the shared pool.
- **Priority queues**: enterprise tenants get their own lane.
- **Shard by tenant**: route the largest tenants to their own database or
  cluster while keeping the long tail pooled.

Measure per-tenant CPU, DB time, and queue depth — otherwise you learn about
noisy neighbors from support tickets.

## Migrations Across Tenants

Migrations become an operational problem as tenant count grows.

- **Shared schema**: one `ALTER TABLE` — but locks a table used by every
  tenant. Use online-schema-change tools or expand/contract migrations.
- **Schema or database per tenant**: iterate over all tenants. Must be
  resumable, parallelized, and observable — a failure at tenant 4,317 out
  of 5,000 should not restart from zero.
- **Versioning**: track schema version per tenant; the app must tolerate
  the mixed state during rollout.

Design new features so they can be **released dark**, enabled per-tenant
behind a flag, and rolled forward gradually.

## Per-Tenant Customization

Customers ask for tweaks. Handle them without forking the codebase:

- **Configuration**: feature flags and settings scoped by tenant.
- **Theming**: per-tenant branding via config, not code.
- **Extension points**: webhooks, custom fields, scripting sandboxes — not
  tenant-specific `if` branches sprinkled through the domain.

Rule of thumb: if a change requires a code branch keyed on `tenant_id`,
it's a design smell. Turn it into configuration or a supported extension.

## Cross-Cutting Concerns

- **Caching**: cache keys must include `tenant_id`. A missing prefix leaks
  data between tenants.
- **Logging and tracing**: attach `tenant_id` to every log line and span —
  essential when triaging incidents that affect only one customer.
- **Backups and restore**: a per-tenant restore is a common enterprise
  requirement. Shared-schema systems need a tenant-scoped export path;
  database-per-tenant makes this trivial.
- **Data export / deletion (GDPR)**: must be tenant-scoped and, for
  individual users, sub-tenant scoped.
- **Metrics**: emit per-tenant metrics (with cardinality controls) so
  usage-based billing and capacity planning are possible.

## Onboarding and Offboarding

- **Onboarding**: automated. In shared schema it's a row insert; in
  schema/database per tenant it's provisioning + migration + seed data.
- **Offboarding**: automated deletion of tenant data, including backups
  and analytics stores, within the promised retention window. Silent
  half-deletions are a compliance risk.

## Multi-Tenancy vs Multi-Region

They're often confused. Multi-tenancy is *how many customers share the
system*. Multi-region is *where the system runs*. A single-tenant product
can be multi-region; a multi-tenant product can be single-region.

Data residency requirements (e.g. EU customers must stay in the EU) usually
force at least a bridge model with region-pinned tenants.

## Common Mistakes

- Passing `tenant_id` from the client instead of the verified session.
- One missing `WHERE tenant_id = ?` in a single repository method.
- Cache keys without a tenant prefix.
- Assuming a shared-schema design will scale forever, then finding a single
  tenant is 40% of the table.
- Per-tenant `if` branches instead of configuration.
- No per-tenant observability, so noisy neighbors are invisible.
- Migrations that assume "a few" tenants and can't run against thousands.

## Mid/Senior Interview Questions and Answers

### 1. How do you choose between database-per-tenant, schema-per-tenant, and shared-schema?

**Answer:** Start from the isolation requirement and tenant profile. A small
number of large or regulated tenants points to database-per-tenant: strong
isolation, per-tenant backups, easier compliance, at the cost of expensive
provisioning and fan-out migrations. A large number of small tenants points to
shared schema: cheap, elastic, one migration path, at the cost of enforcing
isolation entirely in code.

Schema-per-tenant is the middle ground when you want stronger isolation than a
`tenant_id` column but can't justify a database each. Many mature SaaS products
end up **mixed**: pooled shared-schema for the long tail, dedicated databases
for enterprise tenants — because no single strategy fits every customer tier.

### 2. How do you prevent one tenant from reading another tenant's data in a shared-schema system?

**Answer:** Never trust the application layer alone. Establish a request-scoped
tenant context from a **server-verified** source — a JWT claim or session —
and inject it at the repository or ORM layer so use-case code cannot forget the
filter. Then defend in depth with database-level Row-Level Security policies
that enforce `tenant_id = current_setting('app.tenant_id')` regardless of the
query. A buggy application should still be unable to read the wrong tenant.

Tests should include a deliberately hostile case: authenticate as tenant A,
attempt to load tenant B's row by ID, and assert the response is 404, not
"forbidden" (which leaks existence). Cache keys, log correlation IDs, and any
denormalized store must also be tenant-scoped.

### 3. How do you handle the noisy-neighbor problem?

**Answer:** Measure first — per-tenant CPU, database time, queue depth, and
error rate. Without per-tenant metrics, you're guessing. Then apply layered
controls: per-tenant rate limits at the gateway, quotas on expensive
operations, and bulkheads that give heavy work its own worker pool or
connection pool so it can't drain the shared one.

When a specific tenant dominates cost or risk, **shard them out**: give the
top tenants their own database or cluster while keeping the long tail pooled.
This is why bridge models are so common — a pure pool is elegant on paper and
brittle in production once tenant sizes diverge.

### 4. How do you run schema migrations across thousands of tenants?

**Answer:** Treat migration as a distributed job, not a script. It must be
**resumable** (a failure at tenant 4,317 doesn't restart from zero),
**parallelized** with bounded concurrency, **observable** per tenant, and
**idempotent** so retries are safe. Track schema version per tenant and let
the application tolerate the mixed state during the rollout window.

Prefer **expand/contract** migrations — add the new column nullable, dual-
write, backfill, cut over reads, then drop the old column — so the code and
schema are never simultaneously broken. For shared-schema systems, use
online-schema-change tools to avoid table-wide locks that would stall every
tenant at once.

### 5. When is single-tenant the right choice?

**Answer:** When isolation is a **product requirement**, not an implementation
detail: regulated industries (health, finance, government), enterprise
customers with contractual isolation clauses, or workloads whose scale would
disrupt every other tenant in a pool. Single-tenant also simplifies per-
customer restores, region pinning, and downtime scheduling.

The cost is real: per-tenant infrastructure, per-tenant deploys, per-tenant
migrations, and slower onboarding. Most SaaS products land on a hybrid — a
multi-tenant product with an optional single-tenant tier for enterprise —
rather than committing to one model for every customer.
