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
