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

### 1. How does RRF merge keyword and vector results without score calibration?

**Answer:** Reciprocal rank fusion assigns each candidate a score based on its
rank in each result list — 1 / (k + rank) — and sums across lists, so it needs
no score calibration and is robust to lists of different scales. That matters
because keyword and vector scores are not comparable. RRF only needs the
rankings, which is why it is the default for hybrid fusion; weighted blending
requires tuning weights that break when either side changes.

### 2. How do you tune rank thresholds for hybrid search?

**Answer:** Set a minimum score or rank cutoff so weak candidates never reach
the model, and tune it against labeled retrieval evaluation rather than
intuition. The threshold interacts with fusion: a too-low cutoff lets noise
through, a too-high one drops relevant chunks. Track precision and recall at
the cutoff, and re-tune whenever the corpus, index, or fusion method changes.
The goal is a bounded candidate set for the reranker or prompt stage.

### 3. How do you evaluate whether hybrid search is worth the added complexity?

**Answer:** Compare hybrid against each single method on the same labeled
question set, measuring recall at k and end-to-end answer quality. Hybrid
should win on queries with exact identifiers and terms that embeddings miss,
and on paraphrases that keyword search misses — if your real traffic does not
contain both, the extra index and fusion logic may not pay for itself. Measure
on real user queries, since synthetic sets overstate the benefit.

### 4. How do you keep hybrid search fast when querying two indexes?

**Answer:** The two retrievals run in parallel, so the combined latency is
roughly the slower one; the levers are index-side. Keep both indexes tight with
the same metadata filters, use approximate vector search with a bounded
candidate set, and limit keyword hits. Fusion is cheap compared to retrieval,
so focus optimization on the slower stage and on p99 rather than the mean.

### 5. Hybrid search versus pure vector search — which do you pick?

**Answer:** Default to hybrid. Pure vector search loses on exact identifiers,
acronyms, product codes, error strings, and rare terms that embeddings smooth
over. Keyword search alone misses paraphrase and semantic overlap. A BM25 plus
vector blend with a reranker on top handles both cases and is usually worth
the extra latency.

The one time pure vector wins is short, highly semantic queries over clean
prose. Most real corpora are not that.
