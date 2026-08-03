# Agent Evaluation

- Agents need scenario tests with a starting state and an expected end state.
- Assert observable outcomes (tickets created, state transitions, tool calls
  made) rather than exact trajectories.
- Check budget adherence: steps, tokens, and tool calls.
- Replay historical bad runs as regression traces.

## Mid/Senior Interview Questions and Answers

### 1. What does a test for an agent even look like?

**Answer:** You test the pieces the agent depends on deterministically — each
tool with fakes, prompts with golden outputs on fixed inputs — and you test
the agent itself with scenario tests: given this user goal and this environment
state, does the run reach an acceptable end state within budget? Assertions
are on observable outcomes (tickets created, state transitions, tool calls
made), not on the exact trajectory.

Add regression traces: replay historical bad runs and assert the fix holds.
Chasing 100% deterministic reproduction with a stochastic model is a trap.

### 2. How do you evaluate an agent when it is stochastic?

**Answer:** Assert on the outcome, not the path: the same starting state and
goal should reach an acceptable end state within budget, regardless of which
tools got called in which order. Run each scenario several times and track the
success rate and variance, and treat a rare failure as a risk to monitor, not
necessarily a bug. When you need determinism, mock the tools and model outputs
so the agent logic, not the model, is what is under test.

### 3. How do you build scenario-based eval datasets for agents?

**Answer:** Write scenarios as starting-state plus goal plus expected end state,
drawn from real production runs and edge cases, with the tools mocked so tests
are fast and reproducible. Cover the failure paths — tool timeouts, empty
results, ambiguous goals — because that is where agents actually break. Version
the scenario set and grow it from every production incident, so each new
failure becomes a regression test rather than a story.

### 4. How do you test budget adherence as part of agent evaluation?

**Answer:** Budget is a first-class assertion: record steps, tool calls, and
tokens per scenario, and assert they stay under the limits you configured.
Compare the distribution across runs, because an agent that succeeds but uses
ten times the budget it should is a cost bug. Put the same budget checks in
the production agent so it fails closed, and the eval and the runtime enforce
the same contract.

### 5. How do you balance component tests against end-to-end agent evals?

**Answer:** Use component tests for the deterministic core — tools, prompts,
state transitions — and scenario tests for agent behavior, then run a small set
of end-to-end tests against the real environment for the integration layer.
The trade-off is cost: end-to-end evals are expensive and flaky, so let them be
the final gate, not the primary signal. Keep most failures caught at the
component level where they are cheap to diagnose.

See [Agent Fundamentals](../ai-agents/agent-fundamentals.md).
