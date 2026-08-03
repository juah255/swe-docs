# Latency Optimization

Optimize the metric the user actually experiences, whether that is time to
first token or total workflow duration.

## Optimization Techniques

- Stream responses for better perceived latency.
- Parallelize independent model and tool calls so they run concurrently.
- Trim prompt and retrieved context to reduce tokens per request.
- Route to smaller, faster models when latency matters more than capability.
- Prefetch and stream to mask latency where the user can start reading early.

## Mid/Senior Interview Questions and Answers

### 1. When does TTFT matter more than total latency, and when is it the reverse?

**Answer:** TTFT matters for interactive chat, code completion, and any UI
where the user sees streaming text — perceived responsiveness beats total
duration. Stream tokens even if total latency is slightly worse.

Total latency matters for backend workflows, agents doing multi-step
reasoning, and batch jobs where nobody is watching. For a nightly summarizer
or an offline enrichment job, streaming buys nothing. Optimize the metric
the user actually experiences, and do not confuse the two.

### 2. When does batching help, and when does it just add complexity?

**Answer:** Batching helps for offline or async workloads where you can
tolerate delay: nightly embeddings, bulk classification, backfills. Provider
batch APIs give real discounts (often 50%) at the cost of hours of latency.
Take it when you can.

It hurts for interactive requests — queueing to build a batch adds latency
users notice, and any single slow item stalls the whole batch. For live
traffic, prefer parallelism and streaming over batching. Do not batch just
because it sounds like an optimization.

### 3. How do you parallelize independent model and tool calls?

**Answer:** Model the workflow as a dependency graph and fan out calls that
share no dependencies — retrieval, classification, and summarization can run
concurrently instead of sequentially. The win is the difference between the
sum of latencies and the longest path.

Watch the failure modes: parallel calls multiply token usage and hit rate
limits, so set per-request budgets. Decide whether a failed branch fails the
workflow or degrades it. Measure the end-to-end metric, not the per-call
time.

### 4. When does model routing actually reduce latency?

**Answer:** Route to a smaller or faster model when the task is easy and the
strong model adds no quality. A classification call on a small model returns
in hundreds of milliseconds while a frontier model takes seconds, and
sending non-critical work to a cheaper provider keeps the primary path
responsive.

But routing helps only when the latency difference is real for that
workload. For hard reasoning, a small model may retry and loop, costing more
time than using the strong model once.

### 5. How do you set timeouts and user-facing latency budgets?

**Answer:** Derive the budget from the product, not the model: how long will
the user wait, and are you bound by time to first token or total time? Then
allocate that budget across calls, streaming, and parallelism.

Every call needs a timeout and a fallback, because tail latency will exceed
your p95. Caching and prefetching hide work before it is needed, and
streaming the first token can mask a slow full response. Track timeouts as a
metric, not an error log, and tighten budgets when they spike.

See [Cost Optimization](cost-optimization.md) for the related trade-offs.
