# Agent Fundamentals

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

## Common Risks

- Infinite loops or excessive tool calls.
- Tool calls based on misunderstood user intent.
- Hidden state stored only in conversation text.
- Poor observability of intermediate steps.
- Side effects without confirmation.

## Mid/Senior Interview Questions and Answers

### 2. How do you keep loop cost and runaway behavior under control?

**Answer:** Hard caps everywhere: max steps per run, max tool calls per step,
max total tokens, wall-clock timeout. Track budget in the state object and
fail closed when a limit is hit. Detect repeat states — the same tool called
with the same arguments twice is almost always a loop — and break out with an
explicit error the model can see.

Also cap the blast radius: no destructive tool should be callable more than
once per run without a confirmation checkpoint. Cost alarms on top of that
because the model will find creative ways to burn tokens.

### 5. Why do most agent demos not survive production?

**Answer:** Demos run on happy-path prompts, one tool call deep, with clean
data. Production hits ambiguous user intent, stale or contradictory retrieved
context, tools that time out, prompt injection through document content, and
long-running sessions where state drifts. There is no observability, so
failures look like "the AI got confused" instead of "the calendar tool
returned an empty array and the model invented a meeting."

The fix is boring: explicit state, small tool surface, hard limits, real
evaluation on real traffic, and a plan for when the model is wrong.
