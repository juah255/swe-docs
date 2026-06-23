# Tool Calling

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
