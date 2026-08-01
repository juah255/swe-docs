# Structured Outputs

Structured outputs are useful when application code must consume the model
response.

## When To Use

- Classification.
- Data extraction.
- Routing.
- Form filling.
- Workflow decisions.
- API payload generation.

## Design Rules

- Use JSON schemas or typed output parsers where available.
- Validate the response before using it.
- Reject or repair malformed responses with bounded retries.
- Keep generated text separate from trusted internal fields.
- Do not execute model-produced commands without validation and authorization.

## Example Schema

```json
{
  "category": "billing | bug | account | other",
  "priority": "low | medium | high",
  "summary": "short user-facing summary",
  "missing_information": ["string"]
}
```

## Failure Handling

- If parsing fails, retry with the same schema and a small retry limit.
- If validation fails, ask the model to repair only the invalid fields.
- If confidence is low, route to human review or a deterministic fallback.
- Log invalid outputs so evaluation data can improve over time.

## Mid/Senior Interview Questions and Answers

### 1. JSON mode, schema-constrained output, or tool calling — which do you pick?

**Answer:** Tool calling when the model is choosing an action or invoking a
function with typed arguments — the schema doubles as the tool signature.
Schema-constrained or grammar-constrained decoding when the provider supports
it and you need guaranteed parseable output for a single structured payload.
Plain JSON mode when neither is available and you accept validation and retry
cost on your side.

Do not conflate "the model returned JSON" with "the model returned correct
data." All three approaches still require semantic validation — types being
right does not mean the values are.

### 2. What is your validation strategy when the model returns invalid output?

**Answer:** Two layers. First, syntactic and schema validation — parse, type
check, enum check. Second, semantic validation — cross-check against known
constraints, source documents, or business rules. Bounded retries on the
first layer with a repair prompt that quotes the exact error. Route to human
review or a deterministic fallback on the second.

Log every invalid output with the prompt version so you can feed real
failures back into the eval set. If invalid rates rise after a model or
prompt change, that is your regression signal — do not wait for a user
report.

### 3. When does a Pydantic or Zod schema help, and when does it hurt?

**Answer:** It helps when the schema is genuinely typed application data —
enums, required fields, nested objects that downstream code depends on. You
get validation, editor support, and a single source of truth for the shape.

It hurts when the schema is over-specified: strict field orderings, deeply
nested optionals, or fields the model has no way to fill correctly. The
model wastes tokens on shape instead of content, and your retry rate climbs.
Keep schemas as flat and permissive as the downstream contract allows.

### 4. How do you handle partial or streamed structured output?

**Answer:** Usually you do not stream to the caller — you buffer until the
object is complete, then validate and emit. Streaming partial JSON to a UI
requires an incremental parser that tolerates unclosed tokens, and any
downstream action must wait for validation. The complexity rarely pays off.

If perceived latency really matters, stream a human-readable summary field
first and hold the structured payload until it is complete. Never fire
side-effecting actions on partial output — a tool call built from half a
JSON object is a production incident waiting to happen.

### 5. How do you evolve a schema without breaking prompts?

**Answer:** Additive changes are cheap: new optional fields, new enum
values, with the prompt updated to describe them. Breaking changes —
removed fields, renamed keys, tightened types — need a version bump on the
prompt and the schema together, plus a migration for logged data and eval
sets.

Version both the prompt and the schema, and log both on every request. When
a downstream consumer needs a new field, add it optionally, backfill from
model output over time, and only make it required after evaluation confirms
the model fills it reliably.
