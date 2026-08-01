# RAG

Retrieval-augmented generation (`RAG`) retrieves relevant external content and
gives it to the model as context before generation. It is useful when answers
depend on private, current, or domain-specific information.

## Typical Flow

1. Load source documents.
2. Split documents into chunks.
3. Create embeddings for each chunk.
4. Store embeddings and metadata in a vector database.
5. Embed the user's query.
6. Retrieve similar chunks.
7. Optionally rerank or filter results.
8. Build a prompt using the retrieved context.
9. Generate an answer with citations or grounding.
10. Log the query, retrieved documents, and answer quality.

## Design Choices

- **Chunking**: chunks should preserve enough meaning without wasting context.
  (see [Chunking](chunking.md))
- **Metadata**: store source, owner, permissions, timestamps, document type, and
  section titles.
- **Retrieval depth**: retrieve enough context to answer, but not so much that
  irrelevant text distracts the model.
- **Reranking**: improves result order by scoring retrieved chunks against the
  query more carefully. (see [Re-ranking](re-ranking.md))
- **Grounding**: require the answer to stay within retrieved evidence.
- **Citations**: help users inspect the source and catch retrieval mistakes.

## Common Failures

- Poor source documents.
- Chunks that split important meaning.
- Missing metadata filters.
- Retrieved context is relevant but incomplete.
- Prompt allows unsupported claims.
- No evaluation dataset for real user questions.

## Production Checklist

- Enforce document permissions before retrieval results reach the model.
- Log retrieved document IDs and scores.
- Test with real user questions.
- Include "not found" behavior when evidence is missing.
- Re-index documents when source content or embedding models change.

## Mid/Senior Interview Questions and Answers

### 1. Why do RAG systems usually fail in production?

**Answer:** Most production failures are not model failures. They come from
retrieval quality: bad chunk boundaries, embeddings that do not match the query
distribution, missing metadata filters, and a lack of reranking. The model
happily answers from irrelevant context if you hand it any, so weak retrieval
looks like a hallucination problem.

Senior engineers instrument retrieval separately from generation and evaluate
recall on real user queries before they blame the model.

### 2. When is RAG the wrong answer?

**Answer:** RAG is the wrong tool when the task is not really a retrieval
problem. Structured lookups, aggregations, and permission-scoped reads belong
in SQL or an API call, not a vector index. Small, stable corpora fit better in
the prompt directly or in fine-tuning. Highly compositional reasoning over many
documents also breaks RAG because retrieval only surfaces top-k chunks.

If the answer requires computation, joins, or authoritative state, build a tool
call, not a retriever.

### 4. How do you keep the index fresh without rebuilding everything?

**Answer:** Track document identity and content hashes, then re-embed only what
changed. Deletes and permission changes need first-class handling: stale
vectors leak information. Embedding model upgrades force a full re-index, so
version the model alongside the vectors and keep both live during migration.

Freshness SLAs should be explicit per source. A pricing doc probably needs
minutes, a policy PDF can tolerate a day.
