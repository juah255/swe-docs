# Embeddings

**Embedding**: a numeric representation of text used for semantic search,
clustering, deduplication, and recommendations.

## How Embeddings Work

- An embedding maps text to a vector of numbers in a high-dimensional space.
- Similar text maps to nearby vectors, so semantic closeness becomes distance
  in the space.
- Distance is usually measured with cosine similarity, where higher similarity
  means closer meaning.
- Embeddings are produced by models trained so that related text lands close
  together and unrelated text lands far apart.

## When To Use Embeddings

- Search and retrieval over a corpus.
- Clustering and topic grouping.
- Deduplication of near-identical text.
- Routing queries to the right model, prompt, or workflow.
- Recommendation by similarity.

## Why Embeddings Over Generation

- Cheap and fast relative to generation for the same text.
- Deterministic: the same input produces the same vector, and the result does
  not depend on sampling.
- Cacheable: a text only needs embedding once, then the vector is reused.
- Stable: similarity scores shift less than generated text across runs.

## Choosing Embedding Models

- Dimensionality is a trade-off: higher dimensions hold more nuance but cost
  more to store and search.
- Pick a model whose language support and domain fit the corpus.
- Evaluate retrieval quality on your own data rather than trusting leaderboards.
- See [Embedding Models](../knowledge-retrieval/embedding-models.md) for
  choosing and comparing embedding models.

## Mid/Senior Interview Questions and Answers

### 1. When should you use embeddings instead of generation?

**Answer:** Embeddings are for similarity: search, clustering, deduplication,
routing, and recommendations. They are cheap, fast, deterministic, and easy
to cache. Use them when you need to find or compare, not when you need to
produce text or reason.

A common mistake is calling a generation model to classify or match when an
embedding plus a distance threshold — or a small classifier on top of
embeddings — would be faster, cheaper, and more stable across model updates.

### 2. How do you choose an embedding model?

**Answer:** Pick by evaluating retrieval quality on your own data, not by
leaderboard scores: run a sample of real queries against candidate models and
measure recall on the set you actually care about. Match the model's language
and domain support to your corpus, and treat dimensionality as a cost
trade-off — more dimensions hold more nuance but cost more to store and search.
Prefer models you can pin and re-run offline so changes are auditable.

### 3. What similarity metric do you pick, and when does it matter?

**Answer:** Cosine similarity is the default because it is length-invariant and
cheap, and most embeddings are trained to be compared that way. Euclidean
distance behaves differently when vector magnitudes carry meaning, which is
rarely the case for normalized embeddings. Choose one metric per index, tune
the threshold on your data, and keep it consistent across the pipeline so
scores are comparable.

### 4. How do you cache embeddings and keep them fresh?

**Answer:** Cache the vector keyed by normalized text, since the same text
embeds once and is reused forever — that is where most of the cost savings
come from. Store a model version with each vector so mixed versions are
detectable, and refresh the cache when the model version changes or content
updates. Invalidate on re-embed only; do not re-run the embedding model on
every query.

### 5. When do embeddings fail, and what do you fall back to?

**Answer:** Embeddings fail when semantic similarity does not match what users
need — exact matches, code syntax, acronyms, or very short strings — or when
the domain vocabulary is missing from the training data. Diagnose by
inspection: check whether nearest neighbors are actually related before adding
retrieval complexity. Fall back to lexical search, hybrid search, or a
dedicated classifier when the similarity signal is too weak.
