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

## Mid/Senior Interview Questions and Answers

### 1. How do short-term, working, and long-term memory differ, and where does each belong?

**Answer:** Short-term memory is the recent context living in the context
window; working memory is the explicit, structured state the agent mutates as
it acts; long-term memory is durable storage spanning sessions and users.
Keep working memory in a structured object so it survives restarts, put only
what the current turn needs in short-term context, and push anything that must
persist into long-term storage keyed by user and scope.

### 2. How do you summarize conversation history without losing what matters?

**Answer:** Summarize against the state the task needs, not the whole
transcript: keep goals, decisions, constraints, and unresolved items, and drop
the prose that produced them. Store the summary alongside a structured state
object so facts are not trapped in text. Re-summarize incrementally as the
conversation grows, and evaluate the summarizer itself, since a bad summary
silently corrupts every later decision.

### 3. What does memory persistence mean for an agent, and how do you implement it?

**Answer:** Persistence means working state survives restarts, failures, and
sessions — writes go to durable storage, not only to the transcript. Store the
state object with a version and a who-what-when record so you can reload,
audit, and roll back. Persist before any external side effect and checkpoint
the state so a crash resumes from the last committed state.

### 4. How do you prevent memory from leaking across users?

**Answer:** Scope every read and write to a tenant and user key and pass that
scope into every retrieval so no query can see another user's data. Never
stuff pooled context into the prompt from storage that is not isolated per
request. Expire data and honor deletion requests, and audit both what was
written and what was returned, because a leak is a privacy incident, not a
quality issue.

### 5. How does memory cost context, and how do you control it?

**Answer:** Every token of retained history is paid on every turn, so memory
that is never used is pure cost. Budget the context window explicitly: trim or
summarize old turns, keep working state compact, and retrieve from long-term
memory only what the current step needs. Track how much of the prompt is
memory versus task, and treat session growth in cost as the signal to move
from context to storage.
