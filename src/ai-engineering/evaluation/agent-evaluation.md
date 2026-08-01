# Agent Evaluation

- Agents need scenario tests with a starting state and an expected end state.
- Assert observable outcomes (tickets created, state transitions, tool calls
  made) rather than exact trajectories.
- Check budget adherence: steps, tokens, and tool calls.
- Replay historical bad runs as regression traces.

## Mid/Senior Interview Questions and Answers

### 3. What does a test for an agent even look like?

**Answer:** You test the pieces the agent depends on deterministically — each
tool with fakes, prompts with golden outputs on fixed inputs — and you test
the agent itself with scenario tests: given this user goal and this environment
state, does the run reach an acceptable end state within budget? Assertions
are on observable outcomes (tickets created, state transitions, tool calls
made), not on the exact trajectory.

Add regression traces: replay historical bad runs and assert the fix holds.
Chasing 100% deterministic reproduction with a stochastic model is a trap.

See [Agent Fundamentals](../ai-agents/agent-fundamentals.md).
