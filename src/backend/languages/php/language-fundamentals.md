# Language Fundamentals

## Files and Declarations

PHP code begins with `<?php`. In code-only files, omit the closing tag to avoid
accidentally sending whitespace before headers.

```php
<?php

declare(strict_types=1);

namespace App\Catalog;

use DateTimeImmutable;
```

`declare(strict_types=1)` must appear near the beginning of each file where it is
wanted. Namespace declarations prevent global name collisions; `use` imports an
alias into the current file rather than loading the class itself.

## Variables and Values

Variables start with `$` and do not have a separately declared variable type:

```php
$attempts = 3;
$price = 19.95;
$active = true;
$description = null;
$name = 'Ada';
```

Function parameters, returns, properties, and class constants can have type
declarations. Local variables are inferred at runtime and can be reassigned to a
different type, though doing so often makes code harder to understand.

Use `const` or class constants for fixed values. Use `readonly` properties or
classes for state that must not be reassigned after initialization.

## Strings

Single-quoted strings have minimal interpolation; double-quoted strings expand
variables and escape sequences.

```php
$message = "Order {$orderId} accepted\n";
$literal = 'The value is $orderId';
```

Concatenate with `.`, not `+`. PHP strings are byte sequences, not inherently
Unicode character arrays. Use `mb_*` functions or an appropriate Unicode-aware
library when length, case conversion, or slicing must operate on characters.

## Arrays

PHP arrays are ordered maps. They can represent lists, dictionaries, or a mix:

```php
$ids = [10, 20, 30];
$user = [
    'id' => 42,
    'email' => 'ada@example.com',
];
```

This versatility can hide structure and consumes more memory than a packed,
specialized array in many languages. Use arrays for collections and simple local
data. Prefer a class, enum, or typed DTO for stable domain shapes.

Some key rules are surprising: numeric-looking string keys may become integers,
and appending after removal does not necessarily fill a gap. Use `array_is_list()`
when list shape matters.

`isset($data['key'])` is false when the key is absent or its value is `null`.
Use `array_key_exists()` when those states must be distinguished.

## Comparisons and Truthiness

Prefer strict comparison:

```php
if ($status === OrderStatus::Paid) {
    // ...
}
```

Loose `==` comparison applies type juggling and can make values with different
types compare equal. Strict `===` compares both type and value. Validate and
normalize external input before comparison rather than relying on coercion.

Empty strings, `0`, `0.0`, `'0'`, empty arrays, `null`, and `false` are falsey.
That makes a generic truthiness check unsafe when zero is a valid value.

## Control Flow

PHP provides `if`, `switch`, `match`, `for`, `foreach`, `while`, and `do-while`.
`match` uses strict comparison, returns a value, has no fall-through, and should
be exhaustive:

```php
$label = match ($status) {
    OrderStatus::Pending => 'Awaiting payment',
    OrderStatus::Paid => 'Ready to fulfill',
    OrderStatus::Cancelled => 'Cancelled',
};
```

`foreach` normally assigns the current value by value. A by-reference loop can
mutate the source array, but the reference remains after the loop. Unset it to
avoid accidentally changing the final element later:

```php
foreach ($amounts as &$amount) {
    $amount = round($amount, 2);
}
unset($amount);
```

## Null Handling

The null coalescing operator provides a fallback for a missing or null value:

```php
$page = $query['page'] ?? '1';
```

The nullsafe operator stops a property or method chain when the left side is
`null`:

```php
$country = $user->address()?->country();
```

Neither operator validates type or meaning. Parse the page as a bounded positive
integer and report invalid input explicitly.

