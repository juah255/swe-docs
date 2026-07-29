# AI Engineering Interview Questions

Comprehensive index of all mid/senior interview questions across AI engineering topics.
Answers are in the referenced source files.

## AI Engineering Fundamentals

*Source:* `ai-engineering/index.md`

- How is AI engineering different from ML engineering?
- When is an LLM the wrong tool for the job?
- What are the biggest failure modes of LLMs in production?
- How do you evaluate whether a candidate has real AI-engineering experience?
- What does "production-ready" mean for an LLM feature?

## LLM Fundamentals

*Source:* `ai-engineering/llm-fundamentals.md`

- How do you choose the right model size for a task?
- Why isn't lowering temperature the fix for most quality problems?
- What actually causes hallucinations, and how do you mitigate them?
- What are the trade-offs of a larger context window?
- When should you use embeddings instead of generation?

## Prompt Engineering

*Source:* `ai-engineering/prompt-engineering.md`

- Why do prompt tweaks regress silently, and how do you prevent it?
- When do you pick few-shot, zero-shot, or fine-tuning?
- How do you keep the system prompt and user prompt disciplined?
- When is a prompt "done"?
- How do you handle a provider's model update without breaking prompts?

## Model Integration

*Source:* `ai-engineering/model-integration.md`

- How do you design an LLM client for reliability?
- When do you stream versus return a full response?
- Is a provider abstraction worth building?
- How do you handle rate limits and quotas?
- What does secrets and config discipline look like for LLM apps?

## Structured Outputs

*Source:* `ai-engineering/structured-outputs.md`

- JSON mode, schema-constrained output, or tool calling — which do you pick?
- What is your validation strategy when the model returns invalid output?
- When does a Pydantic or Zod schema help, and when does it hurt?
- How do you handle partial or streamed structured output?
- How do you evolve a schema without breaking prompts?

## RAG

*Source:* `ai-engineering/rag.md`

- Why do RAG systems usually fail in production?
- When is RAG the wrong answer?
- How do you evaluate a RAG pipeline end-to-end?
- How do you keep the index fresh without rebuilding everything?
- Hybrid search versus pure vector search — which do you pick?

## Vector Databases

*Source:* `ai-engineering/vector-databases.md`

- How do you choose between Pinecone, Weaviate, pgvector, Qdrant, and Milvus?
- What actually drives sizing and scaling for a vector index?
- When do you not need a dedicated vector database?
- HNSW versus IVF — what are the trade-offs?
- What are the common pitfalls with metadata filtering?

## Tool Calling

*Source:* `ai-engineering/tool-calling.md`

- Few big tools or many small tools — how do you design the surface?
- How do you validate tool inputs from the model?
- How do you handle failed, hallucinated, or repeated tool calls?
- When do you force tool use versus leave it optional?
- What is the security posture when exposing tools to an LLM?

## Agents and Workflows

*Source:* `ai-engineering/agents-and-workflows.md`

- Workflow or agent — how do you actually decide?
- How do you keep loop cost and runaway behavior under control?
- What does a test for an agent even look like?
- What human-in-the-loop patterns actually work?
- Why do most agent demos not survive production?

## MCP

*Source:* `ai-engineering/mcp.md`

- What does MCP actually solve that ad-hoc tool integration does not?
- What is the security posture of running MCP servers?
- When should you not reach for MCP?
- MCP versus direct SDK tools — how do you pick?
- How do you version MCP servers across clients?

## Frameworks

*Source:* `ai-engineering/frameworks.md`

- When does a framework like LangChain start hurting more than helping?
- What should you build yourself instead of pulling in a framework?
- How do you evaluate a framework for lock-in and abstraction cost?
- How do you survive a framework's breaking release?
- When is "no framework, just the SDK" the right call?

## Evaluation

*Source:* `ai-engineering/evaluation.md`

- How do you design an eval that actually catches regressions?
- When does LLM-as-judge lie to you?
- What's the difference between offline and online eval, and when does each fail?
- How do you build a golden set that stays useful?
- Why aren't unit tests enough for LLM apps?

## Observability

*Source:* `ai-engineering/observability.md`

- What do you log for an LLM app, and what do you deliberately not log?
- How do you trace a multi-step LLM workflow so it's actually debuggable?
- How do you alert on quality regressions, not just uptime?
- A user says the assistant gave a bad answer last Tuesday. How do you debug it?
- How do you balance debuggability with the privacy of not logging prompts?

## Cost and Latency

*Source:* `ai-engineering/cost-and-latency.md`

- How do you measure per-request cost end-to-end?
- How do you cut cost without cutting quality?
- When does TTFT matter more than total latency, and when is it the reverse?
- When does batching help, and when does it just add complexity?
- When is the naive one-model-call approach actually fine?

## Safety and Security

*Source:* `ai-engineering/safety-and-security.md`

- What's a realistic prompt injection threat model, and what actually mitigates it?
- How do you handle PII and prevent data leakage to the model provider?
- What does a real red-team practice for LLM apps look like?
- Input filtering vs output filtering — where should defenses live?
- When is a guardrail theater vs actual defense?

## Deployment

*Source:* `ai-engineering/deployment.md`

- How do you roll out a prompt or model change safely in production?
- What does a real rollback strategy look like for an LLM app?
- When would you pick blue-green over progressive delivery for an AI feature?
- How do you handle provider outages and degraded modes?
- How do you keep dev, staging, and production in parity for LLM apps?

## MLOps and LLMOps

*Source:* `ai-engineering/mlops-and-llmops.md`

- How does LLMOps actually differ from classical MLOps?
- How do you version prompts, models, and data together?
- How do you detect drift when there is no ground truth?
- Walk through incident response for a bad LLM release.
- What does a promotion pipeline for prompt changes look like?
