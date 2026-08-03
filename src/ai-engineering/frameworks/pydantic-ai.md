# Pydantic AI

- Python framework built on Pydantic.
- Typed, schema-validated model outputs.
- Agents with tools, structured results, and retries.
- Good when you want strong typing and validation in Python.
- Integrates with provider SDKs.

See the [Frameworks overview](index.md) for selection criteria.

## Mid/Senior Interview Questions and Answers

### 1. How does Pydantic AI give you typed outputs, and what happens on validation failure?

**Answer:** The model output is parsed into a Pydantic model, so a response
that does not conform to the schema fails validation instead of flowing
downstream as free text. That turns model errors into typed, catchable
exceptions and gives you the same guarantees as any validated boundary.
Because validation is first-class, schema violations can trigger retries with
a clearer prompt, and your application code can trust the shape of what it
receives.

### 2. How do you design agents with tools in Pydantic AI?

**Answer:** Tools are typed functions the agent can call, and their parameters
are Pydantic models, so the model's tool calls are validated just like
outputs. Keep tools small and single-purpose, with descriptions that tell the
model when to use them, and enforce limits on the number of tool calls per
turn to control cost. The agent loop — deciding, calling, observing, deciding
again — is the part you own: log the tool calls and results so the agent's
behavior stays traceable.

### 3. How do retries work in Pydantic AI, and when do they matter?

**Answer:** Retries re-run a model call when validation fails, so the agent can
recover from malformed output or a tool error instead of failing the turn.
Set a bound on retries — a validation loop can burn budget on a model that
keeps failing a strict schema. Retries matter most for structured output and
tool-heavy flows where the cost of a bad call is high, and least for simple
chat turns where a single failure is cheap to surface.

### 4. When do you choose Pydantic AI over the plain OpenAI Python SDK?

**Answer:** Choose Pydantic AI when validation and typing are the point: you
need schema-validated outputs, retries on failure, and typed tool calls, and
you do not want to build the validation layer yourself. The plain SDK is the
right choice for simple calls, or when you need the full provider surface and
fine-grained control over requests and errors without framework conventions.
Pydantic AI is worth it when the boundary between the model and your code must
be strictly typed.

### 5. How do you handle schema evolution for typed model outputs?

**Answer:** Version your output schemas and migrate like any data contract. A
model trained before a schema change will not reliably produce the new shape,
so pin the schema version alongside the model version in config, and keep a
default or fallback for old fields during transition. Backward-compatible
additions — safer than renames or removals — keep both the model and consumers
working while you roll out, and your evaluation set should track schema
version so regressions are visible.
