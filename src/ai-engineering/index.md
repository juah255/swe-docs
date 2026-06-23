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
