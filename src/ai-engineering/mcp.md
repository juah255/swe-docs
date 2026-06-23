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
