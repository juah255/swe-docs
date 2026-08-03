# Embedding Models

Embedding models convert text into vectors so that similar meaning maps to
nearby points in vector space. See [Embeddings](../foundations/embeddings.md)
for the underlying concepts.

## Choosing a Model

- **Dimensionality**: higher dimensions capture more nuance but cost more
  memory and compute per vector.
- **Language support**: confirm the model handles the languages and scripts in
  your corpus.
- **Domain fit**: a general model may underperform on code, legal, or medical
  text; benchmark candidates on your data.
- **Context limits**: some models embed only short passages, which interacts
  with your chunking strategy.
- **Cost and latency**: embedding volume drives indexing time and budget.

## Versioning

- Record the embedding model name and version alongside every vector.
- Upgrading the model produces vectors that are not comparable with the old
  ones, so mixing both spaces degrades recall.

## Re-embedding

- Re-embed a chunk when the source content changes or when the embedding model
  changes.
- A model upgrade forces a full re-index; run both versions live during
  migration and switch over when the new index is validated.

## Consistency

- Use the same embedding model for the index and the query, or distances are
  meaningless.
- If you change either side, change both and re-evaluate retrieval quality.

See [RAG](rag.md) for how embeddings feed retrieval, and
[Vector Databases](vector-databases.md) for storage.

## Mid/Senior Interview Questions and Answers

### 1. How do you choose an embedding model for your corpus?

**Answer:** Benchmark on your own data before committing. Check language and
script support, domain fit — a general model can underperform on code, legal,
or medical text — and context limits, which interact with your chunking.
Evaluate candidates on a labeled retrieval set using recall at k, not just on
claimed quality or leaderboard scores. Cost and latency of embedding volume
matter at scale, so rank acceptable models by both retrieval quality and
indexing budget.

### 2. How does dimensionality affect cost and quality?

**Answer:** Higher dimensions capture more nuance but cost more memory,
storage, and compute per vector, which matters at index scale and on every
query. Lower-dimension models are cheaper to store and search, and the quality
gap is often small because much of the signal is in a few dimensions. Choose
the smallest model that meets your recall target, and re-measure if you reduce
dimensions, since truncation or a different model changes the distance
distribution.

### 3. How do you handle embedding model versioning and upgrades?

**Answer:** Record the model name and version alongside every vector, because
upgrading produces vectors that are not comparable to the old ones — mixing
spaces degrades recall. Treat an upgrade as a full re-index with both versions
running live during migration, switching over only when the new index is
validated against your evaluation set. The metadata is what makes rollback
possible, so version the schema that stores it.

### 4. When do you re-embed your corpus?

**Answer:** Re-embed when the source content changes or when the embedding
model changes. Source edits only require re-embedding the affected chunks if
you track content hashes, but a model change forces a full re-index since old
and new vectors are incompatible. Re-embedding on every minor source change is
wasteful; define freshness per source — how stale the vectors can be before a
re-index is scheduled — and version the model so you know when the space
actually changed.

### 5. Why must query and document embeddings use the same model?

**Answer:** Distances are only meaningful inside a single embedding space. A
different model on the query side maps queries into a different space, so the
nearest neighbors are meaningless and recall collapses. If you change either
side, change both, and re-evaluate retrieval quality — including after a
provider switches the model behind an endpoint name, which is a silent version
change. Pin the model name and version explicitly in config for both sides.
