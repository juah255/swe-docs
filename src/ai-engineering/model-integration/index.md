# Model Integration

Model integration is the application code around model calls: request building,
streaming, retries, parsing, failure handling, and fallbacks. This section
covers the API surface of models in different modalities and how to call them
reliably.

- [AI APIs](ai-apis.md): request design, retries, rate limits, and production
  concerns.
- [Streaming Responses](streaming-responses.md): streaming for perceived
  latency and when to avoid it.
- [Chat Completions](chat-completions.md): message roles, history, and request
  parameters.
- [Function / Tool Calling](function-tool-calling.md): connecting models to
  application-defined functions.
- [Vision Models](vision-models.md): image inputs for OCR, extraction, and
  document reading.
- [Image Generation](image-generation.md): text-to-image generation and its
  operational concerns.
- [Audio Models](audio-models.md): transcription, text-to-speech, and audio
  understanding.
- [Reasoning Models](reasoning-models.md): chain-of-thought models and their
  latency and cost trade-offs.
