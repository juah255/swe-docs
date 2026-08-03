# Mastra

- TypeScript agent framework.
- Agents, workflows, tools, memory, and evaluation primitives.
- Supports multiple model providers.
- Useful for building and orchestrating agent systems in JS/TS.

See the [Frameworks overview](index.md) for selection criteria.

## Mid/Senior Interview Questions and Answers

### 1. When would you choose Mastra over plain TypeScript orchestration?

**Answer:** Choose Mastra when you want the agent primitives — agents,
workflows, tools, memory, and evaluation — without building the orchestration
loop from scratch. It is a good fit for TypeScript teams building multi-agent
or workflow-driven systems who want a common shape across model calls. Skip it
when the flow is a couple of linear calls or when you need tight control over
the agent loop, transport, and state, where a few hundred lines of your own
code are easier to reason about than framework abstractions.

### 2. How do the agents, workflows, and tools primitives differ, and when do you use each?

**Answer:** Agents own the model-driven loop — deciding, calling tools,
iterating. Workflows are deterministic, pre-defined steps for flows you know
in advance, and tools are the typed, callable functions both can use. Use
workflows for stable pipelines that need reliable ordering, and agents when
decisions depend on model judgment. Prefer explicit workflows over agents for
anything auditable and repeatable, and keep tools shared between them so a
step can be reused in either context.

### 3. How do you handle multiple model providers in Mastra?

**Answer:** Provider configuration is centralized, so swapping or mixing models
is a config change rather than a code change. Still treat providers as
interchangeable only at the level of the abstraction: features like function
calling and structured output differ across providers, so test each provider's
behavior with your actual workflows. Pin model and provider versions in config,
and keep capability-sensitive logic in your own code so a provider swap does
not silently change behavior.

### 4. What does Mastra's memory give you, and where does it live?

**Answer:** Memory lets an agent carry state across conversations — message
history or factual context about the user — so sessions are not stateless.
Where it lives matters: in-memory is fine for demos, but production needs a
persistent store sized to your data and subject to retention rules, since you
are storing user information. Keep memory bounded and scoped, and make sure
retrieval from memory is itself evaluated, because stale or irrelevant
remembered context is the same failure mode as bad retrieval in RAG.

### 5. How do you evaluate Mastra agents in production?

**Answer:** Evaluation starts before deployment: build a labeled set of tasks
and measure completion, tool-use correctness, and adherence to constraints, and
run it as a regression suite on every agent change. In production, log the full
agent trace — decisions, tool calls, intermediate state — so failures are
reproducible, and add guardrails and limits on steps and tokens to bound
runaway behavior. Treat the agent loop as deterministic infrastructure on top
of a stochastic model, and evaluate the infrastructure separately from the
model.
