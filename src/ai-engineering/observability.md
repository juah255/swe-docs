# Observability

AI observability should explain both model behavior and system behavior.

## What To Track

- Prompt version.
- Model name and parameters.
- Input and output token counts.
- Latency by step.
- Cost per request and cost per successful task.
- Retrieved documents and retrieval scores.
- Tool calls and tool errors.
- Validation failures.
- User feedback.
- Safety filter results.

## Tracing

Trace the full workflow, not only the model request.

Useful spans:

- Request validation.
- Retrieval.
- Reranking.
- Prompt assembly.
- Model call.
- Tool call.
- Output validation.
- Persistence or external action.

## Logging Sensitive Data

Logs should avoid storing sensitive user data unless retention, access control,
and redaction are handled properly.

At minimum:

- Redact secrets.
- Limit access to prompt and response logs.
- Define retention periods.
- Avoid logging full documents unless needed for debugging.
- Keep audit logs for external actions.
