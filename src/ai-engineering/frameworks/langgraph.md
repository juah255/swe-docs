# LangGraph

LangGraph is a framework for building stateful, graph-based agent workflows. It
models an application as a graph of nodes connected by edges, with an explicit
state object that flows through the graph. It is built on top of LangChain but
can be used with plain model calls.

## Core Concepts

- **State**: a typed data structure that holds everything the workflow needs —
  messages, tool results, intermediate values, and counters. State is passed
  into every node and returned after each step.
- **Node**: a function that receives the current state, does work (often a model
  call or a tool call), and returns an updated state.
- **Edge**: connects nodes and can be conditional. A conditional edge inspects
  the state and decides which node to run next, which is how branching works.
- **Graph**: the overall workflow definition of nodes and edges. The graph is
  compiled and then invoked with an initial state.

## Key Features

- **Stateful flows**: state is explicit and typed instead of hidden in
  conversation text, so multi-step logic stays predictable.
- **Checkpointing**: the graph can save state after each super-step, enabling
  durable execution, resumption after a crash, and time travel for debugging.
- **Conditional branching**: routes depend on model output or state values, so
  the flow can react to what a step returns.
- **Retries**: nodes can be retried on failure with configurable limits, and
  the graph can fall back to alternate paths.
- **Human-in-the-loop**: the graph can pause, await human input or approval,
  and resume from the saved checkpoint.
- **Streaming**: node output and state updates can be streamed, which helps
  show progress and improve perceived latency.
- **Durability**: with an appropriate checkpoint store, long-running agent
  runs survive restarts instead of starting over.

## When To Use

Use LangGraph when the workflow has:

- Multiple steps with explicit state that must be tracked across them.
- Branching or loops that depend on model judgment or intermediate results.
- A need for retries, checkpoints, or human review.
- Long-running or resumable agent executions.

Prefer plain code or a simpler SDK when the flow is a few linear steps with no
shared state — the graph machinery is overhead when there is nothing to
orchestrate.

## Best Practices

- Keep nodes small and focused: one responsibility per node.
- Define state with a typed schema so invalid transitions fail fast.
- Set hard limits — max steps, max retries, max tokens — in the graph so
  runaway loops cannot burn unbounded budget.
- Put side-effecting actions behind confirmation checkpoints with human
  approval.
- Use checkpointing for anything that must survive a crash or be resumed.
- Log the state, the chosen branches, and tool calls for observability; the
  graph is only debuggable if you record what it actually did.

## Pitfalls

- Overcomplicating simple flows: a graph with one node and one edge is just a
  function call.
- Storing large, unstructured state blobs that are slow to checkpoint and hard
  to reason about.
- Relying on the framework for retries and durability but not configuring a
  persistent checkpoint store, so the guarantees silently disappear.
- Ignoring abstraction cost: if you cannot trace why a node ran, the framework
  is hiding behavior you need to own.

See [Workflows](../ai-agents/workflows.md) for when to choose a graph over a
free-form agent, and the [Frameworks overview](index.md) for selection criteria.

## Mid/Senior Interview Questions and Answers

### 1. When would you reach for LangGraph instead of plain code or a free-form agent?

**Answer:** When the workflow has multiple steps, shared state, branching, or a
need for retries and resumability. LangGraph gives you an explicit state object,
checkpointing, conditional edges, and human-in-the-loop primitives that plain
code forces you to reinvent — usually worse.

For a single model call, a classification endpoint, or a linear three-step
flow, plain code or a direct SDK is simpler and easier to debug. The moment
state must survive across steps, loops depend on model judgment, or a process
must pause for human review and resume later, the graph model earns its keep.
The wrong reason to adopt it is "the team already uses LangChain."

### 2. How does state management and checkpointing actually work in LangGraph?

**Answer:** State is a typed schema that flows through the graph. Each node
receives the current state, returns an updated slice, and reducers define how
incoming updates merge with existing state — for example appending to a message
list instead of overwriting it. Checkpointing saves the state after each
super-step to a configurable store, which gives you durable execution: a crash
or a manual interrupt can be resumed from the last checkpoint, and you can
replay or fork past states for debugging.

The senior details matter: choose a persistent store, not in-memory only, if
you need resumability across restarts; version the state schema because a
schema change breaks replay of old checkpoints; and keep stored state
bounded — persisting large tool outputs or full documents bloats every
checkpoint and slows the whole graph.

### 3. How do you keep a LangGraph agent from running away in cost or loops?

**Answer:** Encode hard limits into the graph itself, not the prompt. Cap the
maximum number of steps or super-steps per run, cap retries per node, and cap
total tokens, then track the budget in state and take a failure or fallback
edge when a limit is hit. Detect repeat states — the same node producing the
same output — and break the loop explicitly rather than letting it cycle.

Put side-effecting or destructive nodes behind confirmation checkpoints so
they cannot execute more than once without human approval. Wire cost and
latency alarms around the whole graph too, because agents find creative ways
to burn budget that individual limits miss.

### 4. What human-in-the-loop patterns work well with LangGraph?

**Answer:** The interrupt-before-side-effect pattern fits the graph model
directly: an edge pauses execution, the graph saves a checkpoint, a human
approves or edits the proposed action, and execution resumes from the saved
state. This works for refunds, emails, destructive operations, or anything
with a high blast radius.

Batched review is better when actions are low-risk individually but need
oversight in aggregate — the graph collects proposals and a human reviews them
in one pass. Whatever the pattern, persist enough context in the checkpoint for
the human to decide: retrieved sources, tool history, and the model's reasoning
for the proposal, not just the final answer.

### 5. How do you debug a graph execution that produced a wrong answer?

**Answer:** You debug the graph the same way you would any distributed stateful
system: logs, traces, and replay. Log every node entry and exit with its input,
output, timing, and the branch that was chosen, tied to a single run ID so you
can reconstruct the full path. Use checkpoint replay or time-travel to step
through the state at each super-step and find where it diverged.

Then reproduce with the same inputs against the current graph, and if it still
fails, add it to your eval set as a regression case. The hard part is that the
failure is often not the model — it is a stale state field, a misconfigured
conditional edge, or a tool returning an unexpected shape. That is exactly why
typed state and explicit edge logic matter: they make the divergence visible
instead of leaving it as "the AI got confused."
