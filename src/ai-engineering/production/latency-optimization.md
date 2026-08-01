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

See [Cost Optimization](cost-optimization.md) for the related trade-offs.
