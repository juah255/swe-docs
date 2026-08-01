# Memory

Agents use memory to carry information across steps and sessions. Design it
explicitly rather than leaving it implicit in conversation text.

## Short-Term Memory

- Recent conversation turns and tool results kept in context.
- Bounded by the context window; trim or summarize old turns when full.
- Do not rely on it to persist state the task logic needs.

## Working Memory and State

- Working memory is the current, explicit state the agent acts on.
- Store state in a structured object (steps done, results, budget) rather than
  only in prose.
- Persist state explicitly so runs survive restarts and humans can review.

## Long-Term Memory

- Summaries or vector-store recalls that span sessions and users.
- Recall by retrieval (see [Knowledge Retrieval](../knowledge-retrieval/index.md))
  rather than stuffing everything into context.
- Store who-what-when so recall can be scoped and expired.

## Memory Hygiene

- Set expiration for ephemeral data; do not let stale memories contaminate
  decisions.
- Respect privacy and deletion: honor user requests to forget.
- Scope memory per user or tenant; never leak one user's memory to another.
- Audit what is written to and read from long-term memory.

See [Planning](planning.md) for how state feeds step selection.
