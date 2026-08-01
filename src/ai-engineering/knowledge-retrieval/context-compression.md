# Context Compression

Context compression reduces the tokens sent to the model by shrinking or
trimming retrieved context before prompt assembly.

## Techniques

- **Deduplicate** overlapping chunks so the same passage is not included
  twice.
- **Drop irrelevant text** from chunks: keep the passages that match the
  query and discard the rest.
- **Summarize** retrieved passages into shorter forms while preserving the
  facts needed to answer.
- **Keep only high-scoring passages**: filter on retrieval or reranking scores.

## Trade-offs

- Aggressive compression lowers token cost and latency but risks losing the
  detail the model needs, hurting answer fidelity.
- Keep enough context to support grounding and citations; compressed summaries
  must still be traceable to their source.
- Summarization itself costs an inference call, so only use it when the saved
  tokens outweigh the added latency.

See [Cost Optimization](../production/cost-optimization.md) for controlling
token spend across the pipeline.
