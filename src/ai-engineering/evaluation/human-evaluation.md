# Human Evaluation

- **Human review**: useful for subjective quality, tone, reasoning, and safety.

- Use when quality is subjective, or when safety and tone matter.
- Cover edge cases that rule-based checks miss.
- Use structured rubrics and labeled examples to keep reviews consistent.
- Sample a slice of traffic rather than reviewing everything.
- Track inter-annotator agreement to detect ambiguous rubrics.
- Account for the cost and latency of human review.
- Keep a small human-reviewed slice even when automated scoring is used.

## Mid/Senior Interview Questions and Answers

### 1. When is human evaluation necessary instead of automated scoring?

**Answer:** When quality is subjective — tone, persuasion, reasoning quality,
safety judgment — and when the cost of being wrong is high enough that a
heuristic or LLM judge is not trustworthy. Human review also covers edge cases
that rule-based checks miss by construction. Use humans where the judgment is
human; use automation everywhere else, because humans are slow and expensive
and do not scale to every request.

### 2. How do you design rubrics that keep annotators consistent?

**Answer:** Write a rubric with concrete, example-anchored levels per dimension
— "2 means the answer cites evidence but misuses it," with an example — rather
than vague Likert anchors. Calibrate on labeled examples, review disagreements
in batch, and measure inter-annotator agreement (Kappa) on a held-out slice.
Low agreement means the rubric, not the annotators, is the problem, and you
fix it before trusting any aggregate score.

### 3. How do you sample traffic for human evaluation?

**Answer:** Sample deliberately, not uniformly: oversample edge cases, new
prompt types, and slices that automated checks flag as risky, while keeping a
representative random slice so you can measure the base rate. Sample per
segment so rare categories are not drowned out, and rotate items across
annotators to avoid rater bias. Size the sample to the question you are trying
to answer, not to a vanity number.

### 4. How do you keep human evaluation affordable as volume grows?

**Answer:** Treat humans as the judgment layer, not the throughput layer: route
only what automation cannot score confidently to humans, and have the LLM
judge draft an assessment the human corrects rather than writes from scratch.
Batch low-risk reviews, and budget a fixed human slice for measurement so
automated scores stay calibrated. Cost scales with what you review, so
optimize the routing, not the workforce.

### 5. How do you combine human and automated evaluation?

**Answer:** Use automated scoring as the always-on gate and a human-reviewed
slice as the calibration set that keeps it honest. Compare automated scores to
human scores on the shared slice, and investigate systematic divergence — that
is how you find where the LLM judge or heuristic is gaming. Escalate
disagreements or low-confidence cases to humans, and let the human-labeled
slice grow your eval dataset over time.
