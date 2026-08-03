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

## Mid/Senior Interview Questions and Answers

### 1. How do you choose between streaming and batched transcription?

**Answer:** Stream when a human is listening or latency matters — live
transcription, voice agents — and accept partial transcripts with a final pass
for accuracy. Batch when accuracy or cost matters more than speed, like meeting
notes or call analytics. The two can share one pipeline: stream for
interaction, then re-run the audio for a cleaned, verified transcript.

### 2. How do you chunk long audio without losing accuracy?

**Answer:** Chunk by natural pauses, speaker turns, or fixed time windows so
each segment stays under the model's context limit and within a sane cost
budget. Overlap chunks slightly and use timestamps to stitch segments back
together without duplication or dropped words. Watch that speaker labels and
cross-segment context survive the split; re-stitch with that in mind.

### 3. How do you keep real-time voice latency low?

**Answer:** Real-time voice demands streaming input and output, so optimize for
time-to-first-token and end-to-end round trip, not just final accuracy. Use
partial transcripts for display while a full pass runs for the record, and
measure perceived latency against the actual pipeline. Degrade gracefully:
when audio quality drops, fall back to a higher-latency mode rather than
returning garbage.

### 4. How do you redact PII before audio reaches a provider?

**Answer:** Redact PII before the audio leaves your boundary: scrub names,
account numbers, and card numbers from the transcript or the audio itself, and
never send raw recordings when a redacted or transcription-only path is
possible. Match languages and dialects to the model so redaction is not
defeated by transcription errors, and apply the same rules on model output
before storing or displaying it.

### 5. How do you reason about compliance for recording and processing audio?

**Answer:** Confirm the legal basis for recording, transcribing, and storing
audio before building the feature, and obtain consent where required. Delete or
retain audio per your data policy, not the provider's defaults, and document
what was sent, stored, and for how long. Compliance is not a one-time check —
re-review when you add languages, jurisdictions, or providers.
