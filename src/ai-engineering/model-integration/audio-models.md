# Audio Models

Audio models handle speech and sound. Common capabilities are speech-to-text
(transcription), text-to-speech, and audio understanding.

## Capabilities

- Speech-to-text: transcribe audio into text, including timestamps and speaker
  labels when supported.
- Text-to-speech: synthesize speech from text for voices, agents, or narration.
- Audio understanding: summarize, classify, or extract information from audio
  or sound.

## Latency

- Streaming audio keeps latency low for interactive use, such as live
  transcription or voice agents.
- Chunk long audio into segments to avoid context limits and improve cost and
  accuracy.
- Consider partial transcripts for interactive surfaces, with a full pass for
  final accuracy.

## Privacy and Compliance

- Language support varies by model; match the model to the languages you serve.
- Redact PII in the prompt or input before sending audio to a provider.
- Recording and processing audio may require consent and compliance handling.
  Confirm the legal basis before storing or sending recordings.
- Delete or retain audio according to your data policy, not the provider's
  defaults.

See [AI APIs](ai-apis.md) for request design, retries, and rate limits.
