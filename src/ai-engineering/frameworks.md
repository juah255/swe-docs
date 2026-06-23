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
