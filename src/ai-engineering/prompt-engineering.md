# Prompt Engineering

Good prompts make the task, constraints, and output contract explicit.

## Prompt Design Checklist

- Start with the user's goal and the product context.
- Define the role only if it changes behavior.
- Provide relevant input data and remove unrelated context.
- Specify the expected output format.
- Add examples when the task has subtle rules.
- Tell the model what to do when information is missing.
- Avoid asking the model to invent facts, IDs, links, prices, or citations.
- Keep prompt versions in code so changes can be reviewed and tested.

## Example Structure

```text
Task:
Summarize the support ticket for an engineering handoff.

Rules:
- Use only the ticket content.
- Include reproduction steps if present.
- Say "Not provided" for missing environment details.

Output:
- Summary
- Impact
- Reproduction steps
- Suspected area
```

## Prompt Versioning

Prompts are application logic. Store them in source control, review changes, and
run evaluation before deploying updates.

Track:

- Prompt name.
- Prompt version.
- Model name.
- Parameters such as temperature.
- Evaluation dataset used before release.
- Known limitations.

## Common Mistakes

- Using vague instructions such as "be accurate" without defining evidence.
- Asking for a strict format without validating the result.
- Passing too much irrelevant context.
- Mixing untrusted retrieved content with trusted instructions.
- Changing prompts in production without regression tests.
