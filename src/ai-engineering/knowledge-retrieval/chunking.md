# Chunking

Chunking splits source documents into smaller pieces before they are embedded
and stored. Retrieval happens at the chunk level, so chunk boundaries determine
what context the retriever can surface.

## Chunk Size and Overlap

- **Smaller chunks** are more precise and match a narrower intent, but they
  lose surrounding context and can split a concept across boundaries.
- **Larger chunks** preserve more context and reduce duplicate hits, but they
  add noise and tokens, and semantic similarity to a short query gets diluted.
- **Overlap** between adjacent chunks helps when a sentence or idea spans a
  boundary; too much overlap inflates index size and duplicate retrieval.
- Tune chunk size to your corpus: dense technical text and conversation
  transcripts behave differently.

## Structure-Aware Chunking

- Split by headings, sections, and paragraphs instead of fixed character
  counts so each chunk is a coherent unit.
- Preserve section titles in the chunk so the model can place the content.
- Respect list, table, and code-block boundaries rather than cutting through
  them.

## Semantic Chunking

- Group sentences into chunks based on meaning or topic shifts rather than
  fixed lengths.
- Semantic chunking produces fewer, more coherent chunks at the cost of an
  extra inference or embedding step at index time.

## Evaluating Chunking

- Evaluate chunking through retrieval recall: on a labeled set of questions,
  does the right content get retrieved within the top-k?
- Changing the chunking strategy changes the index, so re-run retrieval
  evaluation after every change.

See [RAG](rag.md) for where chunking fits in the retrieval pipeline.

## Mid/Senior Interview Questions and Answers

### 1. How do you choose chunk size and overlap for a given corpus?

**Answer:** There is no universal size; tune to the corpus and the questions
you will ask. Dense technical text and long-form prose tolerate larger chunks,
while conversation transcripts and code want smaller ones, and overlap should
cover the average span of a sentence or idea so boundaries do not split
meaning. Use a labeled question set and compare retrieval recall across a few
chunk sizes rather than guessing. Expect different corpora to land on
different settings — the tuning process is the transferable part.

### 2. When do you prefer structure-aware chunking over fixed-size splitting?

**Answer:** When documents have meaningful structure — headings, sections,
paragraphs, lists, tables, code blocks — split on those boundaries instead of
character counts so each chunk is a coherent unit. Fixed-size splitting cuts
through structure, which loses context and splits concepts. Preserve the
section title in the chunk so the model can place the content. For
unstructured text with no stable boundaries, fixed-size or semantic chunking
may be the only options.

### 3. How do you evaluate a chunking strategy?

**Answer:** Evaluate through retrieval recall on a labeled set of questions:
does the chunk containing the answer surface within the top-k? Compare
candidates — different sizes, overlap, and split strategies — on the same
index and question set, and treat recall as the primary metric. Because
changing chunking rebuilds the index, re-run evaluation after every change.
Quality is measured at retrieval, not by how tidy the chunks look.

### 4. How do you chunk long documents without losing context?

**Answer:** For long documents, chunk in a way that preserves hierarchy: keep
section context in each chunk (via titles or parent sections), and consider
hierarchical indexing where you retrieve at one granularity and expand to
context at another. Fixed-size chunking of a long document loses
document-level structure and can split the key passage. Balance chunk size so
each unit is coherent and self-contained enough to be retrieved and answer on
its own.

### 5. How does chunking affect context and token cost?

**Answer:** Larger chunks mean more tokens per retrieved result, so a fixed
top-k consumes more context window and costs more per query, and noise grows
with token count. Smaller chunks reduce per-result cost but may require
retrieving more of them to cover the answer, which can end up costing more
while losing context. Chunking sets the unit of retrieval, so it directly
determines the token budget per query: measure tokens and recall together, not
in isolation.
