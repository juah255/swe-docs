# Streaming Responses

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

## How Streaming Works

- Streaming delivers tokens as they are generated, usually over SSE or
  WebSocket, to improve perceived latency.
- Chunk boundaries are model-driven, so partial output can be incomplete or
  grammatically awkward mid-stream.
- Validate or redact before streaming to a user if the content is untrusted or
  sensitive.

## Mid/Senior Interview Questions and Answers

### 1. When do you stream versus return a full response?

**Answer:** Stream when a human is watching and perceived latency matters —
chat, long-form generation, reasoning steps. Do not stream when the response
drives a business action, needs validation before display, or is short enough
that streaming adds complexity for no perceived gain.

Streaming complicates error handling, retries, structured output validation,
and observability. If the surface is a background job or an API returning
JSON to another service, non-streaming is almost always the right call.

### 2. When do you pick SSE over WebSocket for streaming model output?

**Answer:** SSE is a one-way, HTTP-based stream that is simpler, works through
proxies and load balancers, auto-reconnects, and needs no special auth
handling. WebSocket buys bidirectional communication — useful when the client
also sends messages mid-stream, like a voice agent — at the cost of connection
state, proxying headaches, and heartbeats. For chat-style token streams, SSE
is the default.

### 3. How do you validate or parse partial output that arrives mid-stream?

**Answer:** Do not try to validate every token. Buffer the stream into sentence
or JSON-delta boundaries and validate incrementally, or render partials for
display while validating the complete result before any action. For structured
output, parse incrementally and only act on a fully validated result. Make the
distinction explicit: partial text is for display, validated output is for
actions.

### 4. How do you redact or filter content before it streams to a user?

**Answer:** Apply a redaction or moderation pass on the buffered stream before
forwarding, chunking output so sensitive spans are caught before they leave
your boundary. Never stream provider output directly to the user when the
content is untrusted or carries PII. The trade-off is a small latency cost for
the buffering window, which you accept when safety outweighs speed.

### 5. How do you combine streaming with tool calling?

**Answer:** Stream the assistant's reasoning and arguments as they come, but
execute the tool only on the final, complete arguments — partial or
hallucinated tool input is how bad side effects happen. Signal tool execution
as a separate stream event so the UI can show it, then continue streaming after
the tool result. The stream protocol must distinguish text deltas from
structured events.
