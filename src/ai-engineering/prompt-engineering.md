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

## Mid/Senior Interview Questions and Answers

### 1. Why do prompt tweaks regress silently, and how do you prevent it?

**Answer:** A prompt change that fixes one input often shifts behavior on
inputs nobody looked at. Without an eval set, the regression is invisible
until a user reports it — and by then the change has been live for days.

Treat prompts as code: version them, review them, and gate changes on a
golden eval set with pass/fail metrics. Log the prompt version on every
request so you can attribute quality shifts to a specific change and roll
back cleanly.

### 2. When do you pick few-shot, zero-shot, or fine-tuning?

**Answer:** Zero-shot is the default — cheapest, simplest, and easiest to
change. Add few-shot examples when the task has subtle rules the model keeps
missing, or when the output format needs to be stable. Keep examples short
and representative; too many examples burn tokens and can bias the model.

Fine-tune only when prompting has hit a quality ceiling on a well-defined,
high-volume task with stable inputs, and when you accept the operational cost
of dataset curation, retraining on model updates, and losing the ability to
change behavior with a prompt edit.

### 3. How do you keep the system prompt and user prompt disciplined?

**Answer:** The system prompt owns role, rules, output contract, and safety
constraints — things that must not be overridden by user input. The user
prompt carries the task and its data. Never concatenate user content into the
system prompt, and never let retrieved content look like instructions.

Delimit untrusted content clearly, and remind the model in the system prompt
that anything inside those delimiters is data, not instructions. This is the
first line of defense against prompt injection.

### 4. When is a prompt "done"?

**Answer:** When it passes the eval set at the target metric, has stable
behavior across a range of realistic inputs, produces output that downstream
code can consume without special-cases, and its cost and latency fit the
budget. Not when it looks good on three hand-picked examples.

"Done" is also relative to a model version. A prompt tuned for one model
often needs re-evaluation on the next. Bake that into the release process,
not into a future migration project.

### 5. How do you handle a provider's model update without breaking prompts?

**Answer:** Pin a specific model version in code, never an alias that
silently upgrades. Before adopting a new version, run the eval set on both
old and new, compare quality, cost, and latency, and only cut over when the
new version wins or ties on the metrics that matter.

Keep the old version reachable for rollback until the new one has soaked in
production. If a prompt only works on one model version, that is a signal to
strengthen the prompt or the surrounding validation — not to freeze the
model forever.
