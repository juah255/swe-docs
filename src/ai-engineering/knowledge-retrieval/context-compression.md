# Context Compression

Context compression reduces the tokens sent to the model by shrinking or
trimming retrieved context before prompt assembly.

## Techniques

- **Deduplicate** overlapping chunks so the same passage is not included
  twice.
- **Drop irrelevant text** from chunks: keep the passages that match the
  query and discard the rest.
- **Summarize** retrieved passages into shorter forms while preserving the
  facts needed to answer.
- **Keep only high-scoring passages**: filter on retrieval or reranking scores.

## Trade-offs

- Aggressive compression lowers token cost and latency but risks losing the
  detail the model needs, hurting answer fidelity.
- Keep enough context to support grounding and citations; compressed summaries
  must still be traceable to their source.
- Summarization itself costs an inference call, so only use it when the saved
  tokens outweigh the added latency.

See [Cost Optimization](../production/cost-optimization.md) for controlling
token spend across the pipeline.

## Mid/Senior Interview Questions and Answers

### 1. How do you deduplicate and filter retrieved context?

**Answer:** Overlapping chunks from your chunking strategy produce duplicate
passages, so dedupe on normalized text or content hash before prompt assembly.
Filter on retrieval or reranking score, keeping only the passages that match
the query and dropping weak candidates. The goal is to keep each fact once,
in its most complete form, and to keep the prompt free of near-duplicates that
waste tokens and can bias the answer.

### 2. When do you summarize passages instead of dropping them?

**Answer:** Summarize when a passage is relevant but longer than needed, and
the facts it holds must survive in compressed form. Drop when the passage is
irrelevant or redundant. Summarization itself costs an inference call and can
lose detail, so only use it when the saved tokens outweigh the added latency
and fidelity risk. Keep summaries traceable to their source so answers can
still be grounded and cited.

### 3. What is the trade-off between token cost and answer fidelity?

**Answer:** Aggressive compression lowers cost and latency but risks dropping
the detail the model needs, which shows up as missing or hallucinated facts.
Keeping more context costs tokens but gives the model grounding and supports
citations. The balance point depends on the task: fact-retrieval questions
tolerate heavy compression, while reasoning over dense or contradictory text
needs the full passages. Measure answer quality against tokens saved instead of
assuming smaller is better.

### 4. When does compression hurt recall?

**Answer:** Compression hurts recall when it removes the passage containing the
answer — for example, aggressive score thresholds that drop a relevant but
low-scoring chunk, or summarization that loses the specific fact the question
asks about. Deduplication that keeps the wrong copy of a passage can also lose
key detail. The risk grows with compression aggressiveness, so validate on a
labeled question set and favor keeping more context when the cost is
acceptable.

### 5. How do you measure quality after compression?

**Answer:** Evaluate end to end: on a labeled question set, compare answer
correctness, groundedness, and citation accuracy with and without compression,
and track tokens per query to show what was saved. Watch for the recall of
specific facts, since aggregate correctness hides failures on rare details.
Treat compression as a pipeline stage with its own metrics, and re-run the
evaluation whenever the retrieval or compression logic changes.
