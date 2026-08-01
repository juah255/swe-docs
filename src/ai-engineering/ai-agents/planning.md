# Planning

Planning is how an agent turns a task into a sequence of concrete steps.
The quality of the plan bounds how reliably the agent finishes the task.

## Decomposing Tasks

- Break the goal into discrete, testable steps that each map to a tool call or
  a model step.
- Prefer a plan the model can check against the environment state at each step.
- Keep steps small enough to recover from failure without restarting.

## Plan-then-Execute

- In plan-then-execute, the model produces a plan first, then executes it step
  by step.
- The fixed plan reduces unneeded model decisions, cutting cost and drift.
- For open-ended tasks, re-plan at milestones instead of re-planning each step.

## Re-planning

- Detect when a step fails or the plan no longer matches reality, and re-plan
  from the current state.
- Preserve completed steps and their results; only re-plan the remainder.
- Signal failures explicitly so the planner can react rather than invent
  outcomes.

## Bounded Plans

- Keep plans structured and bounded: max steps, max tool calls, and a budget
  per run.
- Fail closed when a limit is reached instead of letting the agent improvise
  indefinitely.
- Cap the depth of sub-plans so planning itself cannot loop.

## Observability

- Log the plan, the executed steps, and any re-plans for debugging.
- Compare planned versus executed steps to spot where the model drifts.

See [Workflows](workflows.md) for when a fixed graph beats free-form planning.
