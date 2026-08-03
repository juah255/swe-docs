# Reasoning Models

Reasoning models spend extra tokens "thinking" before answering. They generate
a chain-of-thought internally to plan and check their work, then produce the
final response.

## Trade-Offs

- Better complex reasoning on math, multi-step logic, and tricky code.
- Higher latency: thinking takes time before the first output token.
- Higher cost: the thinking process consumes tokens you are billed for.
- More verbose output that needs parsing or trimming downstream.

## When To Use

- Math and symbolic computation.
- Multi-step planning and logic chains.
- Complex code generation and debugging.
- Tasks where the wrong answer is expensive and worth the extra latency.

## When Not To Use

- Simple classification, extraction, routing, or rewriting.
- Chatty or latency-sensitive interactions where a fast model feels better.
- High-volume paths where cost per call matters more than edge-case accuracy.

## Integration Notes

- Keep structured outputs and tool calling in mind: reasoning models still
  need schemas and validation around their output.
- Streaming the final answer helps perceived latency while the model is
  thinking.
- Decide what to do with chain-of-thought traces: exposing them can leak
  reasoning or sensitive context.
- See [Cost Optimization](../production/cost-optimization.md) for routing and
  optimization guidance.

## Mid/Senior Interview Questions and Answers

### 1. When do you route to a reasoning model versus a fast model?

**Answer:** Route to a reasoning model when the task is multi-step, math,
planning, or tricky code where a wrong answer is expensive and latency is
acceptable. Use fast models for classification, extraction, routing, and
rewriting, and for high-volume or latency-sensitive paths where cost per call
dominates. The split should be a routing decision measured by an eval, not a
per-call judgment call.

### 2. How do you manage the latency and cost of reasoning models?

**Answer:** Reasoning models bill for the thinking tokens as well as the reply,
so set explicit caps on the reasoning budget and watch both components in cost
and latency dashboards. Streaming the final answer hides part of the wait, but
the thinking time is real. Negotiate the trade-off by routing: spend the
reasoning budget only where the added accuracy pays for itself.

### 3. How do you handle chain-of-thought traces?

**Answer:** Treat chain-of-thought as private: it can leak the model's
assumptions, user-sensitive context, and prompts, so never expose it verbatim
to users or logs. Use it internally for debugging or as a scrubbed, structured
rationale, and keep the full trace in a separate, access-controlled store.
Follow the provider's policy on reasoning content and return only the final
answer by default.

### 4. How do you combine reasoning models with structured outputs and tool calling?

**Answer:** Reasoning models still need schemas and validation: ask for
structured output, use tool calling for actions, and validate the final answer
against the same contracts as any other model. Do not let the extra thinking
relax parsing and error handling. Where possible give the model the schema up
front so its planning aligns with the shape you need to consume.

### 5. How do you measure whether a reasoning model is actually worth it?

**Answer:** Compare the reasoning model against the fast baseline on the same
eval set, measuring accuracy, cost, and latency together rather than on single
examples. A reasoning model is worth it when it converts enough previously-wrong
high-value cases into correct ones to cover the added cost and delay. Track
accuracy drift over time; "worth it" is a moving target as both models improve.
