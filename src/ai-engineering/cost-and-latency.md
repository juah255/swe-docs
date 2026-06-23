# Cost and Latency

Cost and latency should be measured at the workflow level, not only at the model
request level.

## Optimization Techniques

- Use smaller models for simple tasks.
- Route requests by task difficulty.
- Cache stable answers and embeddings.
- Shorten prompts and retrieved context.
- Stream responses for better perceived latency.
- Batch offline jobs.
- Use asynchronous processing for non-interactive work.
- Set timeouts and fallback behavior.
- Measure cost per successful workflow, not only cost per token.

## Model Routing

Route by task type:

- Small model for classification, extraction, and rewriting.
- Stronger model for complex reasoning or high-value workflows.
- Fallback model when the primary provider is unavailable.
- Human review when no model meets the risk threshold.

## Practical Rule

Do not optimize cost before the evaluation baseline is clear. A cheaper model
that fails often can be more expensive at the product level.
