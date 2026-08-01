# GraphQL Security

GraphQL exposes a single endpoint through which clients query exactly the
fields they want. This makes abuse easy: one query can fan out across nested
resolvers and pull huge amounts of data, so GraphQL security is mostly about
limiting how much work a single request can trigger.

## Query Depth and Complexity

- Enforce a maximum query depth to stop deeply nested queries.
- Measure query complexity (weighted fields and joins) and reject queries over
  a budget.
- Cap the number of items returned per field and across the response.

## Query Allowlists

- In production, allow only queries that were pre-registered by trusted clients
  instead of accepting arbitrary operations.
- Where allowlists are impractical, use strict validation and cost limits as a
  substitute.

## Rate Limiting

- Rate limit per user, per API key, and per operation type, not just per IP.
- Consider cost-aware rate limits that weigh a request by its computed
  complexity. See [Rate Limiting](rate-limiting.md).

## Authorization

- Enforce authorization per resolver and per field, not only at the root query.
- Never assume that a field not requested in an introspection query is safe;
  resolve access checks per field.
- Return minimal error detail so attackers cannot use authorization failures to
  map the schema.

## Production Hardening

- Disable introspection in production unless an explicit workflow needs it;
  introspection is a reconnaissance goldmine.
- Watch for batch attacks: many queries in one request multiply cost, so bound
  the number of operations per request.
- Validate every argument as you would in any API. See
  [Secure API Design](secure-api-design.md).
