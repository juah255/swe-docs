# IDS / IPS

Intrusion Detection Systems (IDS) monitor traffic and behavior and alert on
suspicious activity. Intrusion Prevention Systems (IPS) go further and also
block the activity inline.

Detection approaches:

- **Signature-based**: match against known attack patterns. Accurate for known
  threats, but blind to novel ones.
- **Anomaly-based**: flag deviations from a baseline of normal behavior. Can
  find novel threats, but produces more false positives.

Placement:

- **Host-based (HIDS)**: monitors a single host's activity, files, and
  processes.
- **Network-based (NIDS)**: monitors traffic crossing the network.

Limitations:

- **Encrypted traffic**: cannot inspect content that is encrypted in transit.
- **False positives**: noisy detections erode trust in the alerts.
- **Bypass**: attackers evade signatures or encrypt their activity.

Treat IDS/IPS as one layer of a broader defense, not the only defense. Pair it
with [Security Monitoring](security-monitoring.md), [SIEM](siem.md), and
[Incident Response](incident-response.md).
