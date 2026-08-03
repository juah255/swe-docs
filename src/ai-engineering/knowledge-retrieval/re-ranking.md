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

## Mid/Senior Interview Questions and Answers

### 1. Why do rerankers improve over embedding similarity?

**Answer:** Embedding similarity compresses the query and candidate into fixed
vectors, which loses fine-grained lexical and contextual interaction.
Cross-encoders take the query and candidate as paired text and score the pair
together, so the model can attend to exact matches, negation, and term
significance that bi-encoders smooth over. That makes ranking more accurate,
which is why a reranker on a small candidate set often fixes the noisy ordering
that pure similarity produces.

### 2. How do cross-encoders differ from bi-encoders?

**Answer:** Bi-encoders encode query and document independently into vectors,
so the corpus can be pre-indexed and searched fast, but the interaction between
query and document is only a dot product. Cross-encoders run query and document
together through the model, which is far more expressive but too slow to scan a
whole corpus. That is why the standard pattern is fast bi-encoder retrieval
over the corpus, then a cross-encoder reranker over a small candidate set.

### 3. How do you control the cost and latency of reranking?

**Answer:** The reranker only scores the small retrieved set, so the main lever
is the candidate set size — top 20 to 100 is typical. Batch the scoring in a
single model call where possible, and pick a reranker model sized to your
latency budget. Monitor p99 and token cost, because cross-encoders are slower
and more expensive per query than embedding similarity. If latency is the
binding constraint and recall is already high, consider skipping the stage.

### 4. When is reranking unnecessary?

**Answer:** When retrieval recall is already high and precision is fine — for
example small, curated corpora or domains where embedding similarity already
orders results well. Reranking adds latency and cost, so it is only worth it
when the ordering materially affects answer quality. Also skip it when the
candidate set is tiny or the query type is simple, where the gain is
negligible. Measure the impact before assuming the stage is required.

### 5. How do you evaluate whether reranking improves your pipeline?

**Answer:** Measure precision at k (and downstream answer quality) with and
without the reranker on a labeled question set. The right comparison is
end-to-end: does the top-k order actually put the ground-truth chunk first?
Track recall before reranking and precision after, since reranking reorders
rather than expands the candidate set. If the metric does not move, drop the
stage — the cost is only justified by measured improvement.
