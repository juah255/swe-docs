# Multi-Agent Systems

A multi-agent system uses multiple agents with distinct roles that cooperate on
a task. The division of labor is deliberate, not just more agents doing the
same thing.

## Roles and Orchestration

- **Supervisor pattern**: a supervisor agent delegates subtasks to specialist
  agents and assembles their results.
- **Peer team**: agents share a goal and coordinate, typically through shared
  state or a shared message channel.
- **Pipeline**: each agent hands its output to the next, like a workflow where
  every stage is an agent.

## Communication and State

- Define a shared state or message schema so agents exchange well-formed data.
- Route context and partial results explicitly; do not rely on implicit
  conversation history.
- Make each agent's inputs and outputs observable for debugging.

## Costs

- More agents mean more tokens, more latency, and more failure modes.
- Debugging spans agent boundaries, so log the full trace across agents.
- Coordination overhead can exceed the benefit of specialization.

## When To Use

- Use multiple agents only when one agent with tools is insufficient, such as
  genuinely parallel specialist work.
- Prefer a single agent or a workflow first; add agents only for a measurable
  reason.

See [Workflows](workflows.md) for deterministic orchestration and
[Agent Fundamentals](agent-fundamentals.md) for single-agent design.

## Mid/Senior Interview Questions and Answers

### 1. When do multiple agents actually beat a single agent with tools?

**Answer:** When the work is genuinely parallel — independent specialists that
do not need each other's outputs mid-flight — or when one context window cannot
hold all the roles, tools, and context the task needs. If a single agent with
good tools handles it, prefer that: every extra agent adds tokens, latency,
and failure modes. Use multi-agent only when specialization or parallelism is
measurable, not as an architecture statement.

### 2. Supervisor or peers — how do you choose an orchestration pattern?

**Answer:** Supervisor delegation works when a clear authority can decompose the
task and assemble results, and when you want central control over what happens
next. Peer orchestration fits tasks where agents coordinate through shared
state and no single agent should own the outcome. Prefer the supervisor in
practice: it is easier to observe, bound, and test than emergent peer
negotiation.

### 3. How do you design shared state and communication between agents?

**Answer:** Define an explicit schema for the shared state and for every message
an agent emits, so communication is typed data, not prose. Route context
explicitly instead of sharing raw conversation history, and make each agent
declare which part of the state it owns. Keep the shared schema small and
versioned, because the coordination bug is usually two agents writing fields
that only merge at the end.

### 4. How do you stop cost and latency from blowing up as you add agents?

**Answer:** Cost scales with every message every agent sees, so bound the
fan-out: route each task to the smallest set of agents, pass only the context
each one needs, and avoid broadcast. Run parallel agents in parallel so
wall-clock time does not sum. Budget per run like a single agent and alarm
when an agent's share exceeds what its role justifies.

### 5. How do you debug a failure in a multi-agent system?

**Answer:** Reconstruct the run as one trace across agent boundaries: log every
agent's inputs, outputs, and state transitions under a shared trace ID, and
render them in order so you see where the handoff went wrong. Check the message
schema first — mismatched fields are the most common fault. Reproduce the
failing scenario with mocked states and assert on the final outcome.
