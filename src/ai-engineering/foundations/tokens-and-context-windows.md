# Tokens and Context Windows

Models process text as tokens: text is tokenized into pieces, and cost,
latency, and limits are all measured in tokens. A token is usually a short
word, a word fragment, or a single character, depending on how the tokenizer
splits the input.

## Tokenization

- Tokenizers split text into subword pieces using a learned vocabulary.
- Token counts differ by language and by format. Whitespace, punctuation, and
  rare words consume more tokens per character than common words.
- Different providers use different tokenizers, so the same text can count
  differently across models. Measure token usage per model, not by a shared
  approximation.
- Token counts drive both billing and the effective limit on what fits in a
  single request.

## Context Window

A context window is the maximum number of input and output tokens a model can
handle in one request.

- Input and output share the same budget, so a long prompt leaves less room
  for the response.
- Filling the window is not free: cost, latency, and attention quality all
  degrade as the window fills.
- Prefer targeted retrieval and summarization over "stuff everything in."
  See [LLM Fundamentals](llm-fundamentals.md) and the Q&A below.

## Sampling Parameters

Temperature and top-p control how the model samples the next token rather than
how correct it is. They tune consistency, not quality.

- **Temperature**: controls randomness. Lower values are better for consistent
  tasks; higher values are better for creative generation.
- **Top-p**: limits sampling to the most likely token candidates.

See [What is AI Engineering?](what-is-ai-engineering.md) for how sampling fits
into the broader field.

## Mid/Senior Interview Questions and Answers

### 1. What are the trade-offs of a larger context window?

**Answer:** Larger context lets you skip aggressive retrieval, but it costs
more per token, increases latency, and often degrades quality — models attend
unevenly across long inputs and get distracted by irrelevant content. "Just
stuff everything in" is rarely the right answer.

Prefer targeted retrieval, deduplication, and summarization. Use long context
for tasks that genuinely require cross-document reasoning, and measure whether
quality actually improves versus a smaller, well-curated context.

### 2. How do you estimate token counts and cost before sending a request?

**Answer:** Estimate tokens with the provider's tokenizer for the actual model,
since counts differ across tokenizers, and multiply input plus a reserved
output budget by the per-token price. Measure real usage on production traffic
instead of trusting rough character counts, which drift badly for code, JSON,
and non-English text. Build the estimate into a pre-request budget check so an
oversized prompt fails fast rather than silently exceeding limits.

### 3. When do you reach for more context window versus retrieval?

**Answer:** Use retrieval when the corpus is larger than the window or only a
subset is relevant, and reserve long context for tasks that genuinely need
cross-document reasoning. The cutoff is economic as much as technical: long
context costs more per token and degrades attention, so stuffing everything in
is rarely cheaper than a targeted retrieval step. Decide by measuring answer
quality and cost on both approaches.

### 4. How do long contexts degrade quality, and how do you compensate?

**Answer:** Long contexts degrade quality because attention spreads across more
tokens and irrelevant content dilutes the signal, so the model can miss the
most important evidence. Compensate by ordering critical context first,
deduplicating, and summarizing filler, and evaluate on your real distribution
of prompt lengths. When quality falls off at the tail, treat it as a retrieval
or pruning problem, not a reason to buy a bigger window.

### 5. How do you handle output token limits when the response is too long?

**Answer:** Split the work when the expected output exceeds the output budget:
produce section-by-section generation, summaries, or chunks and concatenate,
or ask the model to draft then trim. Prefer a larger-capable model only when
the task genuinely needs one long, coherent response, since more output tokens
also mean more latency and cost. Detect and surface max_tokens truncation
rather than silently treating it as a complete answer.
