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

## Mid/Senior Interview Questions and Answers

### 1. When is plan-then-execute better than re-planning at every step?

**Answer:** Plan-then-execute wins when the task decomposes into mostly
independent steps, because it cuts per-step decisions, tokens, and drift.
Re-plan at every step only when each action depends on the previous result.
A hybrid is usually best: a coarse plan up front, then re-plan at explicit
milestones or when a step fails.

### 2. What triggers a re-plan, and how do you avoid re-planning in a loop?

**Answer:** Re-plan when a step fails, a tool returns an unexpected result, or
the observed state no longer matches what the plan assumed. Preserve completed
steps and their outputs and only re-plan the remainder. To avoid loops, bound
the number of re-plans per run, require a state change before each re-plan, and
fail closed when the budget is exhausted instead of retrying forever.

### 3. How do you make plans bounded without killing legitimate long-running tasks?

**Answer:** Express limits as observable budget — max steps, max tool calls,
max tokens, wall-clock time — stored in the state object so every step checks
it. Set limits from the task's real requirements, not a default, and scale
them with complexity. The point is to fail closed with a clear error before
the agent improvises past what the business agreed to pay for.

### 4. Structured or free-form plans — how do you choose?

**Answer:** Structured plans with explicit steps, inputs, and outputs are
checkable and easy to bound, resume, and observe, so prefer them for anything
with side effects. Free-form prose is cheaper to generate and suits exploratory
tasks but hides drift and is hard to audit. Use a structured skeleton the
model fills in, so plans stay machine-readable without costing more.

### 5. How do you evaluate the quality of a plan?

**Answer:** Score plans on executability (each step maps to a tool or decision),
coverage (steps achieve the goal), and efficiency (fewer steps than the
alternative). In evaluation, compare planned versus executed steps to measure
drift. Plan quality matters less than outcome: a plan that leads to a
successful, budget-respecting run is a good plan, even if the text is ugly.
