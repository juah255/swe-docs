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

### 1. How do you decide whether a task needs an agent or a deterministic workflow?

**Answer:** Decide on where the branching comes from. If the steps are known
in advance and depend on state that follows a fixed shape, a workflow is
cheaper, more testable, and easier to audit. Use an agent only when the next
action depends on model judgment over open-ended input, and even then wrap it
in a workflow with limits so it cannot spiral.

### 2. How do you keep loop cost and runaway behavior under control?

**Answer:** Hard caps everywhere: max steps per run, max tool calls per step,
max total tokens, wall-clock timeout. Track budget in the state object and
fail closed when a limit is hit. Detect repeat states — the same tool called
with the same arguments twice is almost always a loop — and break out with an
explicit error the model can see.

Also cap the blast radius: no destructive tool should be callable more than
once per run without a confirmation checkpoint. Cost alarms on top of that
because the model will find creative ways to burn tokens.

### 3. Where does state live in an agent, and how do you keep it reliable?

**Answer:** State lives in an explicit object the agent reads and writes —
steps done, results, budget, environment facts — not in conversation history,
which the model will drop or contradict. Persist that object on every
meaningful change so runs survive restarts and failures. The discipline that
keeps it reliable is the same as any program: define the shape, write before
side effects, and never derive truth from the transcript.

### 4. How do you test an agent without shipping flaky tests?

**Answer:** Test the deterministic pieces hard — each tool against fakes,
prompts against golden outputs — and test the agent with scenario tests that
assert observable outcomes (tool calls made, state transitions, end state)
within budget, not exact trajectories. Deterministic reproduction of a
stochastic model is a trap; assert invariants and budgets instead. Add
regression traces from bad production runs and replay them after each change.

### 5. Why do most agent demos not survive production?

**Answer:** Demos run on happy-path prompts, one tool call deep, with clean
data. Production hits ambiguous user intent, stale or contradictory retrieved
context, tools that time out, prompt injection through document content, and
long-running sessions where state drifts. There is no observability, so
failures look like "the AI got confused" instead of "the calendar tool
returned an empty array and the model invented a meeting."

The fix is boring: explicit state, small tool surface, hard limits, real
evaluation on real traffic, and a plan for when the model is wrong.
