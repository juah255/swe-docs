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

### 5. When should you use embeddings instead of generation?

**Answer:** Embeddings are for similarity: search, clustering, deduplication,
routing, and recommendations. They are cheap, fast, deterministic, and easy
to cache. Use them when you need to find or compare, not when you need to
produce text or reason.

A common mistake is calling a generation model to classify or match when an
embedding plus a distance threshold — or a small classifier on top of
embeddings — would be faster, cheaper, and more stable across model updates.
