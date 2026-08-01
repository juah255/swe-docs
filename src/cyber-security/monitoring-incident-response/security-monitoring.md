# Security Monitoring

Security monitoring helps detect suspicious behavior and investigate incidents.

## Alerts

Good alerts are actionable. Alert on behavior that suggests account takeover,
credential misuse, data exfiltration, privilege escalation, or service abuse.

Beyond alerting, monitoring requires continuous collection of logs and metrics
so there is always data to analyze. Establish a baseline of normal behavior so
anomalies stand out, and correlate events across sources to connect the dots
between separate signals.

Keep alert fatigue in mind: too many unactionable alerts cause teams to ignore
them. Review and tune alerts regularly so each one is meaningful. Threat intel
feeds can enrich detections with known indicators of compromise.

See [Logging](logging.md) for what to collect and [SIEM](siem.md) for
centralized analysis and correlation.
