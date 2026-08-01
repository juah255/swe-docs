# Hybrid Search

- **Hybrid search**: combines keyword search and vector search.

## Why Hybrid

- Keyword search (BM25) matches exact terms; vector search matches meaning.
  They fail in complementary ways.
- Exact identifiers, product codes, acronyms, error strings, and rare terms
  are usually lost by embeddings, which smooth over surface forms.
- Paraphrases and semantic overlap are missed by keyword search, which cannot
  see meaning beyond the literal tokens.
- Hybrid search covers both, with the other method as a safety net.

## Fusion Methods

- Run keyword and vector retrieval in parallel and merge the results.
- **Reciprocal rank fusion (RRF)**: score each candidate by the sum of
  1 / (k + rank) across result lists; it needs no score calibration.
- Weighted score blending works too, but keyword and vector scores are not
  comparable, so calibration is fragile.
- Merge rankings before re-ranking so both signals feed the final ordering.

## Rank Thresholds

- Set a minimum score or rank cutoff so weak candidates do not reach the model.
- Tune thresholds against labeled retrieval evaluation, not intuition.

## Mid/Senior Interview Questions and Answers

### 5. Hybrid search versus pure vector search — which do you pick?

**Answer:** Default to hybrid. Pure vector search loses on exact identifiers,
acronyms, product codes, error strings, and rare terms that embeddings smooth
over. Keyword search alone misses paraphrase and semantic overlap. A BM25 plus
vector blend with a reranker on top handles both cases and is usually worth
the extra latency.

The one time pure vector wins is short, highly semantic queries over clean
prose. Most real corpora are not that.
