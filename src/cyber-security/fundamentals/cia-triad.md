# CIA Triad

The CIA triad describes the three core security goals that controls aim to
protect. It is a useful lens for evaluating every design decision.

## Confidentiality

- Only authorized users, services, and systems can read data.
- Controls include encryption at rest and in transit, access control, and
  least privilege.
- Backend example: database queries must enforce authorization before any
  row is returned.

## Integrity

- Data is accurate and unmodified by unauthorized parties.
- Controls include hashing, signatures, checksums, and tamper-evident
  logging.
- Backend example: verify a signed token's signature before trusting its
  claims.

## Availability

- Systems and data remain accessible to authorized users when needed.
- Controls include redundancy, backups, rate limiting, and monitoring.
- Backend example: load balancers and health checks keep services reachable.

## Trade-offs

- Strict controls can reduce availability, and relaxed controls can reduce
  confidentiality or integrity.
- Choose the balance based on the sensitivity of the data and the cost of
  downtime.
- Document the decision so reviewers understand why a trade-off was made.
