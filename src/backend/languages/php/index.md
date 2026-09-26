# PHP for Backend Engineering

PHP is a server-side language designed around web development, while also being
used for command-line tools, queue workers, scheduled jobs, and long-running
services. Its ecosystem includes Composer, interoperable PSR interfaces, mature
frameworks, content platforms, testing tools, and static analyzers.

Modern PHP is a typed, object-oriented language with closures, attributes,
enums, readonly state, generators, fibers, and an evolving type system. It
remains dynamically checked at runtime: declarations and static analysis improve
safety, but untrusted input still needs explicit parsing and validation.

## Why PHP Works Well on the Backend

- The traditional request model offers simple isolation between requests.
- PHP-FPM, web servers, containers, and hosting platforms are widely supported.
- Composer provides package resolution and standardized autoloading.
- Frameworks such as Laravel and Symfony supply mature application tooling.
- PHP-FIG interfaces make logging, caching, HTTP, and containers interoperable.
- OPcache and modern runtimes provide strong performance for web workloads.

PHP's flexibility is also a risk. Implicit coercion, arrays used for every data
shape, global state, and framework shortcuts can hide contracts. Prefer clear
types, immutable value objects where useful, explicit boundaries, and automated
analysis.

## A Typical Request

```text
client
  -> reverse proxy / web server
  -> PHP-FPM worker or application server
  -> front controller and Composer autoloader
  -> middleware and router
  -> controller / request handler
  -> application service
  -> database, cache, queue, or remote API
  -> HTTP response
```

Under PHP-FPM, the process survives but ordinary request state is discarded at
the end of the request. OPcache can retain compiled bytecode. Long-running
runtimes have different state and lifecycle rules, so code written for them must
reset request-scoped data deliberately.

## Subtopics

- [Language Fundamentals](language-fundamentals.md) — syntax, values, arrays,
  comparisons, control flow, and namespaces.
- [Type System](type-system.md) — strict types, unions, intersections, `mixed`,
  `never`, PHPDoc types, and boundary validation.
- [Functions, Closures, and Generators](functions-closures-and-generators.md) —
  callables, captures, named arguments, iterables, and lazy processing.
- [Object-Oriented PHP](object-oriented-php.md) — classes, interfaces, traits,
  enums, readonly state, composition, and dependency injection.
- [Errors and Resource Management](errors-and-resource-management.md) —
  `Throwable`, handlers, cleanup, error boundaries, and reliable failure paths.
- [Composer and Project Structure](composer-and-project-structure.md) — package
  management, PSR-4, lock files, platform requirements, and module boundaries.
- [Web Runtime and Concurrency](web-runtime-and-concurrency.md) — SAPIs, HTTP,
  sessions, FPM, fibers, event loops, workers, and request-scoped state.
- [Database and Persistence](database-and-persistence.md) — PDO, prepared
  statements, transactions, concurrency, ORMs, and migrations.
- [Security](security.md) — injection, escaping, CSRF, sessions, passwords,
  uploads, deserialization, SSRF, and secrets.
- [Testing and Code Quality](testing-and-code-quality.md) — unit and integration
  tests, static analysis, style automation, fixtures, and test design.
- [Performance and Memory](performance-and-memory.md) — OPcache, profiling,
  copy-on-write values, generators, pools, caching, and evidence-driven tuning.
- [Production PHP Services](production-php-services.md) — deployment, FPM,
  configuration, observability, queues, health, and graceful operations.
- [PHP Questions](questions.md) — concise mid- and senior-level review questions.

## Version Awareness

Several PHP release branches are supported at the same time. Newer syntax such
as property hooks, asymmetric visibility, or the pipe operator may not be
available on the project's minimum version. Declare the supported PHP version
and extensions in `composer.json`, test that matrix, and read the migration guide
before upgrading.

## Suggested Learning Path

1. Learn scalar values, arrays, comparisons, functions, and control flow.
2. Add strict declarations, value objects, exceptions, and clear interfaces.
3. Learn Composer, PSR-4 autoloading, testing, and static analysis.
4. Build an HTTP application with safe database and session boundaries.
5. Study memory, FPM, queues, caching, observability, and production deployment.

