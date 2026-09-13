# Modules, Packages, and Project Structure

Packages are Go's unit of encapsulation and compilation. Modules provide a
versioned collection of packages. Clear package boundaries make dependencies,
testing, and ownership easier to understand.

## Packages

Files in one directory normally belong to one package. Exported identifiers
begin with an uppercase letter; all others are package-private.

Name a package after what it provides, not a generic container:

```go
user.Find(...)
http.Server{...}
json.NewEncoder(...)
```

Avoid names such as `util`, `common`, or `helpers` when a cohesive responsibility
can be named. Package documentation should explain purpose and important
contracts rather than repeat identifier names.

## Modules

A `go.mod` file declares the module path, Go language version, and module
requirements. Commit `go.mod` and `go.sum`.

Use module commands to add, update, verify, and tidy dependencies. Review the
resulting module and checksum changes rather than editing dependency versions
casually.

Module paths are part of import identities and public compatibility. A major
version change may require a corresponding version suffix in the module path.

## A Service Layout

One practical layout is:

```text
service/
├── cmd/
│   ├── api/
│   │   └── main.go
│   └── worker/
│       └── main.go
├── internal/
│   ├── account/
│   ├── platform/
│   │   ├── database/
│   │   └── telemetry/
│   └── transport/
│       └── httpapi/
├── migrations/
├── go.mod
└── go.sum
```

This is an example, not a mandatory standard. A small service may need only
`main.go` and a few cohesive packages. Add directories when they establish a
real boundary.

## `internal`

Code under an `internal` directory can be imported only by packages within the
allowed parent tree. This compiler-enforced boundary is useful for application
implementation that should not become a public library accidentally.

Do not put everything under `pkg` merely because some repositories use that
name. Go does not give a top-level `pkg` directory special visibility semantics.

## Commands and Construction

Keep `main` packages small. Their job is to parse configuration, construct
dependencies, register process lifecycle behavior, and start the application:

```go
func run(ctx context.Context, config Config) error {
    database, err := openDatabase(ctx, config.Database)
    if err != nil {
        return err
    }
    defer database.Close()

    server := newServer(config.HTTP, database)
    return serve(ctx, server)
}
```

An explicit `run` function is easier to test than initialization hidden inside
package globals or `init` functions.

## Dependency Direction

Domain and application packages should not need to import HTTP frameworks or
database drivers. Define small interfaces near use cases and implement them in
adapter packages.

Avoid package cycles by fixing responsibility and dependency direction. Moving
unrelated types into a generic shared package often hides the problem rather
than solving it.

## Configuration

Parse environment variables, flags, or files once at startup into a validated
configuration struct. Pass focused configuration to the components that need it.

- Fail early when required values are absent or malformed.
- Keep secrets outside source control.
- Use durations and structured types rather than scattered raw strings.
- Never log the entire environment or configuration object.
- Keep environment access out of domain logic.

## Dependency Selection

The standard library is a strong default, but external packages are appropriate
when they remove substantial, well-understood work. Evaluate maintenance,
security history, API size, transitive dependencies, and compatibility policy.

Wrap important external systems behind application-owned adapters. This avoids
letting a vendor client's types and errors spread throughout the codebase.

## Workspaces and Multi-Module Repositories

A workspace can make local development across several modules convenient. The
module files remain the source of versioned dependency truth; CI should verify
that each module also builds correctly without accidental local-only workspace
resolution.

Use multiple modules only when independent versioning or dependency boundaries
justify the extra release and tooling complexity.

## Project Rules

- Organize packages around cohesive capabilities.
- Keep command packages and initialization explicit.
- Use `internal` for compiler-enforced application boundaries.
- Avoid hidden I/O and goroutines during package initialization.
- Commit and review module metadata.
- Test the same module graph and build entry points used in deployment.
