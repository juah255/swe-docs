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
