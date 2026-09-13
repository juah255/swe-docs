# Interfaces and Generics

Interfaces describe behavior, while generics express relationships across a
family of types. Both are most effective when driven by a concrete consumer
rather than introduced only for abstraction's sake.

## Implicit Interface Satisfaction

A type implements an interface by having its methods; no declaration is
required:

```go
type UserFinder interface {
    FindByID(ctx context.Context, id string) (User, error)
}

type ProfileService struct {
    users UserFinder
}
```

This lets an application package define the small contract it needs while an
infrastructure package supplies the implementation without importing the
consumer.

## Keep Interfaces Small

Prefer interfaces with one or a few cohesive methods. Large provider-owned
interfaces force test doubles and alternate adapters to implement operations
they do not need.

Accept interfaces when multiple behavior-compatible implementations are useful;
return concrete types when callers benefit from the implementation's full API.
Do not create an interface for every struct automatically.

## Method Sets

The method set determines whether a value or pointer satisfies an interface:

- methods with a value receiver belong to the method sets of both `T` and `*T`;
- methods with a pointer receiver belong only to the method set of `*T`.

If an interface requires a pointer-receiver method, a `T` value does not satisfy
it, while `*T` does.

## The Typed-Nil Pitfall

An interface value contains a dynamic type and a dynamic value. It is `nil` only
when both are absent:

```go
func load() error {
    var err *ValidationError
    return err // Non-nil error interface: dynamic type is set.
}
```

Return a plain `nil` when there is no error. Avoid APIs that place typed nil
pointers into interface values.

## Type Assertions and Type Switches

A type assertion extracts a dynamic value:

```go
value, ok := input.(string)
if !ok {
    return fmt.Errorf("expected string, got %T", input)
}
```

Use the two-value form when failure is possible. A single-value failed assertion
panics.

A type switch handles a small, intentional set of runtime types. If application
logic repeatedly switches on implementation types, the interface may be hiding
the wrong behavior.

## The Empty Interface and `any`

`any` is an alias for `interface{}` and can hold a value of any type. It does
not provide type safety; code must use an assertion, switch, reflection, or
decoder to inspect the value.

Use `any` at genuinely dynamic boundaries such as generic JSON trees and
logging fields. Prefer concrete types or type parameters within application
logic.

## Generic Functions

Type parameters preserve relationships without boxing values into interfaces:

```go
func First[T any](items []T) (T, bool) {
    if len(items) == 0 {
        var zero T
        return zero, false
    }
    return items[0], true
}
```

The caller receives the same element type passed in. A type parameter used only
once may not express a useful relationship; a concrete type or interface can be
clearer.

## Constraints

A constraint describes the permitted type arguments and operations:

```go
type Number interface {
    ~int | ~int64 | ~float64
}

func Sum[T Number](values []T) T {
    var total T
    for _, value := range values {
        total += value
    }
    return total
}
```

The `~int` term includes defined types whose underlying type is `int`. Keep
constraints focused on the operations the implementation actually needs.

## `comparable`

The predeclared `comparable` constraint permits types that support `==` and
`!=`, which is required for map keys:

```go
func Index[Key comparable, Value any](
    values []Value,
    key func(Value) Key,
) map[Key]Value {
    result := make(map[Key]Value, len(values))
    for _, value := range values {
        result[key(value)] = value
    }
    return result
}
```

Comparability does not mean a type has meaningful ordering. Ordering needs a
more specific constraint or comparator.

## Interface or Generic?

| Need | Prefer |
| --- | --- |
| Call behavior on different runtime implementations | Interface |
| Preserve input and output types across reusable logic | Generic |
| Store heterogeneous behavior-compatible values | Interface |
| Implement a data structure for many element types | Generic |
| Abstract one concrete implementation with no consumer need | Neither yet |

Interfaces provide runtime polymorphism; generics create compile-time
specialized relationships. They solve different problems and can be used
together.

## Practical Rules

- Define interfaces near consumers.
- Keep method sets small and cohesive.
- Understand pointer receiver method sets and typed nils.
- Use generics when they remove duplication while preserving useful type
  relationships.
- Avoid reflection or `any` when a concrete contract is known.
