# Frameworks

Frameworks help with orchestration, retrieval, tools, memory, and evaluation,
but they should not hide core system behavior.

## LangChain

- Useful for chains, prompt templates, document loaders, retrievers, and tool
  integrations.
- Good for prototyping and connecting common AI building blocks.
- Keep business logic outside framework-specific chains where possible.

## LangGraph

- Useful for stateful agent workflows.
- Supports graph-based flows, branching, retries, checkpoints, and human review.
- Good fit when the process has multiple steps and explicit state.

## LlamaIndex

- Useful for data ingestion, indexing, retrieval, and RAG over documents.
- Good fit for knowledge-base and document-heavy applications.

## Selection Criteria

- Does the framework match the workflow shape?
- Can the team debug failures without guessing?
- Can prompts, tool calls, retrieval, and state transitions be tested?
- Does it integrate with the application's observability stack?
- Is it easy to replace framework pieces if product requirements change?

Frameworks are useful accelerators, but production systems should keep business
rules, permissions, and persistence in application-owned code.

## Mid/Senior Interview Questions and Answers

### 1. When does a framework like LangChain start hurting more than helping?

**Answer:** It hurts once the workflow diverges from the framework's assumed
shape and every custom step requires fighting abstractions. Debugging a chain
where prompt assembly, retries, and tool routing are hidden behind decorators
becomes slower than reading a plain function.

Reach for a framework for the first prototype and the boring glue. Rip it out
of the hot path once the workflow stabilizes and you need to reason about
exact token usage, error handling, and state transitions.

### 2. What should you build yourself instead of pulling in a framework?

**Answer:** Own the pieces that touch business rules, auth, persistence, and
anything you need to reason about under an incident. That usually means the
prompt assembly step, the tool dispatcher, the retry and timeout policy, and
the persistence of intermediate state.

Pull in libraries for document loaders, tokenizers, vector store clients, and
provider SDKs — those are commodity work with real edge cases you do not want
to reimplement.

### 3. How do you evaluate a framework for lock-in and abstraction cost?

**Answer:** Read the source of the two or three primitives you would use most.
If a "simple" chain hides five layers of callbacks, dynamic dispatch, and
implicit state, the abstraction cost will show up as production incidents you
cannot trace.

Check whether prompts, model calls, and tool results are inspectable as plain
data. Check whether you can swap the model provider without a rewrite. Check
how the framework has treated breaking changes historically — that is the
best predictor of your future upgrade pain.

### 4. How do you survive a framework's breaking release?

**Answer:** Isolate framework calls behind a thin adapter you own, so the
blast radius of an upgrade is one module, not the whole codebase. Pin
versions, read the changelog before upgrading, and run your eval suite
against the new version before shipping.

If a framework ships breaking changes every minor release, that is a signal
to reduce your surface area or replace it with 200 lines of your own code.
The upgrade tax compounds.

### 5. When is "no framework, just the SDK" the right call?

**Answer:** When the workflow is a handful of steps, the team already knows
the provider SDK, and you want full control over prompts, retries, and
observability. Most production LLM features are a validation step, a prompt,
a model call, an output parser, and a persistence step — that does not need
an orchestration framework.

Frameworks earn their keep on stateful multi-agent graphs, complex retrieval
pipelines, and prototyping speed. For a single-shot classifier or a simple
RAG endpoint, direct SDK calls are easier to debug and cheaper to maintain.
