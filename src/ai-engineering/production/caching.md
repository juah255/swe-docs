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

## Mid/Senior Interview Questions and Answers

### 1. What belongs in a cache key, and what breaks when you get it wrong?

**Answer:** The key must cover everything that changes the answer: the prompt
(or its version), the model and parameters, and a hash of the retrieved
context the answer depends on. Add user-scoped permissions that gate the
result so users never share entries across access levels.

When the prompt, model, or data source changes, bump the key. A key that
omits any of these silently serves wrong answers on every "hit," which is
worse than no cache at all because it looks correct.

### 2. When should you use semantic caching instead of exact-match hashing?

**Answer:** Exact hashing is free, deterministic, and safe, so keep it as the
default fast path for repeated prompts. Semantic caching adds embedding
similarity so paraphrased questions hit too, but it risks false hits where
different questions share one answer.

Use semantic caching only when paraphrases dominate the miss rate, set a
high similarity threshold, and validate hits against your eval set before
trusting them. Ship exact first; add semantic only when it earns its risk.

### 3. How do you pick a TTL and handle invalidation?

**Answer:** TTL is a backstop, not the primary mechanism. Set it to match how
often the underlying data changes, but invalidate on writes to the source
data so stale answers disappear immediately instead of lingering until
expiry.

Every cache key should be derivable from its inputs. Then invalidation is
just deleting or bumping the affected keys when the source row, prompt, or
model changes. Timer-only eviction is the classic bug: the answer is stale
but the cache reports it as fresh.

### 4. Why cache embeddings and tool outputs, and what can go wrong?

**Answer:** Embeddings are deterministic for a given input and model version,
so caching them avoids recomputation and repeated embedding calls. Tool
outputs are worth caching when they are stable — a query that returns the
same rows on every call should be computed once.

The failure mode is caching things that are not actually stable. Only cache
tool results you can key and invalidate cleanly, and never cache outputs
that embed user-specific data without that user in the key.

### 5. When is caching risky enough that you should not do it?

**Answer:** Caching is risky when the answer changes fast (live prices,
feeds), varies per user (personalization), or depends on permissions that
can change mid-session. In all three cases a cache hit is a wrong answer
that still looks authoritative.

Also avoid non-deterministic outputs — temperature above zero or
time-dependent tool results. When correctness beats cost, cap the TTL short,
scope keys by user and permission, or skip the cache for that request.
