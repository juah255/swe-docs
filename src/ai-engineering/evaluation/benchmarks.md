# Benchmarks

- Public benchmarks measure general capability but have limitations.
- Test-set contamination, saturation, and mismatch with your distribution.
- Build private benchmarks from your own tasks.
- Track benchmark and production behavior separately.
- Use benchmarks for model selection; use custom evals for release gates.

## Mid/Senior Interview Questions and Answers

### 1. What are the limits of public benchmarks for choosing a model?

**Answer:** Public benchmarks suffer from test-set contamination — the model may
have trained on the data — and saturation, where top models are so close that
differences are noise. They also measure general capability, not your
distribution. Use them for a shortlist, but never as the sole basis for a
production decision; a benchmark you cannot reproduce on your own data is not
evidence.

### 2. When do you build a private benchmark instead of using a public one?

**Answer:** As soon as you need to compare models or versions on your own
workload — your prompts, your data, your expected outputs — because public
scores do not predict that. A private benchmark is a fixed, labeled set of real
tasks you never let the model train on, and you refresh it from production
traffic. Start small; a hundred representative examples beat ten thousand
generic ones for predicting your behavior.

### 3. How do you keep benchmark behavior and production behavior separate?

**Answer:** Report them as different signals: benchmarks measure capability on a
fixed set, production measures task success on live traffic, and the two drift
apart as your distribution changes. Run both, and when they disagree, trust
production and investigate why. Let benchmark scores inform model selection and
monitoring baselines, but keep release gates on your own eval set so a
benchmark score cannot override a production regression.

### 4. How do you use benchmarks for model selection without being misled?

**Answer:** Filter by contamination risk, then rank by how close each benchmark
is to your task, not by aggregate leaderboard position. Confirm the shortlist
on your private eval set with your own prompts, and weigh non-score factors —
latency, cost, tool-calling reliability — that benchmarks ignore. A model
selected on two points of benchmark margin will rarely justify a 30% cost
increase.

### 5. When does a benchmark actively mislead you?

**Answer:** When its data is contaminated or stale, when it is saturated so
everyone scores near ceiling, or when it measures a skill you do not use while
ignoring the one you do — for example, multiple-choice accuracy over
tool-calling correctness. Benchmarks also mislead when the eval harness differs
from your call pattern, so prompt and output formats diverge. When a benchmark
cannot reproduce your observed failures, stop treating it as a signal.
