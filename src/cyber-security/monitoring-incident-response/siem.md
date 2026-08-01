# SIEM

A SIEM (Security Information and Event Management) aggregates and correlates
logs and alerts from across systems in one place.

Capabilities:

- **Collection**: ingest logs and events from applications, hosts, and network
  devices.
- **Normalization**: translate diverse event formats into a common schema.
- **Correlation rules**: join related events to detect multi-step behavior.
- **Dashboards**: visualize activity and detection status.
- **Retention**: keep historical data available for investigation and
  compliance.
- **Investigations**: search and pivot across events when responding to an
  incident.

Challenges:

- **Cost**: storing and querying large volumes of logs is expensive.
- **Noise**: unfiltered data produces floods of low-value events.
- **Tuning**: correlation rules need ongoing tuning to stay accurate.

A SIEM is not the same as centralized logging. Centralized logging just
collects and stores logs for search; a SIEM adds correlation, alerting, and
investigation workflows on top of that foundation.

See [Security Monitoring](security-monitoring.md) and
[Logging](logging.md) for what feeds the SIEM.
