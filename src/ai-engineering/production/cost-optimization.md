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

### 3. How do you route requests by difficulty across models?

**Answer:** Classify each request — by intent, input length, or a cheap probe
— and send the easy tail to a small model while reserving the strong model
for hard reasoning. The router must be measured: a misroute that sends hard
work to the weak model fails, and the failures cost more than always using
the strong model.

Route by task type, not by guess. Classification, extraction, and rewriting
rarely need a frontier model; complex reasoning and high-value workflows do.
Keep a fallback and a human-review path when the router is unsure.

### 4. How do you trim prompts and context without losing quality?

**Answer:** Trim everything the model does not need, and prove it with your
eval set before and after. Boilerplate instructions, duplicate retrieved
chunks, and verbose tool output all inflate the token bill without improving
the answer.

Use retrieval to feed only the most relevant context, cap chunk counts, and
summarize or compress tool results. Measure cost per successful workflow,
because a prompt so short it loses needed information is more expensive at
the product level.

### 5. When does fine-tuning pay off versus prompt-side cost controls?

**Answer:** Only after caching, routing, and trimming are exhausted — those
are cheaper and faster to ship. Fine-tuning pays off when a task repeats at
scale with a stable format, or when a small tuned model matches a large
prompt-engineered model at a fraction of the cost.

Provider batch APIs are the other lever, cutting offline job costs
substantially. Both need an eval gate: if the tuned, routed, or batched
output regresses quality, the savings is a hidden product loss.

See [Caching](caching.md) and [Latency Optimization](latency-optimization.md)
for related techniques.
