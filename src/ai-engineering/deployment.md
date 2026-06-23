# Deployment

Production AI features should have the same engineering discipline as other
backend systems.

## Production Readiness

- Clear input and output contracts.
- Versioned prompts and configuration.
- Automated tests and evaluation gates.
- Timeouts, retries, fallbacks, and circuit breakers.
- Rollback plan for prompt, model, retrieval, or tool changes.
- Monitoring for quality, latency, cost, and failures.
- Data retention and privacy controls.
- Documentation for operators and support teams.

## Release Strategy

Deploy risky changes gradually with:

- Feature flags.
- Canary releases.
- Limited user rollouts.
- Shadow evaluation.
- A/B testing when user impact can be measured safely.

## Rollback Planning

Rollback should cover:

- Prompt versions.
- Model versions.
- Retrieval indexes.
- Tool schemas.
- Safety rules.
- Routing configuration.

AI incidents often come from the system around the model, not only from the
model itself.
