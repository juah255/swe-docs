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
