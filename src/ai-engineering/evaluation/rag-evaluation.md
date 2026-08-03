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

### 1. How do you evaluate a RAG pipeline end-to-end?

**Answer:** Evaluate retrieval and generation as separate stages. For retrieval,
measure recall at k and MRR against a labeled set of real questions with known
relevant chunks. For generation, measure faithfulness (does the answer stay
within retrieved evidence), answer correctness, and citation accuracy.

End-to-end scores hide where the pipeline is broken. If recall at k is low, no
prompt engineering will save the answer.

### 2. How do you build the labeled evaluation set for retrieval?

**Answer:** Build it from real user questions with their known relevant chunks,
and sample from production traffic so you cover your actual distribution, not
just clean queries. Have annotators judge chunk relevance and the ground-truth
answer separately so the set supports both retrieval and generation metrics.
Refresh and version the set, because RAG quality depends on the corpus — when
the documents change, old labels rot.

### 3. How do you measure faithfulness and citation accuracy?

**Answer:** Faithfulness means the answer stays within the retrieved evidence —
verify claims against the source chunks, not the model's general knowledge.
Citation accuracy is stricter: each citation must actually support the claim it
is attached to, so annotate at the claim level. Watch the harder failure mode
where the answer is plausible but contradicts the evidence, which is easier to
miss than an obvious hallucination.

### 4. How do you test the "I don't know" behavior when evidence is missing?

**Answer:** Include queries with no relevant evidence in the eval set and assert
the model refuses, or answers from general knowledge while saying so, instead
of fabricating. Measure the refusal rate and the fabrication rate separately,
because a pipeline that always answers is not honest, it is hallucinating. This
is where the stages interact: if recall at k is low on these cases, the
generation model never got a chance to do the right thing.

### 5. How do you localize a RAG failure to retrieval or generation?

**Answer:** Run the pipeline twice — once with the real retriever and once with
gold documents injected — and compare the generation scores. If injecting gold
evidence fixes the answers, the failure is retrieval (recall or ranking); if it
does not, the failure is generation (prompt, instruction, or model). Apply the
same decomposition to bad production runs before changing the prompt, because
the most common waste is prompt-tuning a broken retriever.

See [RAG](../knowledge-retrieval/rag.md) for pipeline design.
