# MLOps and LLMOps

MLOps and LLMOps cover the lifecycle of models, prompts, datasets, evaluation,
deployment, monitoring, and governance.

## What To Version

- Prompt templates.
- Model names and versions.
- Model parameters.
- Tool schemas.
- Retrieval configuration.
- Embedding model versions.
- Evaluation datasets.
- Safety rules.

## Experiment Tracking

Track:

- Dataset used.
- Prompt version.
- Model and parameters.
- Evaluation results.
- Cost and latency.
- Failure cases.
- Reviewer notes.

## Governance

Production AI systems need clear ownership.

- Define who can change prompts, tools, models, and retrieval indexes.
- Keep audit logs for high-impact actions.
- Document data retention and privacy behavior.
- Review model/provider changes before production rollout.
- Keep human review paths for high-risk workflows.

## Continuous Improvement

Use production feedback to update evaluation data, improve prompts, tune
retrieval, and adjust routing. Do not rely on anecdotal examples alone.

## Mid/Senior Interview Questions and Answers

### 1. How does LLMOps actually differ from classical MLOps?

**Answer:** Classical MLOps centers on training pipelines, feature stores, and
model artifacts you own end to end. LLMOps mostly orchestrates a system around
a model you did not train: prompts, retrieval, tools, safety rules, and routing.
The unit of change is usually a prompt or config, not a retrained checkpoint,
so the release cadence is much higher and the failure modes are qualitative
rather than a metric moving a few points.

The practical consequence is that evaluation, versioning, and rollback have to
cover the whole system (prompt + model + retrieval + tools), and your
observability needs to include token cost, latency percentiles, and output
quality signals, not just accuracy.

### 2. How do you version prompts, models, and data together?

**Answer:** Treat every request as being served by a bundle: prompt version,
model name and version, retrieval index version, tool schema version, and
evaluation dataset version. Store that bundle as an immutable release artifact
with a single ID, and log that ID on every production trace. Prompts live in a
registry (git or a dedicated store) with content-addressed versions, models are
pinned to explicit provider versions (never `latest`), and eval datasets are
snapshotted with a hash.

The mistake to avoid is versioning each piece independently and then not being
able to reproduce a specific production response two weeks later because you no
longer know which combination was live.

### 3. How do you detect drift when there is no ground truth?

**Answer:** You lean on proxy signals because you rarely have labels in real
time. Track input distribution drift (topic mix, language, prompt length,
retrieval hit rate), output distribution drift (response length, refusal rate,
tool-call rate, structured-output parse-failure rate), and user behavior drift
(thumbs-down rate, retries, session abandonment, escalation to human). Run a
small LLM-as-judge or rubric-based eval on a sampled slice of production
traffic against a stable reference version.

None of these alone is proof, but a coordinated shift across several is a
strong signal. Alert on the composite, not on any single metric, or you will
drown in noise.

### 4. Walk through incident response for a bad LLM release.

**Answer:** First, stop the bleeding: flip the traffic flag back to the last
known-good bundle (prompt + model + retrieval + tools), not just the previous
container. Confirm the rollback by watching the same quality signals that
caught it — refusal rate, parse-failure rate, thumbs-down, cost per request.
Then triage: pull a sample of bad traces with the request, retrieved context,
tool calls, and final output, and reproduce offline against the golden eval
set plus new failure cases.

Post-incident, the eval set gets updated with the failing examples so the
regression cannot ship again, and the rollout process is examined: usually the
answer is that shadow or canary was skipped or the eval set did not cover the
affected slice.

### 5. What does a promotion pipeline for prompt changes look like?

**Answer:** A prompt change flows through the same stages as code, just with
different gates. PR opens with the diff and rationale, CI runs the offline eval
suite (quality, safety, structured-output validity, cost, latency) against a
frozen dataset, and merges are blocked on regressions beyond a threshold.
Merging promotes to staging where shadow traffic runs for a defined window,
then a canary at low percentage with automatic rollback on SLO breach, then a
ramp to 100%.

Two senior details: gate on cost and latency alongside quality, because a
"better" prompt that doubles tokens is often a regression; and require an
owner and a rollback plan on the PR, since prompt changes are frequently made
by non-engineers and need the same discipline as a code deploy.
