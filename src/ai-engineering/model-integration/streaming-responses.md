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
