# Chat Completions

The chat completions API takes a list of messages and returns a model reply.
It is the standard interface for conversational and instruction-following
models.

## Message Roles

- **system**: a high-priority message that sets role, rules, and behavior. It
  carries the strongest instructions and should not be overridable by user
  input.
- **user**: the immediate task or question from the user, including any input
  data the model needs.
- **assistant**: the model's prior replies. Include them so the model can build
  on earlier turns in a conversation.
- **tool**: results returned by tool calls, treated as data rather than
  instructions.

## Conversation History

- Send prior turns as a message list so the model sees the full conversation.
- History costs tokens on every request, so truncate or summarize old turns for
  long conversations.
- Keep retrieved context separate from user input so it cannot be mistaken for
  instructions.

## Parameters

- **max_tokens**: caps the length of the generated response.
- **stop sequences**: token or string sequences that end generation early.
- **temperature**: controls sampling randomness; lower values are more
  deterministic.

See [AI APIs](ai-apis.md) for request design, retries, and rate limits, and
[Structured Outputs](../foundations/structured-outputs.md) for typed response
contracts.
