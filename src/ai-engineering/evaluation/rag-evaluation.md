# RAG Evaluation

Evaluate retrieval and generation separately.

- Did retrieval find the right documents?
- Did the model use the retrieved evidence correctly?
- Did the answer cite the right source?
- Did the model say it does not know when evidence was missing?

## Retrieval Metrics

- Recall at k.
- MRR.
- Precision at k.

## Generation Metrics

- Faithfulness or groundedness.
- Answer correctness.
- Citation accuracy.

## Mid/Senior Interview Questions and Answers

### 3. How do you evaluate a RAG pipeline end-to-end?

**Answer:** Evaluate retrieval and generation as separate stages. For retrieval,
measure recall at k and MRR against a labeled set of real questions with known
relevant chunks. For generation, measure faithfulness (does the answer stay
within retrieved evidence), answer correctness, and citation accuracy.

End-to-end scores hide where the pipeline is broken. If recall at k is low, no
prompt engineering will save the answer.

See [RAG](../knowledge-retrieval/rag.md) for pipeline design.
