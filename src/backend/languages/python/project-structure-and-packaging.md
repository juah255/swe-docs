# Project Structure and Packaging

A predictable project layout makes imports, tests, deployments, and ownership
easier to understand. The exact folder names matter less than clear boundaries
and one consistent way to build and run the application.

## Modules and Packages

A Python file is a **module**. A directory of importable modules is a
**package**. Prefer absolute imports across application areas and relative
imports only for tightly related code within a package.

Imports execute a module's top-level code the first time it is loaded in a
process. Keep top-level work cheap and deterministic: importing a module should
not connect to a database, make an HTTP request, or start a worker.

## A Service Layout

One practical layout is:

```text
project/
├── pyproject.toml
├── README.md
├── src/
│   └── billing_service/
│       ├── __init__.py
│       ├── api/
│       ├── application/
│       ├── domain/
│       ├── infrastructure/
│       └── settings.py
└── tests/
    ├── unit/
    └── integration/
```

The `src` layout helps prevent tests from accidentally importing the repository
folder instead of the installed package. Small services do not need many empty
layers; add structure when there is a real boundary to express.

## Separate Responsibilities

A common dependency direction is:

```text
HTTP/CLI adapter -> application use case -> domain rules
                         |
                         v
                repository/service interface
                         ^
                         |
                infrastructure adapter
```

- **API layer** translates HTTP input and output.
- **Application layer** coordinates use cases and transaction boundaries.
- **Domain layer** holds business rules with minimal framework coupling.
- **Infrastructure layer** implements database and external-service adapters.

This is a guide, not a requirement to create a class for every operation.

## `pyproject.toml`

Modern projects can keep build metadata and tool configuration in
`pyproject.toml`:

```toml
[build-system]
requires = ["setuptools>=75"]
build-backend = "setuptools.build_meta"

[project]
name = "billing-service"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = []
```

The chosen build backend and dependency manager may add their own sections.
Commit the lock file for an application so CI and deployments resolve the same
dependency versions. Libraries usually publish compatible ranges, while their
test environments should still lock exact versions.

## Environments and Dependencies

Use an isolated virtual environment for each project. Separate runtime
dependencies from development tools and optional features. Keep the direct
dependency list small; transitive dependencies come from those packages and
should not be added as direct dependencies unless the application imports or
configures them explicitly.

Dependency updates should be routine and reviewed. Run tests, static checks,
and vulnerability scanning against the resolved dependency set.

## Configuration

Configuration should enter through a defined boundary, be parsed once, and
produce a typed settings object.

- Keep non-secret defaults in code or configuration files.
- Supply environment-specific values through the deployment platform.
- Store secrets in a secret manager, not in source control.
- Validate required values at startup and fail with a useful message.
- Avoid reading environment variables throughout business logic.

Never log the complete configuration object if it may contain credentials.

## Import Cycles

A circular import often signals that module responsibilities are tangled. Fix
the dependency direction before reaching for local imports as a permanent
workaround.

Useful approaches include:

- moving shared types to a lower-level module;
- depending on a protocol rather than a concrete adapter;
- moving application wiring to a composition root;
- keeping framework registration separate from domain logic.

## Application Entry Points

Expose a clear factory or command entry point rather than doing work at import
time:

```py
def create_app(settings: Settings) -> Application:
    database = Database(settings.database_url)
    return Application(settings=settings, database=database)
```

Factories allow tests to supply controlled settings and dependencies. They also
make startup order and resource ownership easier to see.

## Packaging Checklist

- Declare the supported Python version.
- Use one reproducible dependency workflow.
- Keep build and tool configuration discoverable.
- Do not rely on manually changing `PYTHONPATH`.
- Include only required files in the deployment artifact.
- Run the same package artifact in test and production when practical.
