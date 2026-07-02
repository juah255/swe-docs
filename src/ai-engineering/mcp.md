# Model Context Protocol

Model Context Protocol (`MCP`) is a standard way to connect AI applications to
external tools and data sources.

## Core Ideas

- **Host**: the AI application that coordinates the user experience.
- **Client**: the component that connects the host to an MCP server.
- **Server**: exposes tools, resources, or prompts from a specific system.
- **Tool**: an operation the model can request through the host.
- **Resource**: data the application can read from the connected system.

## When To Use MCP

Use MCP when the same tool or data integration should be reusable across
assistants, editors, agents, or internal workflows.

Good fits:

- Developer tools.
- Internal knowledge systems.
- Ticketing systems.
- File or document systems.
- Databases exposed through controlled operations.

## Security Notes

- Treat tool descriptions, resource content, and tool results as untrusted data.
- Enforce authorization outside the model.
- Expose only the tools needed for the current workflow.
- Avoid giving MCP servers unnecessary access to secrets or broad credentials.
- Log tool calls for auditability.

## Mid/Senior Interview Questions and Answers

### 1. What does MCP actually solve that ad-hoc tool integration does not?

**Answer:** MCP standardizes the interface between hosts (Claude Desktop, IDEs,
agents) and tool providers, so the same integration works across clients
without rewriting glue for each SDK. That is a real win when you have multiple
consumers of the same capability — a Jira server used by an IDE assistant, a
chat app, and an internal agent all through one protocol.

If you only have one host and one integration, MCP is overhead. The value
appears at the second or third consumer.

### 2. What is the security posture of running MCP servers?

**Answer:** Every MCP server is a signed-in process that can execute actions on
behalf of the user, often against sensitive systems. Treat tool descriptions
and resource content as untrusted (prompt injection through file contents is a
real attack). Run servers with least-privilege credentials, isolate them per
tenant or per workspace, and log every call. Do not install random community
MCP servers on production credentials.

The threat model is closer to "browser extension" than "library dependency."
Review accordingly.

### 3. When should you not reach for MCP?

**Answer:** Skip MCP when the integration is host-specific, when latency
matters and the extra hop costs too much, or when you want tight control over
the tool schema and prompt strategy. Internal one-off tools that only your
agent will ever call are simpler as direct SDK tools in the same process.

MCP shines for reusable, cross-client integrations. It is the wrong shape for
"just add a function my agent can call."

### 4. MCP versus direct SDK tools — how do you pick?

**Answer:** Direct SDK tools live in your application code, share your typing,
and are the fastest path when the tool is specific to this app. MCP tools live
behind a protocol boundary, which buys reusability and process isolation at the
cost of an extra hop and a less flexible schema.

A good rule: if the tool logic would ship in a separate service anyway, wrap
it in MCP. If it is a thin call into local code, keep it as a direct SDK tool.

### 5. How do you version MCP servers across clients?

**Answer:** Treat the server contract like any public API: semantic versioning,
additive changes by default, and never rename or remove a tool without a
deprecation window. Clients cache tool descriptions and may pin versions, so
breaking a schema mid-flight can strand assistants that were mid-conversation.
Publish a changelog and expose a version endpoint the client can read.

For internal deployments, run the old and new server side by side during
cutover and route clients gradually. The alternative is silent tool-call
failures the model will happily paper over.
