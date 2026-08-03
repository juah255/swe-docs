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

### 3. How do you keep the model grounded in the retrieved context?

**Answer:** Constrain generation to the retrieved evidence: instruct the model
to answer only from context, require citations to specific retrieved chunks,
and add an explicit "not found" path when the evidence is missing. Grounding
is not a prompt-only fix — enforce it by filtering what reaches the model, by
validating that cited chunks exist and match, and by logging the retrieval IDs
with each answer. If the model can cite passages that were not retrieved,
grounding has failed.

### 4. How do you keep the index fresh without rebuilding everything?

**Answer:** Track document identity and content hashes, then re-embed only what
changed. Deletes and permission changes need first-class handling: stale
vectors leak information. Embedding model upgrades force a full re-index, so
version the model alongside the vectors and keep both live during migration.

Freshness SLAs should be explicit per source. A pricing doc probably needs
minutes, a policy PDF can tolerate a day.

### 5. RAG versus a long context window — how do you decide?

**Answer:** Long context wins when the relevant material is bounded and known
in advance — a handful of documents, a session transcript, a single spec. RAG
wins when the corpus is large, changes often, or is permission-scoped, because
you cannot stuff a million documents into a prompt and the retrieval step also
enforces access control.

The cost comparison matters too: long context charges you per token on every
request, while RAG pays for indexing plus a smaller prompt per query. In
practice, measure whether the retrieved context actually improves answer
quality over a long-context baseline on your eval set before committing to
either.

See [RAG Evaluation](../evaluation/rag-evaluation.md) for how to measure the
pipeline.
