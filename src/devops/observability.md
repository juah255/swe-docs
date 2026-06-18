# Observability

Observability helps explain a system's behavior from its outputs and supports detection, diagnosis, and improvement.

## Logs

- Structured logging
- Log levels and consistent fields
- Correlation and request IDs
- Centralized collection and retention
- Protecting sensitive data in logs

## Metrics

- Counters, gauges, histograms, and summaries
- Application and infrastructure metrics
- The latency, traffic, errors, and saturation signals
- Prometheus and exporters
- Grafana dashboards

## Traces

- Spans and distributed traces
- Context propagation
- Sampling
- OpenTelemetry
- Trace and log correlation

## Alerting and Service Health

- Actionable alerts
- Symptoms instead of internal causes
- Service-level indicators (`SLIs`)
- Service-level objectives (`SLOs`)
- Service-level agreements (`SLAs`)
- Error budgets
- Runbooks and escalation

## Mid/Senior Interview Questions and Answers

### 1. What information should every application log entry contain?

**Answer:** Important logs should include timestamp, level, message, service,
environment, request or correlation ID, user or tenant identifier when safe,
operation name, error details, and relevant structured fields.

Do not log secrets, tokens, passwords, full payment data, or unnecessary PII.
Logs should help investigation without creating a security liability.

### 2. When should you use a metric instead of a log?

**Answer:** Use a metric when you need aggregation, dashboards, alerting, or
trend analysis. Use a log when you need event details and debugging context.

For example, request latency, error rate, queue depth, and memory usage should
be metrics. A failed payment attempt with context should be a structured log.

### 3. How does distributed tracing identify latency across services?

**Answer:** Distributed tracing propagates a trace context across service calls.
Each service records spans with timing and metadata, allowing the full request
path to be reconstructed.

This shows whether latency came from the gateway, application code, database,
cache, queue, or downstream service.

### 4. What makes an alert actionable?

**Answer:** An actionable alert indicates user impact or imminent risk, has a
clear owner, includes useful context, links to a runbook, and avoids noisy
conditions that do not require human action.

Good alerts focus on symptoms such as high error rate or SLO burn, not only
internal causes such as one pod restart.
