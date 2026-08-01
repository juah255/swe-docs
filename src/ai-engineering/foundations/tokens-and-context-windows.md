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

### 4. What are the trade-offs of a larger context window?

**Answer:** Larger context lets you skip aggressive retrieval, but it costs
more per token, increases latency, and often degrades quality — models attend
unevenly across long inputs and get distracted by irrelevant content. "Just
stuff everything in" is rarely the right answer.

Prefer targeted retrieval, deduplication, and summarization. Use long context
for tasks that genuinely require cross-document reasoning, and measure whether
quality actually improves versus a smaller, well-curated context.
