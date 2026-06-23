# Retrieval-Augmented Generation

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
- **Metadata**: store source, owner, permissions, timestamps, document type, and
  section titles.
- **Retrieval depth**: retrieve enough context to answer, but not so much that
  irrelevant text distracts the model.
- **Reranking**: improves result order by scoring retrieved chunks against the
  query more carefully.
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
