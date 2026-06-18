# Languages

Language-specific notes, interview questions, and backend engineering
references.

## Pages

- [Go](go.md)
- [JavaScript](javascript.md)
- [TypeScript](type-script.md)
- [PHP](php.md)
- [Python](python.md)

## Mid/Senior Interview Questions and Answers

### 1. How do you choose a backend programming language for a service?

**Answer:** Evaluate team expertise, ecosystem, runtime performance,
concurrency model, operational tooling, hiring pool, library support, and
compatibility with existing systems.

The best choice is context-specific. A language that is excellent for high
concurrency services may not be ideal for data science workflows or a team with
different expertise.

### 2. What language knowledge matters beyond syntax?

**Answer:** Senior engineers need to understand runtime behavior, memory model,
error handling, concurrency primitives, package management, testing tools,
profiling, deployment, and production failure modes.

Syntax is the entry point. Runtime and ecosystem behavior determine production
quality.

### 3. How do typed and dynamically typed languages affect backend design?

**Answer:** Static typing catches many mistakes before runtime and improves
large-codebase refactoring. Dynamic typing can improve iteration speed but needs
strong tests and runtime validation at boundaries.

Both styles can produce reliable systems when validation, testing, and code
ownership are disciplined.
