# Caching

Cache deterministic results and reuse them across requests to cut cost and
latency without changing quality.

## What To Cache

- Embeddings for stable, well-known inputs.
- Tool outputs that do not change between calls.
- Stable answers for repeated or idempotent prompts.
- Provider-side prompt caching for long, fixed prompt prefixes.

## Cache Key Design

- Include the prompt version, model, and parameters in the key.
- Include a hash of the retrieved context the answer depends on.
- Include any user-scoped permissions that gate the result.

## TTL and Invalidation

- Set TTLs that match how often the underlying data changes.
- Invalidate on writes to the source data, not on a timer alone.
- Bump cache keys on prompt or model changes so old answers never mix with
  new behavior.

## Semantic Caching

- Hash exact inputs for the fastest hits.
- Use embedding similarity for near-duplicate queries, but set a high
  threshold so different questions do not share answers.

## When Caching Is Risky

- Fresh data that changes quickly.
- Personalized answers that vary per user.
- Results gated by permissions that can change.
- Non-deterministic outputs where a cached answer is wrong.

Caching is the highest-ROI cost lever; see [Cost
Optimization](cost-optimization.md) for how it fits the full strategy.
