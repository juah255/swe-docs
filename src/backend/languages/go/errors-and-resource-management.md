# Errors and Resource Management

Go treats errors as ordinary values. Callers inspect, wrap, translate, or return
them explicitly. Cleanup is commonly paired with acquisition through `defer`.

## Return Useful Errors

Put the error last in a function's return values and add operation context as it
moves upward:

```go
user, err := repository.FindByID(ctx, id)
if err != nil {
    return User{}, fmt.Errorf("find user %q: %w", id, err)
}
```

Use `%w` when callers may need the underlying error. Use `%v` when intentionally
ending the inspection chain.

Do not add the same vague context at every layer. Each wrapper should help an
operator or caller understand which operation failed.

## Inspecting Wrapped Errors

Use `errors.Is` for a target error and `errors.As` for a particular error type:

```go
if errors.Is(err, sql.ErrNoRows) {
    return User{}, ErrUserNotFound
}

var validationErr *ValidationError
if errors.As(err, &validationErr) {
    return writeValidationResponse(w, validationErr)
}
```

Direct equality and type assertions do not reliably inspect a wrapped chain.

## Sentinel and Typed Errors

A sentinel is a package-level error value callers can compare with `errors.Is`:

```go
var ErrUserNotFound = errors.New("user not found")
```

Use sentinels for stable categories without additional data. Use a custom type
when callers need structured fields. Every exported error becomes part of the
package contract, so expose only distinctions callers can act on.

Error message text is for humans, not programmatic control flow.

## Translating at Boundaries

Infrastructure errors should not leak through every layer. An adapter can map a
database-specific missing-row error into a domain or application error. An HTTP
boundary can then map known application errors to stable status codes.

Log an error once where request, job, or process context is available. Repeated
log-and-return patterns create duplicate events while losing the ownership of
the final outcome.

## `defer`

A deferred call runs when the surrounding function returns. Deferred calls run
in last-in, first-out order:

```go
rows, err := database.QueryContext(ctx, query)
if err != nil {
    return err
}
defer rows.Close()
```

Arguments to a deferred function call are evaluated when the `defer` statement
runs, not later during cleanup.

Check cleanup errors when they can affect correctness, particularly flushing,
committing, and closing a file being written. A small named cleanup function is
often clearer than complex deferred inline logic.

## Cleanup Inside Loops

A `defer` belongs to the surrounding function, not the loop iteration. Repeated
defers in a long loop can keep resources open until the function returns.

Move one iteration into a helper function so its deferred cleanup runs promptly:

```go
func processFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()

    return decode(file)
}
```

## Panic and Recover

Use panic for unrecoverable programmer errors or impossible initialization
states, not ordinary invalid input or dependency failure. Libraries generally
should return errors that let the application choose a policy.

`recover` works only in a deferred function on the same goroutine that is
panicking. A server boundary may recover to record a stack and prevent one
handler panic from crashing unrelated requests. It should not pretend an
unknown partial operation succeeded.

Do not use panic and recover as exception-style control flow.

## Cleanup With Context

Pass context into blocking operations so cancellation can release connections
and goroutines. `defer cancel()` after deriving a context to release its timer
and related resources:

```go
ctx, cancel := context.WithTimeout(parent, 2*time.Second)
defer cancel()

return client.Call(ctx, request)
```

The child timeout should fit inside the caller's remaining deadline.

## Practical Rules

- Add actionable context and preserve inspectable causes.
- Use `errors.Is` and `errors.As` across wrapped chains.
- Export only error categories callers need to distinguish.
- Pair resource acquisition with immediate cleanup planning.
- Reserve panic recovery for deliberate process or request boundaries.
- Never expose raw internal errors directly to API clients.
