# Evaluation

Evaluation checks whether an AI feature is actually useful, safe, and stable.

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

## RAG Evaluation

Evaluate retrieval and generation separately.

- Did retrieval find the right documents?
- Did the model use the retrieved evidence correctly?
- Did the answer cite the right source?
- Did the model say it does not know when evidence was missing?

## Practical Advice

Start with a small but realistic dataset. Add new examples whenever production
feedback reveals a failure, edge case, or ambiguous requirement.
