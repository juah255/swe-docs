# Cost Optimization

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

See [Caching](caching.md) and [Latency Optimization](latency-optimization.md)
for related techniques.
