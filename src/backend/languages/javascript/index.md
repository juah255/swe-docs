# JavaScript for Backend Engineering

JavaScript powers backend services through Node.js as well as applications in
the browser. Backend engineers need to understand both the language and the
runtime: values and coercion, closures and prototypes, promises and the event
loop, modules, streams, memory, testing, and production operations.

## Why JavaScript Works Well on the Backend

- One language can be shared across browser, server, and tooling code.
- Node.js is well suited to services that spend much of their time waiting for
  databases, APIs, queues, and file or network I/O.
- The package ecosystem covers web frameworks, observability, databases,
  automation, and build tooling.
- JSON maps naturally to JavaScript values, making it convenient for web APIs.
- A mature stream model supports large files, uploads, proxies, and data
  pipelines without loading everything into memory.

The trade-off is that compact syntax can hide coercion, asynchronous ordering,
and unbounded work. Reliable services make types, resource limits, timeouts,
and error ownership explicit.

## Subtopics

- [Language Fundamentals](fundamentals.md) — values, equality, scope,
  destructuring, optional chaining, and common language pitfalls.
- [Functions, Objects, and Prototypes](functions-objects-and-prototypes.md) —
  closures, `this`, classes, prototypes, and composition.
- [Promises, Async/Await, and the Event Loop](async-and-event-loop.md) — task
  ordering, concurrent operations, cancellation, and bounded concurrency.
- [Node.js Runtime and Modules](node-runtime-and-modules.md) — runtime APIs,
  CommonJS, ES modules, package metadata, imports, and project structure.
- [Streams and Data Processing](streams-and-data-processing.md) — readable and
  writable streams, backpressure, pipelines, and large payloads.
- [Errors and Reliability](errors-and-reliability.md) — error propagation,
  timeouts, retries, idempotency, and process-level failures.
- [Testing and Code Quality](testing-and-quality.md) — test boundaries,
  dependency control, static analysis, and stable test suites.
- [Performance and Memory](performance-and-memory.md) — event-loop health,
  garbage collection, leaks, profiling, and CPU-heavy work.
- [Production Node.js Services](production-node-services.md) — workers, pools,
  security, observability, graceful shutdown, and deployment.
- [JavaScript Questions](questions.md) — concise mid- and senior-level
  interview questions and answers.

## Core Vocabulary

| Term | Meaning |
| --- | --- |
| **Runtime** | The environment that executes JavaScript and provides APIs beyond the language. Node.js is a server-side runtime. |
| **Event loop** | The runtime mechanism that schedules callbacks as timers, I/O, and other work become ready. |
| **Promise** | An object representing the eventual fulfillment or rejection of an asynchronous operation. |
| **Closure** | A function together with access to the lexical environment where it was created. |
| **Prototype** | An object used as another object's fallback for property lookup. |
| **Stream** | An interface for processing data incrementally instead of buffering it all at once. |
| **Backpressure** | Flow control that slows a producer when a consumer cannot keep up. |

## Suggested Learning Path

1. Learn values, scope, equality, coercion, collections, and errors.
2. Practice functions, closures, object composition, prototypes, and classes.
3. Understand promises, `async`/`await`, task ordering, and cancellation.
4. Learn Node.js modules, package boundaries, streams, and runtime APIs.
5. Add automated tests, linting, and repeatable dependency management.
6. Study event-loop health, worker capacity, observability, and shutdown.

After the language foundations, continue with [NestJS](../../libraries-frameworks/nestjs/index.md)
or [Next.js](../../libraries-frameworks/nextjs/index.md) for framework-specific
patterns.
