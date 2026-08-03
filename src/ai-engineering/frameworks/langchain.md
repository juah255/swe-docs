# LangChain

LangChain is a framework for building applications around language models. It
provides building blocks for prompts, model calls, retrieval, tools, and
chained workflows, plus a large ecosystem of integrations.

## Core Concepts

- **Chains**: composed steps that run in sequence — prompt, model call, output
  parsing — linked into a pipeline.
- **Prompt templates**: reusable prompt definitions with variables, so prompts
  stay versioned and consistent instead of string-built at call sites.
- **Document loaders and retrievers**: load content from many sources and fetch
  relevant chunks for context injection.
- **Tool integrations**: connectors that let models call functions such as
  search, databases, or APIs.
- **LCEL**: the LangChain Expression Language for composing chains with lazy
  evaluation, streaming, and parallel steps.
- **Memory**: abstractions for carrying conversation history across turns.

## Key Features

- **Prototyping speed**: connecting prompts, models, loaders, and retrievers is
  fast, which makes it strong for early exploration and demos.
- **Large ecosystem**: many integrations for providers, vector stores, and
  document sources.
- **Composable chains**: LCEL lets you build pipelines declaratively and run
  them with streaming and batching.
- **Tool and agent primitives**: utilities for tool calling and agent loops
  without writing all the glue.

## When To Use

Use LangChain when:

- You want to prototype a multi-step AI feature quickly.
- You need many integrations and want to avoid hand-rolling each client.
- The workflow matches the framework's assumptions: chains of model calls with
  retrieval or tool steps.

Prefer plain code or a direct SDK when:

- The workflow is a few linear steps — a prompt, a call, a parse.
- You need tight control over token usage, error handling, and state.
- The framework's abstractions would hide behavior you must reason about under
  an incident.

## Best Practices

- Keep business rules, permissions, and persistence in application-owned code,
  not inside framework chains.
- Treat prompts as versioned assets: store them in code and review changes like
  any other application logic.
- Use the framework for the boring glue and commodity pieces — loaders,
  tokenizers, vector store clients — and own the hot path yourself.
- Inspect what a chain actually sends: token counts, prompt text, and tool
  results should remain visible for debugging and cost attribution.
- Read the source of the primitives you depend on most before trusting their
  defaults.

## Pitfalls

- **Hidden abstraction**: chains can obscure prompt assembly, retries, and tool
  routing behind decorators, which turns debugging into guessing.
- **Version churn**: the framework has a history of breaking changes; a pinned
  version can go stale fast, and upgrade tax compounds.
- **Over-engineering**: wrapping a single model call in a chain adds indirection
  with no benefit.
- **Lock-in**: deep reliance on framework-specific chains makes it hard to swap
  pieces or move to a direct SDK later.

See [LangGraph](langgraph.md) for stateful, graph-based workflows, and the
[Frameworks overview](index.md) for selection criteria.

## Mid/Senior Interview Questions and Answers

### 1. How do you prevent LangChain's abstractions from hiding production-critical behavior?

**Answer:** The risk is that chains hide prompt assembly, token usage, retries,
and tool routing behind decorators, so you cannot see what is actually sent or
why a step failed. Own the observability: log the assembled prompt, model name
and parameters, token counts, and tool results at the chain boundaries, and
keep a request ID that ties every step together.

Inspect the source of the primitives you rely on most before trusting their
defaults — retry policies, streaming behavior, and output parsing are where
silent surprises live. If a chain cannot be made inspectable as plain data,
that is a signal to replace it with your own code.

### 2. How do you use LangChain without getting locked in?

**Answer:** Isolate framework calls behind a thin adapter you own, so the
integration surface is one module instead of the whole codebase. Keep business
rules, permissions, and persistence in application-owned code — never inside a
chain. Use the framework for commodity pieces (loaders, vector store clients,
provider connectors) and own the hot path yourself.

Treat prompts and model versions as your own config, not framework state, so
you can migrate off the framework without migrating your product logic. If the
workflow stabilizes, consider replacing the chain with direct SDK calls —
LangChain's value is prototyping speed, not being a runtime dependency.

### 3. How do you debug a LangChain chain that returns a wrong answer?

**Answer:** Reconstruct what actually ran. A chain is only debuggable if you
record each step: the rendered prompt, the model call with its parameters, the
raw output, and any parsed result. Without that, a wrong answer is
indistinguishable from "the AI got confused."

Check the deterministic layers first — prompt template rendering, output
parser behavior, and tool result handling — before blaming the model. Then
reproduce with the same inputs and add the failing case to your eval set. If
the chain's abstractions make this impossible to trace, that is the clearest
sign the framework is costing more than it saves.

### 4. How do you handle LangChain's version churn in production?

**Answer:** Pin exact versions and treat upgrades like any dependency change:
read the changelog, run your eval suite and integration tests against the new
version, and ship it through the normal rollout stages instead of letting a
`latest` pin drift under you. Isolate framework calls behind your own adapter
so a breaking release touches one module.

Track how the project treats breaking changes before you adopt new primitives.
If upgrades keep breaking behavior you did not expect, reduce your surface
area — a framework that forces constant migration work is more expensive than
a few hundred lines of direct SDK code.

### 5. When do you use an LCEL chain versus plain Python functions?

**Answer:** Use LCEL chains when you want lazy, streamable, parallel pipelines
with little glue — for example a retrieval-plus-generation flow where the
framework's composition genuinely saves code. Reach for plain functions the
moment the step has real business logic: custom validation, authorization,
error handling, or state that must survive across calls.

A good rule of thumb: if the chain is just "prompt, call, parse," write it as a
function. If it is several composed steps that benefit from streaming and
parallel execution, an LCEL chain can be cleaner — as long as you can still
inspect every step. The framework should express the pipeline, not hide it.

General framework questions (abstraction cost, lock-in, breaking releases, and
when to skip frameworks) are covered in the [Frameworks overview](index.md).
