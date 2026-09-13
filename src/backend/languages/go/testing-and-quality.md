# Testing and Code Quality

Go's test tooling lives alongside the language toolchain. Good tests verify
behavior at the narrowest realistic boundary, run independently, and make
concurrency and cleanup failures visible.

## Table-Driven Tests

Tables keep related cases consistent without hiding their differences:

```go
func TestNormalizeEmail(t *testing.T) {
    tests := []struct {
        name  string
        input string
        want  string
    }{
        {name: "trims spaces", input: " user@example.com ", want: "user@example.com"},
        {name: "lowercases domain", input: "user@EXAMPLE.COM", want: "user@example.com"},
        {name: "keeps empty", input: "", want: ""},
    }

    for _, test := range tests {
        t.Run(test.name, func(t *testing.T) {
            got := NormalizeEmail(test.input)
            if got != test.want {
                t.Fatalf("NormalizeEmail(%q) = %q; want %q", test.input, got, test.want)
            }
        })
    }
}
```

Give cases names that describe behavior. Use subtests when filtering, parallel
execution, or separate failure reporting is valuable—not for every assertion.

## Test Helpers

Call `t.Helper()` so failures point to the caller:

```go
func requireNoError(t *testing.T, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}
```

Use `t.Cleanup()` immediately after acquiring a test resource. Cleanup runs even
when the test fails through `Fatal` or returns early.

Keep helpers typed and focused. A large assertion framework can hide the value
comparison or context needed to diagnose a failure.

## Fakes and Interfaces

Small consumer-owned interfaces make test fakes simple:

```go
type fakeUserFinder struct {
    user User
    err  error
}

func (f fakeUserFinder) FindByID(context.Context, string) (User, error) {
    return f.user, f.err
}
```

A fake must preserve semantics that matter to the test. An in-memory repository
may not reproduce transaction isolation, uniqueness constraints, or SQL
behavior, so verify those with the real database engine.

## Integration Tests

Integration tests should use isolated, production-like dependencies and known
initial state. Apply real migrations, clean up deterministically, and avoid
depending on test order.

Use build tags or separate commands when expensive tests should not run in the
fast default suite. CI should still run them on a defined path.

For HTTP handlers, `httptest` can exercise request and response behavior without
opening an external network port. Use a real server when connection behavior,
timeouts, streaming, or shutdown is under test.

## Parallel Tests

`t.Parallel()` improves suite time only when cases do not share mutable globals,
ports, database rows, environment variables, or resource limits.

Parallel tests can reveal unsafe test design. Give each case unique resources
and avoid process-wide configuration changes when concurrent execution is
possible.

## Race Detection

Run the race detector on unit and representative integration tests:

```text
go test -race ./...
```

It detects races that occur in executed code paths; it is not a proof that
unexecuted paths are race-free. Race-enabled binaries use more time and memory,
so plan CI capacity accordingly.

## Fuzzing

Fuzz tests explore generated inputs and retain values that trigger failures:

```go
func FuzzParseToken(f *testing.F) {
    f.Add("valid-token")

    f.Fuzz(func(t *testing.T, input string) {
        token, err := ParseToken(input)
        if err == nil && token.String() == "" {
            t.Fatal("successful parse returned an empty token")
        }
    })
}
```

Fuzz parsers, decoders, protocol state, and functions with strong invariants.
A fuzz target should be deterministic, bounded, and free from uncontrolled
external I/O.

## Golden Files

Golden files work for stable serialized output, generated code, and complex
rendering. Review updates as code changes; never make tests rewrite expectations
silently during normal execution.

Normalize nondeterministic fields such as timestamps, map order, and generated
IDs before comparison.

## Static Quality Checks

A practical CI sequence includes:

1. formatting verification;
2. `go vet` and project linters;
3. unit and integration tests;
4. race-enabled tests for concurrency-sensitive paths;
5. vulnerability and dependency checks;
6. a production build and artifact smoke test.

Linters should catch real risks without forcing complicated workarounds. Keep
the configuration versioned and upgrade rules deliberately.

## Stable Test Rules

- Use explicit inputs and expected outcomes.
- Avoid real sleeps; coordinate with channels or inject time.
- Do not depend on public internet access.
- Close servers, bodies, files, pools, and goroutines.
- Test errors, cancellation, duplicate messages, and shutdown.
- Include enough failure context to diagnose the case.
- Test observable behavior rather than unexported implementation details.
