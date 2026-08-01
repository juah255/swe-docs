# Deployment

Production AI features should have the same engineering discipline as other
backend systems.

## Production Readiness

- Clear input and output contracts.
- Versioned prompts and configuration.
- Automated tests and evaluation gates.
- Timeouts, retries, fallbacks, and circuit breakers.
- Rollback plan for prompt, model, retrieval, or tool changes.
- Monitoring for quality, latency, cost, and failures.
- Data retention and privacy controls.
- Documentation for operators and support teams.

## Release Strategy

Deploy risky changes gradually with:

- Feature flags.
- Canary releases.
- Limited user rollouts.
- Shadow evaluation.
- A/B testing when user impact can be measured safely.

## Rollback Planning

Rollback should cover:

- Prompt versions.
- Model versions.
- Retrieval indexes.
- Tool schemas.
- Safety rules.
- Routing configuration.

AI incidents often come from the system around the model, not only from the
model itself.

## Mid/Senior Interview Questions and Answers

### 1. How do you roll out a prompt or model change safely in production?

**Answer:** Treat every prompt, model, or retrieval change as a code change with
its own version, evaluation gate, and rollout stage. Start with offline evals on
a curated dataset, then run shadow traffic where the new version scores real
requests without affecting the response. Move to a small canary (1–5% of
traffic) with quality, latency, and cost SLOs wired into automatic rollback.
Only run an A/B test once basic quality is proven, because A/B is expensive and
noisy for open-ended outputs.

The common mistake is skipping shadow mode and going straight to canary. Shadow
catches regressions that offline evals miss because the input distribution in
production rarely matches your golden set.

### 2. What does a real rollback strategy look like for an LLM app?

**Answer:** A single "redeploy the old container" rollback is not enough because
the failure surface is wider than the code. You need to independently roll back
the prompt version, model version, retrieval index, tool schemas, safety rules,
and routing config, so version each of these behind a flag or config key that
can be flipped without a redeploy. Keep the last known-good pinned and reachable
in under a minute.

Also plan for partial rollback: it is common to keep a new model but revert the
prompt, or keep the prompt but pin retrieval to yesterday's index while a bad
embedding rebuild is investigated.

### 3. When would you pick blue-green over progressive delivery for an AI feature?

**Answer:** Blue-green is fine for infrastructure changes (SDK upgrades, gateway
swaps, index rebuilds) where behavior should be identical and you mainly want a
fast cutover with a fast revert. For anything that changes model output —
prompt edits, model swaps, new tools, retrieval tuning — progressive delivery
(shadow → canary → gradual ramp) is almost always the right call because output
quality is a distribution, not a boolean, and you need traffic to observe it.

The failure mode of blue-green for AI features is that quality regressions only
show up under real traffic mix, and by then you have already cut 100% over.

### 4. How do you handle provider outages and degraded modes?

**Answer:** Assume the primary provider will fail and design a degraded mode
that is still useful. Concretely: timeouts and retries with jittered backoff,
circuit breakers per provider and per model, a fallback model (either a
secondary provider or a smaller model from the same provider), cached responses
for idempotent prompts, and a "safe minimum" response for endpoints that cannot
gracefully degrade.

Watch the second-order effects: cross-region failover multiplies your token
spend, and a fallback model may violate the assumptions the prompt was tuned
against, so evaluate the fallback path as its own release, not as a free
safety net.

### 5. How do you keep dev, staging, and production in parity for LLM apps?

**Answer:** True parity is harder than in classical services because behavior
depends on the model, provider region, prompt, retrieval index, tool
definitions, and often per-tenant config. The pragmatic approach is to pin the
exact model version (not aliases like `latest`), share the same prompt and tool
schema registry across environments, and use production-like retrieval indexes
in staging — even a downsampled snapshot beats synthetic data.

Non-parity to accept explicitly: staging usually points at a lower-tier rate
limit, and PII is scrubbed or synthesized. Document those deltas so incidents
that reproduce only in prod are not a surprise.
