# Re-ranking

- **Reranking**: improves result order by scoring retrieved chunks against the
  query more carefully.

## How Re-ranking Works

- Embedding similarity is a cheap approximation; rerankers (cross-encoders)
  score each candidate against the query directly, so they are more accurate.
- Run reranking as a stage after retrieval and before prompt assembly, over a
  small candidate set (for example, top 20 to 100).

## Why Rerank

- It improves precision at low cost because the expensive scoring runs only on
  the small retrieved set, not the whole corpus.
- It fixes noisy ordering from embedding similarity and hybrid search merges.

## Latency and Cost

- Cross-encoders are slower and more expensive per query than embedding
  similarity; keep the candidate set small.
- Batch the candidate scoring in one model call where possible.
- Consider skipping reranking when retrieval recall is already high and
  latency is the binding constraint.

## Fitting In

- Add reranking between retrieval and prompt assembly in the RAG pipeline.
- Evaluate precision at k with and without reranking to justify the cost.

See [RAG](rag.md) for the retrieval pipeline and
[Hybrid Search](hybrid-search.md) for the retrieval stage before reranking.
