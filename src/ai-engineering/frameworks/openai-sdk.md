# OpenAI SDK

The official OpenAI Python and TypeScript SDK is the direct integration point
for OpenAI models.

- Chat completions, streaming, tool calling, and structured outputs.
- Set timeouts and retries on requests.
- Handle API errors: authentication failures, rate limits, and server errors.
- Keep the model and prompt version in config, not hardcoded in code.

See the [Frameworks overview](index.md) for selection criteria.

## Mid/Senior Interview Questions and Answers

### 1. How do you handle errors, timeouts, and retries in the OpenAI SDK?

**Answer:** Classify errors before retrying: 401s and 403s are configuration
bugs and must never be retried, 429s and 5xx are transient and worth bounded,
jittered backoff with respect for Retry-After. Set explicit timeouts per
request rather than relying on defaults, especially for streaming, and make the
retry policy part of the shared client configuration so every call inherits it.
Log the model, error class, and attempt count for each failure.

### 2. How do you implement streaming without losing reliability?

**Answer:** Stream tokens to the client while buffering the complete response
for logging, error handling, and evaluation — the UI needs incremental tokens
but the backend needs the full message. Handle mid-stream errors distinctly:
partial responses, disconnects, and rate limits interrupt the stream, so the
UI must surface a retryable state and the client must be able to resume or
recover cleanly. Timeouts apply per-chunk too, not just to the first byte.

### 3. How do you make tool calling reliable in production?

**Answer:** Treat tool calls as a loop with hard limits: the model may emit
multiple tool calls or malformed arguments, so parse and validate JSON, run
tools with their own error handling, and cap the number of turns to prevent
runaway cost. The model can request a tool that no longer exists or with bad
parameters — validate against a schema and return a structured error message
for the model to recover from. Log every tool call and result for debugging
and audit.

### 4. How do you get structured outputs without fragile parsing?

**Answer:** Use the SDK's structured output support — response_format with a
JSON schema — so the model returns schema-validated JSON instead of free text
you parse with regex. Keep schemas small and strict; large schemas increase the
chance of validation failures, so validate the response yourself as a backstop
and retry on failure. Version the schema, since a deployed model output must
match the consumer's expectations, and pin both the schema and model version
in config.

### 5. How do you keep SDK and model versions pinned in production?

**Answer:** Pin the SDK to an exact version and promote it like any dependency —
read the changelog, run integration tests against the new version, and roll out
through normal staging. Keep the model name and parameters (temperature, max
tokens, schema) in config, not hardcoded, so changes are reviewable and
rollback-able. The model and the SDK evolve independently, so the pinned pair
is what you test and what you can reproduce an incident against.
