# Node.js Runtime and Modules

Node.js combines the JavaScript engine with runtime APIs for networking, files,
processes, streams, workers, and modules. A backend project should declare its
runtime assumptions and use one predictable module and dependency strategy.

## Runtime Responsibilities

The JavaScript engine executes language code and manages objects and garbage
collection. Node.js adds facilities such as:

- an event loop and asynchronous I/O;
- HTTP, TCP, DNS, file-system, and stream APIs;
- process signals, environment variables, and standard input/output;
- a worker-thread API for CPU-bound JavaScript;
- CommonJS and ECMAScript module loading.

Some asynchronous APIs use operating-system facilities, while others use a
runtime-managed worker pool. Application callbacks return to the JavaScript
thread when their work is ready.

## ECMAScript Modules

ES modules use `import` and `export`:

```js
import { readFile } from "node:fs/promises";
import { parseConfig } from "./config.js";

export async function loadConfig(path) {
  return parseConfig(await readFile(path, "utf8"));
}
```

They are statically analyzable, support top-level `await`, and use URL-based
module resolution. Relative imports normally include the file extension.

A package can opt into ES module interpretation with `"type": "module"` in
`package.json`. The `.mjs` and `.cjs` extensions can mark individual files
explicitly.

## CommonJS

CommonJS uses `require()` and `module.exports`:

```js
const { readFile } = require("node:fs/promises");

module.exports = { loadConfig };
```

It remains common in older Node.js projects and packages. CommonJS and ES module
interop has edge cases around default exports, named exports, file paths, and
loading behavior. Pick one primary system for a new service and test any
boundary with legacy packages.

## Package Metadata

`package.json` describes the package and its operational contract:

```json
{
  "name": "billing-service",
  "private": true,
  "type": "module",
  "engines": {
    "node": ">=22"
  },
  "scripts": {
    "start": "node src/server.js",
    "test": "node --test"
  }
}
```

Applications should normally be private packages. Declare the supported Node.js
range, commit the lock file, and run installation in CI in a mode that refuses
to rewrite it.

Keep runtime dependencies separate from development-only tooling. Add a package
as a direct dependency when production code imports or requires it; do not rely
on it appearing transitively through another package.

## A Service Layout

One practical structure is:

```text
project/
├── package.json
├── package-lock.json
├── src/
│   ├── api/
│   ├── application/
│   ├── domain/
│   ├── infrastructure/
│   ├── config.js
│   └── server.js
└── test/
    ├── unit/
    └── integration/
```

Small services do not need empty architectural layers. Split code when doing so
expresses an ownership or dependency boundary.

## Side Effects and Module Caching

A module's top-level code runs as it is loaded, and loaded modules are cached.
Avoid connecting to services, starting timers, or listening on a port during
import. Export factories or startup functions instead:

```js
export function createUserService({ users, logger }) {
  return new UserService({ users, logger });
}
```

Explicit construction makes tests independent and resource shutdown possible.
It also avoids hidden singleton state shared across every importer.

## Configuration

Read configuration at the application boundary, validate it once, and pass a
typed or well-defined configuration object inward.

- Keep secrets outside source control and deployment artifacts.
- Distinguish build-time from runtime configuration.
- Fail at startup when required values are missing or malformed.
- Do not spread `process.env` access throughout business code.
- Never log complete environment or configuration objects.

Environment variables are strings when present; parse numbers and Boolean
values explicitly.

## Dependency Hygiene

- Prefer packages with maintained source, clear ownership, and a narrow purpose.
- Review install scripts and avoid unnecessary packages.
- Update dependencies regularly in small, testable batches.
- Run vulnerability and license checks appropriate to the organization.
- Keep the runtime and lock file consistent across development, CI, and
  deployment.

The package ecosystem is a strength, but every dependency adds supply-chain,
maintenance, startup, and compatibility cost.
