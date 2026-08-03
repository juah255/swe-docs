# Vercel AI SDK

- TypeScript toolkit for building AI applications.
- Provider abstraction exposes a common interface across models.
- Streaming UI helpers (useChat) for chat interfaces.
- Tool calling and generateObject for structured output.
- Good for full-stack JavaScript apps.
- Framework-agnostic: works with React, Next.js, and other UI stacks.

See the [Frameworks overview](index.md) for selection criteria.

## Mid/Senior Interview Questions and Answers

### 1. What does the provider abstraction buy you, and when does it cost you?

**Answer:** It gives one interface across models and providers, so switching
models or running a multi-model setup is a config change rather than a rewrite,
and streaming and tool calling work consistently. It costs you when a
provider's unique capabilities have no common representation — features you
rely on may be lost or approximated. Treat the abstraction as a default, not a
promise: pin the provider and model in config, test against the real backend,
and be ready to fall back to the provider SDK for provider-specific behavior.

### 2. How does useChat manage streaming state, and when do you roll your own?

**Answer:** useChat manages messages, streaming tokens, pending state, and
abort on the client, which removes a lot of glue for chat UIs. It is a React
abstraction over the SDK's transport, so you trade some control over rendering
and state shape for speed. Roll your own when you need fine control: custom
message history persistence, non-standard streaming protocols, or interleaving
tool results and multi-turn flows that the hook's model does not fit. Keep the
wire format stable either way.

### 3. How do you get reliable structured output with generateObject?

**Answer:** generateObject asks the model for structured data and validates it
against a schema (Zod or similar), giving you typed, checked output instead of
unparsed text. Keep the schema focused, and treat validation as part of the
contract: on failure, retry with a clearer prompt or fail explicitly rather
than silently producing garbage. The typed result should be treated as data,
not text, so downstream code gets a validated object with no manual parsing.

### 4. When do you use the AI SDK instead of plain fetch in a full-stack JS app?

**Answer:** Use the SDK when you want streaming, provider abstraction, tool
calling, and structured output without reimplementing the transport and state
handling — these are exactly the pieces that are error-prone to hand-roll.
Reach for plain fetch when the call is a one-off, provider-agnostic HTTP
request, or when you need complete control over the payload and headers. The
SDK is a convenience layer over the provider API, so a simple POST to a chat
endpoint is often clearer as fetch.

### 5. How do you handle streaming errors and interruptions in a chat UI?

**Answer:** Streaming UIs must distinguish streaming failures from generation
failures. Handle network drops mid-stream, provider rate limits, and aborted
requests as distinct states, and surface retry, regenerate, and copy
affordances based on whether a partial message exists. Persist the
conversation so a refresh does not lose context, and treat the client and
server streaming implementations as a contract — a mismatch is the most common
source of broken chat UIs.
