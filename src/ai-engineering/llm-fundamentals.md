# LLM Fundamentals

Large language models are probabilistic text models. They predict likely output
tokens from input tokens and learned patterns.

## Core Terms

- **Token**: a piece of text processed by the model. Cost, latency, and context
  limits are usually measured in tokens.
- **Context window**: the maximum input and output tokens a model can handle in
  one request.
- **Temperature**: controls randomness. Lower values are better for consistent
  tasks; higher values are better for creative generation.
- **Top-p**: limits sampling to the most likely token candidates.
- **System instruction**: high-priority instruction that defines the assistant's
  role, rules, and behavior.
- **User instruction**: the immediate task request from the user or product.
- **Few-shot prompting**: providing examples so the model can follow a pattern.
- **Embedding**: a numeric representation of text used for semantic search,
  clustering, deduplication, and recommendations.

## Practical Model Selection

- Start with the smallest model that may solve the task.
- Test with representative inputs, not only happy paths.
- Measure quality, latency, and cost together.
- Use stronger models for reasoning-heavy, ambiguous, or high-value tasks.
- Use smaller models for classification, extraction, routing, and rewriting
  when evaluation proves quality is acceptable.

## Common Failure Modes

- The model confidently states unsupported facts.
- The answer follows style instructions but misses the actual task.
- Long context distracts the model from the most relevant evidence.
- Small prompt changes produce behavior regressions.
- The model returns valid-looking output that violates business rules.

Practical rule: treat an LLM as an unreliable dependency until the surrounding
system has tests, validation, monitoring, and fallback behavior.

## Mid/Senior Interview Questions and Answers

### 1. How do you choose the right model size for a task?

**Answer:** Start with the cheapest model that has a chance of working, run it
against a representative eval set, and only move up when quality on the eval
set is clearly insufficient. Do not select on vibes or single examples.

For classification, extraction, routing, and rewriting, small models plus a
tight prompt and validation usually win on cost and latency. Reserve frontier
models for ambiguous reasoning, long-context synthesis, or high-value tasks
where a few cents per call is irrelevant next to the wrong answer.

### 2. Why isn't lowering temperature the fix for most quality problems?

**Answer:** Temperature controls sampling randomness, not correctness. If the
model is missing context, misunderstanding the task, or hallucinating from
weak evidence, temperature 0 just makes the same wrong answer deterministic.

Quality problems usually come from unclear instructions, missing grounding,
weak examples, or an overloaded context. Fix the prompt, the retrieval, or the
task decomposition first. Use low temperature to stabilize an already-correct
pipeline, not to paper over a broken one.

### 3. What actually causes hallucinations, and how do you mitigate them?

**Answer:** Hallucinations come from asking the model to produce facts it does
not have — missing grounding, ambiguous instructions, or forcing an answer
when the correct response is "I don't know." Long, noisy context also dilutes
the relevant evidence.

Mitigations: ground the answer with retrieval and cite sources, tell the model
explicitly to say "not provided" when data is missing, constrain outputs with
a schema, validate any factual field against a source, and evaluate for
faithfulness — not just fluency. Never rely on the model to police itself.

### 4. What are the trade-offs of a larger context window?

**Answer:** Larger context lets you skip aggressive retrieval, but it costs
more per token, increases latency, and often degrades quality — models attend
unevenly across long inputs and get distracted by irrelevant content. "Just
stuff everything in" is rarely the right answer.

Prefer targeted retrieval, deduplication, and summarization. Use long context
for tasks that genuinely require cross-document reasoning, and measure whether
quality actually improves versus a smaller, well-curated context.

### 5. When should you use embeddings instead of generation?

**Answer:** Embeddings are for similarity: search, clustering, deduplication,
routing, and recommendations. They are cheap, fast, deterministic, and easy
to cache. Use them when you need to find or compare, not when you need to
produce text or reason.

A common mistake is calling a generation model to classify or match when an
embedding plus a distance threshold — or a small classifier on top of
embeddings — would be faster, cheaper, and more stable across model updates.
