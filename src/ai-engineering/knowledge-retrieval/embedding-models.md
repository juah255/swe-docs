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
