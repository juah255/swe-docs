# AI Engineering

Model integration notes, evaluation workflows, prompts, and tooling references.

## Mid/Senior Interview Questions and Answers

### 1. What makes an AI feature production-ready?

**Answer:** A production AI feature needs clear task definition, input and
output contracts, evaluation data, failure handling, observability, latency and
cost controls, safety checks, and a rollback plan.

The model call is only one part of the system. The surrounding product logic
must handle uncertainty.

### 2. How do you evaluate an LLM feature?

**Answer:** Use representative test cases, expected behavior criteria, human
review where needed, automated scoring where possible, regression tests, and
production monitoring.

Senior evaluation separates task success, factuality, formatting, safety,
latency, and cost. A single aggregate score can hide important failures.

### 3. What is retrieval-augmented generation?

**Answer:** Retrieval-augmented generation (`RAG`) retrieves relevant external
content and provides it to the model as context before generation.

RAG is useful when answers need private, current, or domain-specific knowledge.
Quality depends on chunking, embeddings, retrieval ranking, context assembly,
and citation or grounding behavior.

### 4. How do you reduce hallucinations?

**Answer:** Ground responses in retrieved or structured data, constrain output
formats, validate results, ask the model to say when information is missing, and
avoid asking it to invent unknown facts.

For high-risk workflows, use human review, deterministic checks, or source-based
answering rather than trusting generation alone.

### 5. How do you control AI cost and latency?

**Answer:** Use the smallest capable model, cache stable results, shorten
prompts, retrieve only relevant context, stream responses when useful, batch
offline work, and set timeouts and budgets.

Measure cost per successful task, not only cost per request.
