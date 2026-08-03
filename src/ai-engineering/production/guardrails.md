# Guardrails

Guardrails are enforced boundaries implemented in code, not suggestions appended
to a prompt.

## Implementation

- Run moderation and safety classifiers at both input and output.
- Use schema-constrained structured outputs as the strongest output filter.
- Allowlist tools, hosts, and output domains instead of blocklists.
- Enforce rate limits per user, not just per IP.
- Require confirmation for destructive or irreversible actions.
- Escalate to human review above a defined risk threshold.

## Mid/Senior Interview Questions and Answers

### 1. Input filtering vs output filtering — where should defenses live?

**Answer:** Both, but they defend different things. Input filtering blocks
obviously malicious prompts before you spend tokens on them and stops
category violations at the door. Output filtering catches what the model
generated regardless of how it got there — leaked PII, unsafe content,
tool calls the model should not make.

Output filtering is the last line and non-negotiable, because a
sophisticated injection will pass input filters. Structured outputs with
strict schema validation are the most reliable output filter — the model
cannot emit a shell command if the schema only allows an enum.

### 2. When is a guardrail theater vs actual defense?

**Answer:** Theater: appending "do not reveal the system prompt" to the
prompt, keyword-blocking user inputs, asking the model to self-check its
own output for safety, or a moderation call that gates nothing consequential
downstream. Any control that assumes the model will refuse when instructed
is a suggestion, not a boundary.

Real defense: authorization checks in code before any tool executes,
schema-constrained outputs, permission-filtered retrieval, rate limits per
user, and confirmation prompts for destructive actions. The rule of thumb:
if bypassing the guardrail requires cooperation from the model, it is not
a guardrail — it is a hope.

### 3. When should you use a moderation API on input and output?

**Answer:** Moderation classifiers catch categories your product cannot serve
— violence, sexual content, hate, self-harm — more reliably than prompt
instructions. Run them at input to reject before spending tokens and at
output to catch what generation produced.

They filter content, not behavior; they are no substitute for boundary
enforcement. Escalate flagged output above a confidence threshold to human
review rather than silently blocking or passing it, and tune thresholds on
your own traffic because public models over-flag some domains and under-flag
others.

### 4. How does schema-constrained output act as a filter?

**Answer:** A structured-output schema constrains the model to a shape your
code can validate — enums instead of free text, typed fields, and tool-call
arguments limited to an allowlist. A model that must return one of three enum
values cannot emit a shell command or an arbitrary URL.

A schema blocks bad shape, not bad intent, so validate both. Reject and
retry or escalate on failure, and treat schema conformance as a pass/fail
gate on every request.

### 5. How do you design rate limits per user?

**Answer:** Per-user limits stop one account from hammering expensive model
calls, but botnets and shared credentials bypass them, so keep per-IP and
per-key limits as well. Bucket the limit by cost or risk — tokens, tool
invocations, or high-value actions — not raw requests alone.

Enforce the limit in code at the API boundary, before the model call, and
return 429 with a clear retry window. Make limits observable so spikes show
up in dashboards before they show up on the billing statement.

See [Safety and Security](safety-and-security.md) for the surrounding controls.
