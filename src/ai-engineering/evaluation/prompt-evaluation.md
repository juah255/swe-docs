# Prompt Evaluation

- Evaluate prompt versions against a fixed dataset before shipping.
- Track the prompt version on every run.
- Treat prompt changes as code changes with regression tests.
- Compare two prompts or models on the same dataset.
- Score pass/fail per example, then roll up by dimension.

See [Prompt Engineering](../foundations/prompt-engineering.md) for how to
write the prompts being evaluated.

## Mid/Senior Interview Questions and Answers

### 1. How do you evaluate one prompt version against another?

**Answer:** Run both prompts on the same fixed dataset with the same inputs,
same model, and same temperature, then score pass/fail per example. Read the
individual diffs, not just the aggregate: a prompt that wins overall may fail
a specific slice you care about. Track the prompt version on every production
run so you can later reproduce which version produced which result.

### 2. How do you build regression testing for prompts?

**Answer:** Maintain a golden dataset of real inputs with expected outcomes and
run it on every prompt change, the way you would unit tests on code. Score each
example pass/fail and diff the failures against the previous version so a
change that fixes one class of input cannot silently break another. Expand the
set from every production incident, and keep the runtime fast enough that the
suite runs on every pull request.

### 3. How do you A/B compare two prompts in production?

**Answer:** Split traffic deterministically by user or session so an individual
never bounces between variants, and log which variant served each request with
the prompt version attached. Measure outcome metrics, not just preference:
task success, latency, and error rates. Guard against confounds like time of
day and model rollout, and let the comparison run long enough to reach
statistical significance before shipping the winner.

### 4. How do you gate a prompt change on evaluation?

**Answer:** Make the eval the only way a change ships: the prompt version is a
code review artifact that must pass the regression suite and a canary before
rollout. Start at low traffic, watch outcome metrics and failure modes, and be
ready to roll back by flipping the version, not by editing text. The gate only
works if the eval set matches production distribution, so refresh it
continuously from real traffic.

### 5. How do you attribute a quality shift to the prompt and not something else?

**Answer:** Hold the environment constant — same model, same version, same
retrieval, same sampling, same data — and change only the prompt. When you
cannot, use an experiment design that isolates variables, such as a pinned
retrieval snapshot and a frozen model version. If shifts appear without a
prompt change, check model and data drift first: quality regressions are more
often upstream than in the prompt text.
