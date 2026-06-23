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
