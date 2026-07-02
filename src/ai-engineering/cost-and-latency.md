# Cost and Latency

Cost and latency should be measured at the workflow level, not only at the model
request level.

## Optimization Techniques

- Use smaller models for simple tasks.
- Route requests by task difficulty.
- Cache stable answers and embeddings.
- Shorten prompts and retrieved context.
- Stream responses for better perceived latency.
- Batch offline jobs.
- Use asynchronous processing for non-interactive work.
- Set timeouts and fallback behavior.
- Measure cost per successful workflow, not only cost per token.

## Model Routing

Route by task type:

- Small model for classification, extraction, and rewriting.
- Stronger model for complex reasoning or high-value workflows.
- Fallback model when the primary provider is unavailable.
- Human review when no model meets the risk threshold.

## Practical Rule

Do not optimize cost before the evaluation baseline is clear. A cheaper model
that fails often can be more expensive at the product level.

## Mid/Senior Interview Questions and Answers

### 1. How do you measure per-request cost end-to-end?

**Answer:** Sum token cost across every model call in the request — including
retries, tool-invoked follow-up calls, and any embedding calls — plus the
infrastructure cost per request (vector DB reads, cache lookups, external
API calls). Attribute the total to a request ID and a feature.

Then divide by successful outcomes, not by requests. Cost per successful
task is what actually matters. A workflow that costs $0.02 per call but
fails 30% of the time is often more expensive than a $0.05 call that
succeeds — you pay for retries, escalations, and human review.

### 2. How do you cut cost without cutting quality?

**Answer:** In order of ROI: cache anything deterministic (embeddings, tool
outputs, stable answers) — this is free money. Route by difficulty so a
haiku-class model handles classification and extraction while the strong
model only handles the hard tail. Trim prompts and retrieved context to
what the model actually needs, measured against your eval set.

Only after those, consider fine-tuning or distillation. Every one of these
needs an eval to prove quality did not regress. Cost wins without eval
coverage are usually quality losses in disguise that ship silently.

### 3. When does TTFT matter more than total latency, and when is it the reverse?

**Answer:** TTFT matters for interactive chat, code completion, and any UI
where the user sees streaming text — perceived responsiveness beats total
duration. Stream tokens even if total latency is slightly worse.

Total latency matters for backend workflows, agents doing multi-step
reasoning, and batch jobs where nobody is watching. For a nightly summarizer
or an offline enrichment job, streaming buys nothing. Optimize the metric
the user actually experiences, and do not confuse the two.

### 4. When does batching help, and when does it just add complexity?

**Answer:** Batching helps for offline or async workloads where you can
tolerate delay: nightly embeddings, bulk classification, backfills. Provider
batch APIs give real discounts (often 50%) at the cost of hours of latency.
Take it when you can.

It hurts for interactive requests — queueing to build a batch adds latency
users notice, and any single slow item stalls the whole batch. For live
traffic, prefer parallelism and streaming over batching. Do not batch just
because it sounds like an optimization.

### 5. When is the naive one-model-call approach actually fine?

**Answer:** When traffic is low, the workflow is simple, and the model cost
is a rounding error against engineer time. Premature routing, caching, and
distillation infrastructure costs more to build and maintain than the
provider bill it saves.

Ship the direct call. Instrument cost and latency. Add complexity only when
a metric — cost per successful task, p95 latency, or provider rate limits —
forces the change. Most LLM features never need more than one model, one
prompt, and a cache.
