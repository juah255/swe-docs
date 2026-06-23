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
