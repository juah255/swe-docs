# Model Integration

Model integration is the application code around model calls: request building,
streaming, retries, parsing, failure handling, and fallbacks.

## Request Design

- Keep input and output contracts explicit.
- Separate system instructions, user content, retrieved context, and tool
  results.
- Use request IDs so logs and traces can connect model calls to user workflows.
- Set token limits, timeouts, and retry budgets.
- Avoid sending secrets, credentials, or unnecessary personal data.

## Streaming

Streaming improves perceived latency for interactive workflows.

Use streaming when:

- Users benefit from seeing partial output.
- The response may be long.
- The interface can handle partial text safely.

Avoid streaming when:

- The response must be validated before display.
- The result drives a business action.
- Partial output could expose sensitive or unsafe content.

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
