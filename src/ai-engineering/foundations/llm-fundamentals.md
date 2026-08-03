# LLM Fundamentals

Large language models are probabilistic text models. They predict likely output
tokens from input tokens and learned patterns.

## Core Terms

- **System instruction**: high-priority instruction that defines the assistant's
  role, rules, and behavior.
- **User instruction**: the immediate task request from the user or product.
- **Few-shot prompting**: providing examples so the model can follow a pattern.

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

### 4. How do you evaluate a model before committing to it?

**Answer:** Build a small golden set of real, representative inputs with labeled
outputs and run candidates against it, scoring on the metrics that matter for
the task — accuracy, faithfulness, format compliance, cost, and latency. Do not
rely on three happy-path examples or public benchmarks, which rarely match your
distribution. Treat the eval as a gate that a new model must pass before it is
promoted to production.

### 5. How do you explain sampling and randomness to a product team?

**Answer:** Explain that the model does not "know" one correct answer but
samples from a probability distribution over likely next words, and temperature
tunes how flat or peaked that distribution is. Low temperature makes the most
likely answer more consistent; higher temperature makes output more varied and
creative. The product takeaway: temperature changes style and stability, not
correctness, and it should be tuned per surface, not globally.
