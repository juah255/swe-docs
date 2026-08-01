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

### 4. Input filtering vs output filtering — where should defenses live?

**Answer:** Both, but they defend different things. Input filtering blocks
obviously malicious prompts before you spend tokens on them and stops
category violations at the door. Output filtering catches what the model
generated regardless of how it got there — leaked PII, unsafe content,
tool calls the model should not make.

Output filtering is the last line and non-negotiable, because a
sophisticated injection will pass input filters. Structured outputs with
strict schema validation are the most reliable output filter — the model
cannot emit a shell command if the schema only allows an enum.

### 5. When is a guardrail theater vs actual defense?

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

See [Safety and Security](safety-and-security.md) for the surrounding controls.
