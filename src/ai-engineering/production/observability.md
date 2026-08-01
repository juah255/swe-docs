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

## Mid/Senior Interview Questions and Answers

### 1. What do you log for an LLM app, and what do you deliberately not log?

**Answer:** Log the metadata you need to debug and cost-attribute: prompt
version, model, parameters, token counts, latency per step, retrieval doc
IDs and scores, tool calls, validation failures, and a stable request ID
that ties spans together.

Do not log full prompts and outputs by default. They contain PII, secrets
users paste in, and copyrighted content, and they land in log stores with
weaker access control than your primary database. If you must sample them,
redact aggressively, store separately with tight retention and access, and
document the legal basis for keeping them.

### 2. How do you trace a multi-step LLM workflow so it's actually debuggable?

**Answer:** Model it as spans: request validation, retrieval, rerank, prompt
assembly, model call, output validation, tool call, persistence. Each span
records inputs, outputs, timing, and errors. Tie them under one trace ID so
you can replay the full request path.

The point is that when a user reports "the assistant gave me a wrong answer
at 3:14," you can find that trace and see which document was retrieved,
which prompt was sent, and what the model returned — without guessing.
Without this, post-hoc debugging turns into speculation.

### 3. How do you alert on quality regressions, not just uptime?

**Answer:** Uptime alerts on 5xx and latency, which say nothing about whether
answers are correct. Layer quality signals on top: validation failure rate,
tool error rate, retrieval-hit rate, groundedness score on a sampled slice,
user thumbs-down rate, and completion rate for multi-step flows.

Alert on rate of change, not absolute value, because the baseline drifts.
Route quality alerts to the product owner, not just on-call — a rise in
thumbs-down is not a page-at-3am incident but it does need triage before
the metric goes viral.

### 4. A user says the assistant gave a bad answer last Tuesday. How do you debug it?

**Answer:** Pull the trace by user ID and timestamp. Read the exact prompt
sent, the retrieved documents, the raw model output, and any tool calls.
Check the prompt version and model version that were live at the time.

Then reproduce it with the same inputs against the current system. If it
still fails, add it to the eval set. If it now passes, note what changed
between then and now. This whole loop only works if you captured the trace
in the first place — which is why observability decisions made at build
time determine what you can debug at incident time.

### 5. How do you balance debuggability with the privacy of not logging prompts?

**Answer:** Segment by risk. For low-sensitivity endpoints (public docs
Q&A), sample prompts and outputs with short retention. For high-sensitivity
endpoints (health, finance, HR), log only structural metadata — no prompt
text, no output text — and add a customer-visible flag that lets them opt
into diagnostic logging when they file a bug.

Redact known secret patterns and PII at capture time, not in a batch job
later. Keep the tool-call audit log full and immutable regardless — you
need it for security review, and it usually contains less user text than
the prompt itself.
