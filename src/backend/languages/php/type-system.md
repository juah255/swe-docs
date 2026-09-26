# Type System

PHP checks declared types at runtime. Static analyzers can infer richer contracts
before execution, but the runtime remains the final enforcement point for native
declarations.

## Scalar and Object Types

Common native types include `int`, `float`, `string`, `bool`, `array`, `object`,
`iterable`, `callable`, class and interface names, `self`, `parent`, and `static`.
Special return types include `void` and `never`.

```php
function subtotal(int $quantity, Money $unitPrice): Money
{
    return $unitPrice->multiply($quantity);
}
```

A `float` parameter accepts an integer because widening an integer to a float is
allowed even under strict typing. Native `array` says nothing about key and value
types; use domain objects or static-analysis annotations for richer contracts.

## Strict Types

```php
declare(strict_types=1);
```

Strict mode controls scalar coercion per file. For user-defined function calls,
the caller's file determines how argument scalar types are handled. This means a
strictly declared library can still receive coerced arguments from a non-strict
caller. Return checking follows the function's declaring file.

Strict types do not:

- parse an HTTP string into a domain value;
- validate the contents of an array;
- guarantee a string is non-empty or an integer is positive;
- replace database constraints or authorization;
- turn PHP into a compile-time typed language.

Validate external values, then pass trusted typed values inward.

## Nullable, Union, and Intersection Types

```php
function find(string $id): User|null
{
    // ...
}

function render(Stringable&JsonSerializable $value): string
{
    // ...
}
```

`?User` is shorthand for `User|null`. A union accepts one of its member types;
an intersection requires all listed interfaces or classes. Modern PHP also
supports combinations in disjunctive normal form where the target version
allows it.

Use unions when callers genuinely need multiple forms. A wide union can signal
that parsing or object design has been deferred.

## `mixed`, `void`, and `never`

- `mixed` explicitly permits any value, including `null`.
- `void` means the function returns no useful value; it may return without a
  value.
- `never` means the function cannot complete normally because it always throws,
  exits, or otherwise terminates control flow.

Prefer `mixed` at an unavoidable untyped boundary, narrow immediately, and avoid
letting it spread through application code.

## Value Objects

Native types often permit invalid domain values. A value object can validate
once and carry meaning:

```php
final readonly class EmailAddress
{
    public function __construct(public string $value)
    {
        if (filter_var($value, FILTER_VALIDATE_EMAIL) === false) {
            throw new InvalidArgumentException('Invalid email address');
        }
    }
}
```

Keep validation appropriate to the domain. An email validator can check syntax;
it cannot prove identity or deliverability.

## PHPDoc and Static Analysis

PHPDoc can describe generics, array shapes, non-empty strings, numeric ranges,
templates, and conditional returns for tools such as PHPStan and Psalm:

```php
/**
 * @param list<OrderLine> $lines
 * @return non-empty-list<OrderLine>
 */
function validatedLines(array $lines): array
{
    // ...
}
```

These contracts are not enforced by the PHP runtime unless application code
checks them. Keep annotations aligned with implementation and prefer native
types when they can express the same constraint.

## Variance and API Design

Method compatibility may allow parameter contravariance and return covariance.
In practice, design around substitutable interfaces: an implementation must
accept everything promised by the interface and return at least what callers
expect.

Avoid changing public parameter names casually in libraries because callers can
use named arguments. Types, defaults, exceptions, side effects, and parameter
names all form part of a public API contract.

