# PHP Questions

These questions focus on runtime behavior and production trade-offs rather than
syntax trivia.

## 1. What does `declare(strict_types=1)` do?

It enables strict scalar coercion rules for calls made from that file. For
user-defined function parameters, the caller's mode matters; it does not deeply
validate arrays, external input, or domain constraints. An integer can still be
accepted where a float is declared.

## 2. Why prefer `===` over `==`?

Strict comparison checks both type and value. Loose comparison performs type
juggling, which can make values of different types compare equal. Normalize
input first and use strict comparison for predictable control flow.

## 3. How are PHP arrays different from typical arrays?

They are ordered maps and can contain integer and string keys. They support list
and dictionary behavior but have significant per-element overhead. Stable
structured data often reads better as a typed object.

## 4. What is copy-on-write?

Assigned arrays and strings can share underlying storage until one value is
modified. Mutation may then allocate a copy. Passing a large array by value is
not automatically a full copy, but mutation and retained references still affect
memory.

## 5. How do closure captures work?

A normal closure explicitly captures outer variables with `use`, by value unless
`&` is used. An arrow function automatically captures referenced outer variables
by value. Objects captured by value still refer to the same object instance.

## 6. When should a generator be used?

Use a generator for single-pass lazy production when materializing every value
would be wasteful. It shifts execution to iteration time and does not by itself
guarantee a database driver or upstream source is streaming.

## 7. What does readonly guarantee?

It prevents reassignment of the property after valid initialization. It is
shallow: a mutable object stored in a readonly property can still change its own
internal state.

## 8. Interface, abstract class, or trait?

An interface declares a role, an abstract class shares a base contract and
implementation within a genuine hierarchy, and a trait injects implementation
into unrelated classes. Composition is usually clearer when behavior has state
or dependencies.

## 9. Why use constructor injection?

It makes required dependencies visible, supports immutable references and plain
unit tests, and separates object construction from behavior. Pulling services
from a global container hides the real contract.

## 10. What is the difference between `composer install` and `update`?

`update` resolves version constraints and changes the lock file. `install` uses
the versions already locked. Applications should commit the lock file and deploy
with `install`, not resolve a new graph in production.

## 11. Why declare PHP extensions in `composer.json`?

PHP installations differ. Declaring `ext-*` requirements lets Composer reject an
incompatible environment before the application reaches missing-function or
behavior failures at runtime.

## 12. How does a typical PHP-FPM request work?

A web server accepts the connection and forwards dynamic work to an available
FPM worker. The worker boots or invokes the application, returns the response,
and cleans up request state. The worker process and OPcache can survive for later
requests.

## 13. What changes in a long-running PHP runtime?

Statics, singletons, container services, open transactions, locale, and retained
objects can survive between requests or jobs. Code must reset request-scoped
state and use clients designed for the runtime's concurrency model.

## 14. Do Fibers make PHP I/O asynchronous?

No. A Fiber can suspend and resume execution, but scheduling and non-blocking I/O
come from an event-loop or coroutine library. A blocking driver still blocks the
thread.

## 15. How should SQL injection be prevented?

Use prepared statements for values and fixed allowlists for identifiers or sort
directions. Placeholders cannot represent arbitrary SQL syntax. Application
validation is useful but is not an injection defense by itself.

## 16. How should concurrent database updates be protected?

Choose database constraints, conditional updates, version columns, row locks,
and isolation based on the invariant. Keep transactions short and retry only
whole, idempotent transactions for recognized transient conflicts.

## 17. Why is `unserialize()` dangerous for untrusted data?

It can instantiate available classes and invoke deserialization-related magic
methods, enabling object injection chains. Use a data-only format such as JSON
and validate its decoded structure.

## 18. What is OPcache?

OPcache stores compiled bytecode in shared memory so workers avoid parsing and
compiling scripts on every request. It needs capacity monitoring and a deployment
strategy for code invalidation or worker replacement.

## 19. How should FPM worker count be chosen?

Measure memory per worker, CPU, request duration, traffic concurrency, and the
database or remote connection budget. Too few workers cause queueing; too many
can exhaust memory and overwhelm downstream systems.

## 20. What makes a production PHP service reliable?

Use a supported runtime, locked dependencies, strict configuration, OPcache,
bounded FPM and worker pools, safe errors, prepared queries, secure sessions,
timeouts, observability, graceful deployment, compatible migrations, and tested
backup restoration.

