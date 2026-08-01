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

## Mid/Senior Interview Questions and Answers

### 1. How do you choose between Pinecone, Weaviate, pgvector, Qdrant, and Milvus?

**Answer:** Start with the operational question, not the benchmark. If Postgres
is already your source of truth and the corpus fits comfortably in memory,
`pgvector` avoids a second system, keeps transactions honest, and lets you
filter with real SQL. Pinecone wins when you want a managed service and do not
want to run infrastructure. Qdrant and Weaviate are strong self-hosted options
with good filtering; Milvus is aimed at very large scale and heavier ops.

The wrong reason to pick a dedicated vector DB is "it is faster in a blog
post." The right reasons are scale, filtering needs, and who is on call.

### 2. What actually drives sizing and scaling for a vector index?

**Answer:** Vector count, embedding dimensionality, index type, and required
recall dominate memory. HNSW keeps most of the graph in RAM, so a few hundred
million 1536-dim vectors gets expensive quickly. Query concurrency drives CPU
and shard count. Metadata cardinality affects filter performance more than
people expect.

Plan for re-embedding cost too. A model swap means rebuilding the whole index,
often with both versions live during cutover.

### 3. When do you not need a dedicated vector database?

**Answer:** When the corpus is small (say, under a few million vectors),
freshness needs are modest, and you already run Postgres, `pgvector` is almost
always enough. When the retrieval need is really keyword or structured lookup
in disguise, skip vectors entirely. Prototypes often do fine with SQLite plus
an in-process index; adding Pinecone on day one is premature.

The tell that you actually need a dedicated system is filter-heavy queries at
scale, high write throughput, or multi-tenant isolation requirements.

### 4. HNSW versus IVF — what are the trade-offs?

**Answer:** HNSW gives excellent recall and low query latency but uses more
memory and is expensive to build and update. IVF (with PQ or SQ quantization)
scales to much larger corpora on less RAM and supports faster bulk indexing,
at the cost of recall tuning through `nprobe`. HNSW is the default for most
RAG workloads under ~50M vectors; IVF-PQ starts making sense past that or when
memory is the binding constraint.

Neither is free. Both need recall benchmarks on your data, not vendor claims.

### 5. What are the common pitfalls with metadata filtering?

**Answer:** Pre-filter versus post-filter behavior varies by engine and can
silently wreck recall. Aggressive post-filtering on top-k returns fewer results
than expected; naive pre-filtering blows up latency on high-cardinality fields.
Permission filters must be enforced at the query layer, not in application code
after the fact, or you leak documents across tenants.

Index the filter fields the engine supports, and test filtered recall
explicitly. Unfiltered benchmarks lie about production behavior.
