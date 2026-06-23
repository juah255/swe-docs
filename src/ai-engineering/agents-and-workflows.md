# Agents and Workflows

An agent uses a model to choose steps, call tools, and use intermediate results
to finish a task. Agents are powerful but harder to test than fixed workflows.

## When To Use Agents

Use agents when:

- The steps depend on open-ended user input.
- The workflow needs dynamic tool choice.
- The system must inspect intermediate results before deciding the next action.

Prefer deterministic workflows when:

- The process is known in advance.
- Compliance requires predictable behavior.
- The task has high-impact side effects.

## Design Rules

- Keep tools small and permission-aware.
- Store state explicitly instead of relying only on conversation history.
- Limit the number of steps and tool calls.
- Add checkpoints before external side effects.
- Log the plan, tool calls, observations, and final result.
- Use human review for risky actions.

## Graph-Based Workflows

Workflow orchestration is often more reliable than free-form agent behavior.
LangGraph is commonly used when the application needs explicit state machines,
branching, retries, checkpoints, and human-in-the-loop steps.

## Common Risks

- Infinite loops or excessive tool calls.
- Tool calls based on misunderstood user intent.
- Hidden state stored only in conversation text.
- Poor observability of intermediate steps.
- Side effects without confirmation.
