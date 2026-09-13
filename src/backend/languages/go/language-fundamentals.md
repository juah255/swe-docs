# Language Fundamentals

Go is statically typed and uses value semantics by default. Assigning a value,
passing it to a function, or returning it normally copies that value. Some
values, such as slices, maps, channels, functions, and pointers, contain
references to shared runtime data.

## Declarations and Zero Values

Variables declared without an initializer receive their zero value:

```go
var attempts int       // 0
var enabled bool       // false
var name string        // ""
var user *User         // nil
var labels []string    // nil slice
var metadata map[string]string // nil map
```

Design types so their zero value is useful when practical. `sync.Mutex`,
`bytes.Buffer`, and many standard-library types follow this principle.

Use `:=` for short declarations inside functions and `var` when the zero value
or an explicit type communicates intent. Package-level mutable variables should
be rare because they hide dependencies and complicate tests.

## Constants

Constants are evaluated at compile time and can be untyped until context gives
them a concrete type:

```go
const defaultPort = 8080
const requestTimeout = 5 * time.Second
```

Untyped numeric constants can represent values more precisely than runtime
numeric variables. Conversion to a concrete type must still fit that type.

Use `iota` for related constants only when generated numeric values are part of
the design. String values are often clearer in logs and external protocols.

## Structs

Structs group named fields into a value:

```go
type User struct {
    ID        string
    Email     string
    CreatedAt time.Time
}
```

Exported names begin with an uppercase letter. This also affects reflection,
JSON encoding, database mappers, and other packages.

Prefer keyed struct literals outside the defining package:

```go
user := User{
    ID:    "user-123",
    Email: "reader@example.com",
}
```

Keyed literals remain readable and do not depend on field order.

## Methods and Receivers

A method belongs to a named receiver type:

```go
type Account struct {
    balance int64
}

func (a *Account) Debit(amount int64) error {
    if amount <= 0 {
        return errors.New("amount must be positive")
    }
    if amount > a.balance {
        return ErrInsufficientFunds
    }
    a.balance -= amount
    return nil
}
```

Use a pointer receiver when the method mutates the receiver, the value is large,
or copying would be unsafe. Use a value receiver for small immutable-style
values. Keep the receiver style consistent across a type unless there is a
clear reason not to.

A pointer does not imply ownership. Document whether a function retains or
mutates referenced data when the behavior is not obvious.

## Composition and Embedding

Go favors composition. Struct embedding promotes fields and methods but does
not create subtype inheritance:

```go
type AuditFields struct {
    CreatedAt time.Time
    UpdatedAt time.Time
}

type Order struct {
    AuditFields
    ID string
}
```

Use embedding when the promoted API is intentionally part of the outer type.
A named field is clearer when callers should see the relationship explicitly.

## Control Flow

Go has one loop keyword, `for`, which covers counted loops, conditions, and
iteration. `switch` cases do not fall through by default.

```go
for _, job := range jobs {
    if err := process(job); err != nil {
        return fmt.Errorf("process job %s: %w", job.ID, err)
    }
}
```

The blank identifier discards a value intentionally. Use early returns to keep
the successful path readable.

## Multiple Return Values

Multiple returns make results and errors explicit:

```go
func FindUser(id string) (User, error) {
    // The zero User value accompanies an error on failure.
    return User{}, ErrNotFound
}
```

Document whether a non-zero result may accompany an error. Most APIs make the
result unusable when the error is non-nil.

The two-value form distinguishes a missing map key or failed assertion from a
present zero value:

```go
role, ok := roles[userID]
if !ok {
    return ErrRoleNotAssigned
}
```

## Initialization

Package variables are initialized before `init` functions, and imported
packages initialize before their importers. Avoid important I/O, goroutine
startup, or hidden registration in `init`. Explicit construction is easier to
test, order, and shut down.

## Practical Rules

- Make the zero value useful when it fits the domain.
- Prefer explicit dependencies over package globals.
- Use pointer receivers deliberately and consistently.
- Compose small types instead of building inheritance-like hierarchies.
- Keep initialization cheap and free from hidden external work.
