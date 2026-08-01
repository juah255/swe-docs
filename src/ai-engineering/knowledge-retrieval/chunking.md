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
