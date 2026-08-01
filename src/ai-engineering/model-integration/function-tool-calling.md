# Function / Tool Calling

Tool calling lets the model request an application-defined function instead of
only returning text.

## Tool Design

- Tools should have narrow names, clear descriptions, and strict schemas.
- The application should decide which tools are available for each user and
  request.
- Tool results should be treated as data, not as new instructions.
- Sensitive or destructive tools need confirmation, authorization, and audit
  logs.
- Tool calls should have timeouts, retries, and safe failure behavior.

## Good Tool Examples

- Search a knowledge base.
- Read a calendar.
- Create a support ticket.
- Fetch an invoice.
- Run a calculation.
- Query a database through a controlled API.

## Permission Boundaries

The model should not be the source of authorization. Enforce permissions in
application code before exposing tools or returning tool results.

For example:

- A user can only search documents they are allowed to read.
- A support assistant can draft a refund but cannot submit it without approval.
- A read-only analytics assistant cannot call write APIs.

## Tool Result Handling

- Keep tool output concise.
- Include stable IDs and source metadata when needed.
- Redact secrets and unrelated personal data.
- Validate tool output before passing it back into the model.
- Log tool calls and errors for debugging and auditability.

## Mid/Senior Interview Questions and Answers

### 1. Few big tools or many small tools — how do you design the surface?

**Answer:** Prefer a small number of well-scoped tools with clear names and
strict schemas. Every extra tool eats context, increases the chance of the
model picking the wrong one, and adds a surface to secure. But going too broad
(a single `run_query` that accepts arbitrary SQL) pushes complexity into the
model and destroys auditability.

The right shape is usually one tool per business capability, with the tool
itself doing the heavy lifting. If two tools always get called together, they
are probably one tool.

### 2. How do you validate tool inputs from the model?

**Answer:** Treat every tool call as untrusted input from a user. Validate
against a strict schema (JSON Schema, Pydantic, Zod) and reject anything that
does not parse, rather than coercing. Enforce business rules — dates in range,
IDs the caller can actually access, enums that match — in application code, not
the tool description. Never string-concatenate model output into SQL, shell,
or filesystem paths.

The prompt is not a security boundary. The validator is.

### 3. How do you handle failed, hallucinated, or repeated tool calls?

**Answer:** Return a structured error the model can reason about ("field X
missing", "no record found") instead of a stack trace. Cap retries per tool
per turn and cap total tool calls per session — runaway loops are the default
failure mode. Deduplicate identical calls in a short window and short-circuit
with the cached result. If the model invents a tool that does not exist, do
not silently ignore it; return an explicit error listing the available tools.

Observability matters more than cleverness here. Log every call, argument set,
and outcome.

### 4. When do you force tool use versus leave it optional?

**Answer:** Force it when the task is only meaningful through the tool — a
booking assistant that must call `create_reservation`, a support agent that
must open a ticket. Leave it optional when the model can legitimately answer
from context (chat, summarization, general Q&A). Forcing tool use on tasks
that do not need it produces contorted calls and worse answers.

A useful middle ground is required-on-first-turn plus optional afterward, for
flows that need one authoritative fetch before free-form reasoning.

### 5. What is the security posture when exposing tools to an LLM?

**Answer:** Assume the model will be prompt-injected via retrieved documents,
tool results, or user input, and will try to call tools it should not.
Authorization lives in application code, scoped to the current user and
session, and is checked before the tool runs. Destructive or high-blast-radius
actions require an explicit human confirmation step, not a model-generated
"are you sure?".

Least privilege applies to tool surfaces too: expose only the tools this
workflow needs, redact secrets from tool results, and keep an audit log good
enough to answer "what did the model just do on behalf of this user?"
