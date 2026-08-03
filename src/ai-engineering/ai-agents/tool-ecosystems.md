# Tool Ecosystems

Agents act through tools, and the ecosystem around those tools determines how
agents get capabilities, how safe they are, and how they evolve.

## Tool Catalogs and Registries

- Use catalogs or registries to discover and reuse tools across teams.
- Document each tool's schema, purpose, permissions, and owner so agents and
  developers can pick the right one.
- Allow scoped access so an agent only sees the tools relevant to its task.

## Vetting Third-Party Tools

- Third-party tools are untrusted code: review them before they touch your
  credentials or data.
- Restrict credential scope: least-privilege keys, per-tenant isolation, and
  no broad access to production systems.
- Watch for tools that exfiltrate data or prompt-inject through their
  descriptions and results.

## Versioning Tool Schemas

- Treat tool schemas like a public API: semantic versioning and additive
  changes by default.
- Never remove or rename a tool without a deprecation window; agents caching
  old schemas will break mid-conversation.
- Coordinate schema changes with the model versions that consume them.

## Monitoring Tool Usage

- Log every tool call: which tool, which arguments, duration, and result.
- Track failure rates and unexpected arguments to catch broken tools and
  misbehaving agents.
- Alert on cost spikes and repeated calls to the same tool.

See [Function and Tool Calling](../model-integration/function-tool-calling.md)
for how the model invokes tools.

## Mid/Senior Interview Questions and Answers

### 1. What is the point of a tool registry or catalog?

**Answer:** A registry is how tools get found, versioned, and governed beyond a
single repo: it stores schema, description, permissions, and owner, and it is
what agents query to discover what they can call. It makes tool choice
deliberate instead of ad hoc and lets teams reuse instead of reimplement.
Keep it searchable and scoped, because a catalog that surfaces everything is
just a code dump.

### 2. How do you vet a third-party tool before wiring it into an agent?

**Answer:** Treat it as untrusted code: review what it sends and where, and test
it against credentials that cannot touch production. Grant least-privilege,
per-tenant scoped permissions, and watch its descriptions and results for
prompt injection that tries to steer the agent. Wrap it behind an internal
proxy that enforces allow-listed actions and audits every call, so the
untrusted surface stays small.

### 3. How do you version tool schemas without breaking running agents?

**Answer:** Treat the schema as a public API: additive changes by default,
semantic versioning, and a deprecation window before anything is removed or
renamed. Keep old versions working while new ones roll out and update the
model version consuming the schema at the same time. Never remove a parameter
in the same release it is renamed, because cached schemas break mid-conversation
silently.

### 4. How do you make tools discoverable by agents?

**Answer:** The model finds tools through descriptions, so write each one for
selection: what it does, when to use it, what it needs, and what it returns,
and keep the description consistent with the schema. Keep the visible set small
and scoped per task, because a long list degrades both choice quality and
latency. Log which tools were offered versus called and tune the catalog from
the miss rate.

### 5. What do you monitor about tool usage in production?

**Answer:** Log every call with tool, arguments, duration, result, and caller,
then track failure rates, latency, and cost per tool. Watch for repeated
identical calls that signal loops, unexpected arguments, and tools that break
after a schema change. Alert on cost spikes and per-tool error rates, and feed
the logs into your evaluation set so production failures become regression
cases.
