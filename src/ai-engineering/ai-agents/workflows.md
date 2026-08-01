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
