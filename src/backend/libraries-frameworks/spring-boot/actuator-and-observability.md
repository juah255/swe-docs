# Actuator and Observability

Spring Boot Actuator exposes operational information and integrates with
Micrometer observations, metrics, and tracing. Observability should answer what
is failing, where, for whom, and since which change.

## Actuator Endpoints

Common endpoints include health, info, metrics, Prometheus output, loggers,
configuration properties, mappings, and migration state. Most endpoints are not
exposed over HTTP by default because several reveal sensitive internals.

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus
  endpoint:
    health:
      probes:
        enabled: true
      show-details: when-authorized
```

Exposure and authorization are separate controls. Limit the exposed set, secure
it with Spring Security or network policy, and consider a separate management
port or interface. Never publish `env`, `configprops`, heap dumps, or log-level
mutation broadly.

## Health Probes

Health policy should reflect how the deployment platform acts on it:

- **Liveness** asks whether the process should be restarted.
- **Readiness** asks whether the instance should receive new traffic.
- **Startup** gives initialization a separate time budget where supported.

Do not make liveness depend on a remote database or API; an outage could restart
every otherwise healthy process. Readiness may depend on capabilities necessary
to serve the traffic assigned to that instance.

Custom health indicators need strict timeouts and should reveal enough for
operators without disclosing credentials or topology to untrusted callers.

## Metrics

Micrometer provides a vendor-neutral instrumentation API. Useful service-level
metrics include:

- request rate, errors, and latency distributions;
- JVM CPU, heap, garbage collection, and thread state;
- database and HTTP pool usage and wait time;
- query, remote dependency, and cache latency;
- queue depth, oldest message age, retries, and dead letters;
- business outcomes such as accepted, paid, or rejected orders.

Keep metric labels low-cardinality. User IDs, request IDs, URLs with identifiers,
exception messages, and raw SQL can create unbounded time series.

## Tracing and Observations

An observation can produce metrics, traces, or both. Propagate trace context over
HTTP and messages using supported instrumentation. Create custom spans around
meaningful remote or expensive operations, not every method.

Thread-local observation context does not automatically survive every custom
executor or reactive boundary. Use Spring's context-propagation support and
verify it with tests. Never put credentials or sensitive personal data in span
attributes.

## Logging

Prefer structured logs with timestamp, level, service, environment, trace ID,
event name, and carefully selected domain identifiers. Log an exception once at
the boundary that handles it; repeated logging at every layer creates noise.

Use parameterized logging to avoid unnecessary string construction:

```java
log.info("order_paid orderId={} paymentId={}", orderId, paymentId);
```

Apply redaction centrally and test it. Authorization headers, cookies, tokens,
passwords, database URLs, and customer payloads should not appear in logs.

## Alerts and Diagnostics

Alert on user-visible symptoms and exhaustion trends: sustained error rate, tail
latency, unavailable instances, pool saturation, queue age, and failed critical
jobs. Connect alerts to ownership and a runbook.

Retain thread dumps, heap diagnostics, Java Flight Recorder data, and deployment
markers where appropriate. Diagnostic access is privileged production access and
must be protected accordingly.

