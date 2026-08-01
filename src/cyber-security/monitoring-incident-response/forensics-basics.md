# Forensics Basics

Forensics is about preserving evidence so a compromise can be investigated
properly.

Preserve evidence in a way that does not destroy it:

- **Logs**: retain security-relevant logs with timestamps.
- **Memory**: capture volatile state before it is lost.
- **Disk images**: take copies rather than examining the live disk.
- **Snapshots**: keep virtual machine or container snapshots for review.

Practice timeline analysis to reconstruct the order of events, and document a
chain of custody so the evidence can be trusted later. Avoid modifying original
data: work from copies whenever possible. Collect evidence before remediation
where possible, because cleanup destroys the artifacts you need to understand
what happened.

Know what data is retained and for how long, so you can answer whether a window
of evidence still exists when an incident is found.

See [Logging](logging.md) and [Incident Response](incident-response.md) for how
evidence fits into detection and response.
