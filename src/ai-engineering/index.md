# AI Engineering

AI engineering focuses on building reliable software systems around models.
The model is one dependency in a larger product system that also includes data,
retrieval, prompts, tools, evaluation, monitoring, deployment, cost control, and
safety.

## Learning Path

Follow these topics in order when learning AI engineering from the beginning:

1. [LLM Fundamentals](llm-fundamentals.md): tokens, context windows, sampling,
   embeddings, and model capabilities.
2. [Prompt Engineering](prompt-engineering.md): instructions, examples,
   constraints, output formats, and prompt versioning.
3. [Model Integration](model-integration.md): API calls, streaming, retries,
   timeouts, error handling, and fallbacks.
4. [Structured Outputs](structured-outputs.md): schemas, validation, parsing,
   extraction, and typed application contracts.
5. [Retrieval-Augmented Generation](rag.md): indexing, chunking, retrieval,
   reranking, grounding, and citations.
6. [Vector Databases](vector-databases.md): embeddings, similarity search,
   metadata filters, hybrid search, and index maintenance.
7. [Tool Calling](tool-calling.md): function calling, tool schemas, permission
   boundaries, and side-effect controls.
8. [Agents and Workflows](agents-and-workflows.md): orchestration, state,
   graph-based workflows, checkpoints, and human review.
9. [Model Context Protocol](mcp.md): reusable tool and data integrations for AI
   applications.
10. [Frameworks](frameworks.md): LangChain, LangGraph, LlamaIndex, and related
    ecosystem tools.
11. [Evaluation](evaluation.md): golden datasets, automated checks, human
    review, regression tests, and production feedback.
12. [Observability](observability.md): traces, token usage, retrieval quality,
    tool calls, cost, and user feedback.
13. [Cost and Latency](cost-and-latency.md): model routing, caching, prompt
    reduction, batching, streaming, and budgets.
14. [Safety and Security](safety-and-security.md): prompt injection, data
    leakage, authorization, validation, and high-risk workflows.
15. [Deployment](deployment.md): release controls, rollback plans, monitoring,
    and production readiness.
16. [MLOps and LLMOps](mlops-and-llmops.md): versioning, governance, model
    lifecycle, and continuous improvement.

## Suggested Practice

- Build a document Q&A system with RAG and source citations.
- Add structured JSON extraction from messy text and validate the schema.
- Create a support-ticket classifier with evaluation data.
- Build a tool-calling assistant that can query a read-only API.
- Add tracing, token usage, cost tracking, and feedback collection.
- Compare two prompts or two models using the same evaluation dataset.
- Add prompt-injection test cases to a RAG pipeline.

## Interview Preparation

Use [AI Engineering Questions](questions.md) for mid/senior interview questions
and answers.

## Mid/Senior Interview Questions and Answers

### 1. How is AI engineering different from ML engineering?

**Answer:** ML engineering owns training pipelines, feature stores, model
training, and offline metrics. AI engineering owns the product system around a
model that someone else usually trained: prompts, retrieval, tools, evaluation,
guardrails, latency, cost, and rollout.

The scarce skill in AI engineering is not model math — it is building reliable
software when a probabilistic dependency can silently regress. Candidates who
only talk about model choice usually skip the harder work of evaluation,
observability, and failure isolation.

### 2. When is an LLM the wrong tool for the job?

**Answer:** Deterministic rules, exact numeric computation, high-volume
classification with cheap labeled data, and anything with strict correctness
guarantees. If a regex, a SQL query, a classical classifier, or a lookup table
gives 99% quality at a fraction of the cost and latency, an LLM is a liability,
not a feature.

Use an LLM when the input is unstructured, the rules are fuzzy, and the cost of
being wrong is bounded — or when it augments a deterministic system rather than
replacing it.

### 3. What are the biggest failure modes of LLMs in production?

**Answer:** Silent prompt regressions on model updates, hallucinated facts that
look confident, prompt injection through retrieved or user content, cost blowups
from unbounded context or agent loops, latency variance under load, and lack of
evaluation coverage so nobody notices quality drift until users complain.

The common pattern: teams ship without a golden eval set, without token and
latency budgets, and without a rollback path for a prompt or model change. The
model then becomes a load-bearing dependency with no test suite.

### 4. How do you evaluate whether a candidate has real AI-engineering experience?

**Answer:** Ask about a change they shipped that regressed quality and how they
detected it. Real practitioners describe an eval set, a metric, an alert, or a
user report — not a hunch. Ask how they version prompts, how they compare two
models on the same task, and what their p95 latency and cost per successful
task were.

Candidates without production experience default to framework names and model
benchmarks. Senior candidates talk about eval rigor, failure isolation, and the
boring reliability work.

### 5. What does "production-ready" mean for an LLM feature?

**Answer:** Prompts under source control with versions, an offline evaluation
set that gates changes, structured logging with prompt version and token usage,
timeouts and bounded retries, a fallback for provider outages, cost and latency
budgets with alerts, and a documented rollback plan.

If you cannot answer "how would I revert this prompt in five minutes" and "how
would I know quality dropped," it is not production-ready — it is a demo.
