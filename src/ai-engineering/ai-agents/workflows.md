# Workflows

Workflows are deterministic sequences or graphs of steps with explicit state,
branching, retries, checkpoints, and human-in-the-loop steps. When the steps
are known in advance, prefer a workflow over a free-form agent.

## Graph-Based Workflows

Workflow orchestration is often more reliable than free-form agent behavior.
LangGraph is commonly used when the application needs explicit state machines,
branching, retries, checkpoints, and human-in-the-loop steps.

## When To Use a Workflow

- Use workflows when the process is known in advance and predictable behavior
  is required.
- A graph with explicit state, branching, retries, and checkpoints is easier
  to test and debug than free-form agent behavior.
- Insert human-in-the-loop steps at the points where a side effect needs
  approval or review.

## Prefer Workflows over Agents

- If you can draw the flowchart, build the workflow: cheaper, more testable,
  and easier to operate.
- Use an agent only when branching depends on model judgment over open-ended
  input, and wrap it inside a workflow so it cannot spiral.

## Mid/Senior Interview Questions and Answers

### 1. Workflow or agent — how do you actually decide?

**Answer:** If you can draw the flowchart, build the workflow. Deterministic
graphs are cheaper, easier to test, and much easier to debug when something
goes wrong at 3am. Reach for an agent only when the branching genuinely depends
on model judgment over open-ended input, and even then, wrap the agent inside a
workflow so it cannot spiral.

Most systems that call themselves agents are workflows with one model-driven
step. That is usually the right shape.

### 2. How do you model state in a graph-based workflow?

**Answer:** Define one typed state object that flows through every node, and let
each step read and update only the fields it owns. Keep the graph acyclic
unless a retry loop is explicit and bounded, and store checkpoints of the
state at each node so a failure resumes from the last completed step. The
state schema is your contract: nodes that mutate it inconsistently are the
most common source of graph bugs.

### 3. How do you handle retries and failures in a workflow?

**Answer:** Retry idempotent steps with bounded backoff, and distinguish
transient failures (timeouts, rate limits) from permanent ones (schema
mismatch, invalid input). Model retries as explicit graph edges with a counter,
not hidden code, so the policy is visible and testable. Fail closed when
retries exhaust, persist the partial state, and route the error to a handler
rather than looping.

### 4. What human-in-the-loop patterns actually work?

**Answer:** Interrupt-before-side-effect is the most useful pattern: the agent
proposes an action, the workflow pauses, a human approves or edits, then it
resumes. Batched review works when actions are low-risk individually but need
oversight in aggregate. Escalation-on-uncertainty (the model signals low
confidence and hands off) is nicer in theory than in practice because
calibration is poor.

Whatever you pick, persist state so a human can come back tomorrow, and make
the review UI show the retrieved context and tool history — not just the final
proposal.

### 5. How is testing a workflow different from testing an agent?

**Answer:** A workflow is a deterministic program, so you can test it like one:
unit-test each node, then property-test the graph over the state space —
branch coverage, every retry path, every failure edge. Agents need scenario
tests with tolerated variance instead. If your workflow is so dynamic it needs
agent-style probabilistic testing, that is a sign it should have been an
agent.
