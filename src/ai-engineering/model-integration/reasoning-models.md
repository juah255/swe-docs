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
