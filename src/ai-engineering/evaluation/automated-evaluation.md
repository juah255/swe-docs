# Automated Evaluation

- **Automated scoring**: useful for format, exact matching, retrieval recall,
  groundedness, and classification accuracy.

- Rule-based checks: exact match, schema validity, containment.
- LLM-as-judge with explicit rubrics and examples.
- Score each dimension separately, then alert on per-dimension drops.
- Run the eval on every prompt, model, or retrieval change.

## Mid/Senior Interview Questions and Answers

### 1. How do you design an eval that actually catches regressions?

**Answer:** Anchor it to real failures, not synthetic prompts. Every incident,
bug report, or "this answer was wrong" ticket becomes a permanent test case
with a scored expected behavior. That way the eval grows toward the shape of
your actual product.

Score each dimension separately — task success, grounding, format, tone — and
alert on per-dimension drops. A single aggregate score hides the regression
that matters. Run the eval on every prompt change, model swap, and retrieval
change, not only on releases.

### 2. When does LLM-as-judge lie to you?

**Answer:** When the judge shares the same biases as the model under test,
when the rubric is vague, and when the judge sees the answer without the
ground truth or source documents. Judges also inflate scores for verbose,
confident-sounding answers regardless of correctness.

Mitigate by using a stronger model as judge, providing explicit rubrics with
examples, showing the judge the expected answer and evidence, and calibrating
against human labels on a sample. Treat judge scores as a signal, not truth —
and always keep a small human-reviewed slice.

### 3. What's the difference between offline and online eval, and when does each fail?

**Answer:** Offline eval runs against a fixed dataset and catches regressions
before deploy. It fails when the dataset drifts from real traffic — you pass
CI and still ship a broken feature. Online eval measures live behavior via
feedback signals, thumbs, and outcome metrics. It fails on delay, sparsity,
and self-selection bias in who bothers to give feedback.

You need both. Offline for fast iteration and gating. Online for the truth
about what users actually experience. Feed online failures back into the
offline golden set so the loop closes.

### 4. How do you build a golden set that stays useful?

**Answer:** Seed it from production traffic, not from what you imagine users
will ask. Sample across intents, difficulty, and user segments. Every failure
found in prod gets added with the correct expected behavior labeled by
someone who understands the domain.

Version it. Review it quarterly for stale examples where the "correct"
answer has changed. Keep it small enough that engineers actually run it — a
thousand carefully labeled examples beat ten thousand noisy ones.

### 5. Why aren't unit tests enough for LLM apps?

**Answer:** Unit tests confirm a function does what it says. They cannot tell
you whether "summarize this ticket" produced a summary a human would accept.
LLM outputs are non-deterministic, context-sensitive, and fail in ways string
matching cannot detect — subtly wrong facts, missing nuance, wrong tone.

Keep unit tests for the deterministic pieces: prompt assembly, schema
validation, tool routing, parser behavior. Layer eval on top for the model's
actual output quality. Both matter — unit tests catch integration breaks,
evals catch quality regressions.
