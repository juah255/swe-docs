# Evaluation

Evaluation checks whether an AI feature is actually useful, safe, and stable.

## Evaluation Guides

- [Prompt Evaluation](prompt-evaluation.md)
- [RAG Evaluation](rag-evaluation.md)
- [Agent Evaluation](agent-evaluation.md)
- [Benchmarks](benchmarks.md)
- [Human Evaluation](human-evaluation.md)
- [Automated Evaluation](automated-evaluation.md)

## Evaluation Inputs

- **Golden dataset**: representative examples with expected behavior.
- **Unit tests**: prompt formatting, schema validation, tool routing, and parser
  behavior.
- **Regression tests**: prevent prompt or model changes from breaking known
  cases.
- **Human review**: useful for subjective quality, tone, reasoning, and safety.
- **Automated scoring**: useful for format, exact matching, retrieval recall,
  groundedness, and classification accuracy.
- **Production monitoring**: catches distribution shifts and failures not
  present in test data.

## Dimensions To Score

- Task success.
- Factual accuracy.
- Grounding in sources.
- Formatting correctness.
- Safety and policy compliance.
- Latency.
- Cost.
- User satisfaction.

## Practical Advice

Start with a small but realistic dataset. Add new examples whenever production
feedback reveals a failure, edge case, or ambiguous requirement.
