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

## Mid/Senior Interview Questions and Answers

### 1. How do you keep message roles disciplined in a chat application?

**Answer:** The system message owns role, rules, and output contract and must
be the single place instructions live. User messages carry the task and its
data, assistant messages reproduce prior model replies, and tool messages hold
tool results as data. Never concatenate user content into the system prompt,
and delimit retrieved context so it cannot be mistaken for instructions.

### 2. How do you handle long conversations without blowing the context window?

**Answer:** Maintain a sliding window of recent turns plus a rolling summary
of the older conversation, and budget tokens up front so system, history, and
retrieval fit with room for the reply. Prefer summarizing over dropping context
abruptly, and cap history by tokens rather than by turn count, because a single
long user turn can eat the entire budget.

### 3. What do max_tokens and stop sequences actually control, and how do they differ?

**Answer:** max_tokens caps how many output tokens the model may generate,
protecting latency, cost, and the shared input/output budget — but it can
truncate a reply mid-thought. Stop sequences end generation early at a
specific string, which is ideal for structured formats like JSON or
newline-delimited lists. Use both: a hard token ceiling plus semantic stop
markers.

### 4. How do you handle multi-turn conversations when users edit or restate prior turns?

**Answer:** Reconstruct the conversation server-side rather than replaying a
naive message list when users edit earlier turns, send follow-ups with
ambiguous references, or undo an action. Resolve references against the current
state, trim or rewrite contradictory history, and treat the model as stateless
so each request is an accurate snapshot of the conversation.

### 5. When do you pick chat completions over other model APIs?

**Answer:** Chat completions is the right default for conversational and
instruction-following work because roles, history, and tool support are
first-class. Use embeddings for similarity, dedicated transcription or speech
APIs for audio, and image APIs for generation. Prefer chat over raw completion
endpoints unless you need token-level control that the message structure
actually fights against.
