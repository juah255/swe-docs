# AI APIs

Model integration is the application code around model calls: request building,
streaming, retries, parsing, failure handling, and fallbacks.

## Request Design

- Keep input and output contracts explicit.
- Separate system instructions, user content, retrieved context, and tool
  results.
- Use request IDs so logs and traces can connect model calls to user workflows.
- Set token limits, timeouts, and retry budgets.
- Avoid sending secrets, credentials, or unnecessary personal data.

## Retries and Fallbacks

- Retry transient network or rate-limit failures with bounded backoff.
- Do not retry unsafe side-effecting tool calls without idempotency.
- Use fallback models or fallback workflows when quality requirements allow it.
- Return a clear recoverable error when the system cannot meet the contract.

## Production Concerns

- Timeouts should be shorter than user-facing request limits.
- Model errors should not crash the entire workflow.
- Logs should include prompt version, model, latency, token usage, and validation
  status.
- Cost should be measured per successful task, not only per request.

## Mid/Senior Interview Questions and Answers

### 1. How do you design an LLM client for reliability?

**Answer:** Wrap the provider SDK in a small internal client that owns
timeouts, bounded retries with jitter, structured errors, request IDs, and
metrics. Timeouts must be shorter than the user-facing request budget so a
stuck call cannot hold a worker forever. Retries only on transient errors —
network, 429, 5xx — never on validation failures or content errors.

Add circuit breaking or fallback routing when the primary provider degrades,
and make sure every call emits latency, token usage, and status so you can
see failure modes before users do. The client is the seam where reliability
lives; do not spread this logic across call sites.

### 2. Is a provider abstraction worth building?

**Answer:** A thin abstraction — one interface, a few concrete adapters — is
usually worth it for testability, fallback routing, and swapping models per
task. A thick abstraction that tries to normalize every provider's features
almost always leaks and becomes a maintenance burden.

Rule of thumb: abstract what you actually use across providers today
(messages, streaming, tool calls, structured output) and expose the raw
client for anything provider-specific. Do not build a framework speculating
about a future migration you may never do.

### 3. How do you handle rate limits and quotas?

**Answer:** Read the provider's rate-limit headers, back off with jitter, and
queue rather than retry-hammer. For predictable load, request quota increases
before launch and monitor headroom. For spiky load, add a token bucket in
front of the client so bursts do not exhaust the account and starve other
callers.

Segment quota by workload: interactive traffic must not be blocked by a
batch job. When you approach limits, degrade gracefully — smaller model,
cached response, or a clear "try again shortly" — instead of failing the
user request outright.

### 4. What does secrets and config discipline look like for LLM apps?

**Answer:** API keys in a secret manager, never in code or images, rotated
on a schedule and on staff changes. Per-environment keys so a staging bug
cannot spend production budget. Model name, temperature, timeouts, and
prompt version in config so changes are auditable and rollbackable without a
redeploy.

Log the config values that affect behavior — model, prompt version,
temperature — on every request. Never log the prompt or response payload
without a redaction pass; user data and PII end up in traces faster than
teams expect.

### 5. How do you design idempotent retries for side-effecting calls?

**Answer:** Generate a client-supplied idempotency key per logical operation
and have the provider or your own store deduplicate on it, so a retry after a
timeout cannot double-charge or double-send. Retry side-effecting calls only
when the operation is known idempotent, and otherwise return a clear
recoverable error and let the workflow reconcile. Never blindly retry a tool
call that writes, emails, or pays.
