# Functions, Closures, and Generators

## Function Design

Functions can declare parameter and return types, defaults, variadic arguments,
and references. Keep required parameters first and avoid boolean flags whose
meaning is unclear at the call site.

```php
function createInvoice(
    CustomerId $customerId,
    iterable $lines,
    InvoiceOptions $options = new InvoiceOptions(),
): Invoice {
    // ...
}
```

Default object expressions require a compatible PHP version. For widely shared
libraries, choose syntax from the declared minimum platform.

## Named Arguments

Named arguments improve selected calls:

```php
$result = search(query: 'php', limit: 20, includeArchived: false);
```

They make parameter names part of compatibility. Use them deliberately for
stable APIs, and do not combine them with an assumption that parameters can be
renamed freely in a future release.

## Closures and Captures

Anonymous functions can capture outer variables with `use`:

```php
$minimum = 100;

$eligible = array_filter(
    $orders,
    static function (Order $order) use ($minimum): bool {
        return $order->total()->minorUnits() >= $minimum;
    },
);
```

Normal captures are by value at closure creation time. Add `&` to capture by
reference, but shared mutation makes behavior harder to reason about.

Arrow functions have concise expression bodies and automatically capture used
outer variables by value:

```php
$ids = array_map(
    static fn (Order $order): string => $order->id()->toString(),
    $orders,
);
```

Mark a closure `static` when it does not need `$this`; that makes the dependency
explicit and avoids binding the object unnecessarily.

## First-Class Callables

PHP can turn a function or method into a `Closure`:

```php
$normalize = trim(...);
$formatter = $invoiceFormatter->format(...);
```

Use callable types for local behavior injection. For a long-lived architectural
contract, a named interface often communicates intent and supports analysis
better than a generic `callable`.

## References

Passing or returning by reference creates an alias to the same variable. It is
different from passing an object handle and is rarely needed in application
APIs. References interact subtly with loops, arrays, and reassignment, so prefer
return values or mutable objects with explicit behavior.

## Generators

A function containing `yield` returns a `Generator` and suspends between values:

```php
/** @return Generator<int, Order> */
function orders(PDO $pdo): Generator
{
    $statement = $pdo->query('SELECT id, status FROM orders ORDER BY id');

    while ($row = $statement->fetch(PDO::FETCH_ASSOC)) {
        yield hydrateOrder($row);
    }
}
```

Generators avoid building one large PHP array. They do not guarantee the
database driver streams rows or releases server resources early; driver buffering
and cursor behavior still matter.

Generators are single-pass iterators. Work happens during iteration, so errors
and resource use may occur far from the function call. Document that laziness
when it affects transaction or connection lifetime.

## Iterables and Collections

Accept `iterable` when code can consume arrays and traversable objects one pass
at a time. Return a concrete collection when callers need stable indexing,
counting, repeated iteration, or collection-specific behavior.

Built-in `array_map`, `array_filter`, and `array_reduce` are expressive for small
in-memory arrays, but each may allocate another array. A straightforward loop or
generator can be clearer and more memory-efficient for a hot or large path.

