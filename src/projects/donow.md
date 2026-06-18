# DoNow

Notes, architecture, and operational details for the DoNow project.

## Mid/Senior Interview Questions and Answers

### 1. How would you describe DoNow's core workflow?

**Answer:** Explain the main user actions, the data created by those actions,
and the request path through frontend, backend, database, and notifications or
background jobs if applicable.

A senior answer should include failure handling and how the system keeps user
state consistent.

### 2. What reliability concerns apply to a task or productivity app?

**Answer:** Common concerns include data loss, offline or retry behavior,
duplicate actions, notification reliability, permission boundaries, and syncing
state across devices.

Use idempotent writes, clear conflict handling, backups, and observability for
failed jobs or sync operations.

### 3. What would you monitor for DoNow in production?

**Answer:** Monitor request latency, error rate, task creation/update failures,
database performance, queue failures, notification delivery, authentication
errors, and frontend runtime errors.

Operational metrics should map to user-visible workflows.
