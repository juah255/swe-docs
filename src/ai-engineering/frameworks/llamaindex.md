# LlamaIndex

- Useful for data ingestion, indexing, retrieval, and RAG over documents.
- Good fit for knowledge-base and document-heavy applications.
- Data connectors and loaders for many sources.
- Index structures for organizing and searching documents.
- Retrieval and query engines for answering over documents.
- Good fit for document-heavy RAG. See [RAG](../knowledge-retrieval/rag.md).

See the [Frameworks overview](index.md) for selection criteria.

## Mid/Senior Interview Questions and Answers

### 1. How do you decide between LlamaIndex, LangChain, and plain code for a RAG app?

**Answer:** Use LlamaIndex when the work is dominated by document ingestion,
indexing, and retrieval — data connectors, index structures, and query engines
are its core value, and you want them without wiring loaders and vector stores
by hand. Prefer LangChain when you need broader orchestration, chains, and tool
integrations beyond retrieval. Pick plain code when the pipeline is small and
stable enough that a framework is overhead — a few hundred lines of direct SDK
and a vector store client are easy to reason about, test, and replace.

### 2. What do data connectors give you, and when do you write your own ingestion?

**Answer:** Connectors normalize messy sources — PDFs, databases, web pages —
into a common document representation with text and metadata, saving you the
glue. Write your own when you need exact control: handling authentication and
permissions, preserving source structure, or cleaning content the connector
mangles. Your ingestion is also a pipeline with failure modes, so own the parts
that carry business logic and use connectors for the commodity extraction.

### 3. How do index structures in LlamaIndex affect retrieval behavior?

**Answer:** Index choice changes what gets retrieved and how. A vector store
index retrieves by embedding similarity; a summary index concatenates and
abstracts; tree and keyword indexes match by structure or terms. Match the
index to the retrieval need — semantic search wants vectors, structured or
keyed lookups want metadata filters or keyword indexing. Also record the
chunking and embedding choices, because both interact with the index: an index
is only as good as the chunks it holds.

### 4. How do query engines work, and what does the query pipeline do?

**Answer:** A query engine turns a natural-language question into a retrieval
plus generation step: embed the query, look up the index, optionally filter or
rerank, and compose the prompt with the retrieved context. The pipeline
abstraction lets you insert transforms — query rewriting, hybrid search,
reranking, response synthesis — between stages. Keep the pipeline inspectable:
log the retrieved chunk IDs, scores, and the final prompt so a bad answer can
be traced to retrieval or generation.

### 5. When would you drop LlamaIndex and use plain code for document RAG?

**Answer:** When the framework's abstractions cost more than they save. A stable
pipeline with a single source type, fixed chunking, and one vector store may
be clearer as direct calls to an SDK and a vector store client — especially
when you need tight control over permissions, token cost, retries, and
observability. The trade-off is that you reimplement connectors and plumbing.
Reach for the framework for breadth of sources and fast iteration; own the code
when behavior must be fully explicit.
