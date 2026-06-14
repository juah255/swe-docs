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

## Questions to Answer

- What information should every application log entry contain?
- When should you use a metric instead of a log?
- How does distributed tracing identify latency across services?
- What makes an alert actionable?
