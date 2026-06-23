# Vector Databases

Vector databases store embeddings and support similarity search.

## Core Concepts

- **Embedding**: numeric representation of text, image, audio, or another input.
- **Similarity search**: finds semantically close content.
- **Metadata filtering**: restricts search by tenant, permission, date, product,
  language, or document type.
- **Hybrid search**: combines keyword search and vector search.
- **Indexing strategy**: affects recall, speed, and cost.
- **Re-embedding**: required when the embedding model or source content changes.

## Common Options

- Postgres with `pgvector`.
- Pinecone.
- Weaviate.
- Milvus.
- Qdrant.
- Elasticsearch.
- OpenSearch.
- Redis vector search.

## When To Use

Use a vector database when semantic retrieval matters. Use normal SQL or keyword
search when exact filters, joins, or deterministic lookup are enough.

## Operational Notes

- Store source IDs and metadata with every vector.
- Use tenant and permission filters in retrieval queries.
- Track embedding model versions.
- Build re-indexing jobs for changed documents.
- Evaluate recall and answer quality, not only search latency.
