# TypeScript for Backend Engineering

TypeScript adds static analysis to JavaScript while preserving JavaScript's
runtime and ecosystem. It is especially valuable in backend codebases where
data crosses HTTP, queue, database, and service boundaries and where safe
refactoring matters over a long project lifetime.

TypeScript does not replace JavaScript knowledge. Types are erased during
compilation, and the generated JavaScript still follows JavaScript and Node.js
runtime behavior.

## Why TypeScript Works Well on the Backend

- Function and module contracts are checked before deployment.
- Editors can navigate, rename, and refactor large codebases with confidence.
- Unions model state transitions and success or failure outcomes clearly.
- Generics preserve relationships between repository, service, and API types.
- Generated types can connect API schemas, database clients, and application
  code.
- Strict compiler settings catch many missing-value and unsafe-access defects.

The trade-off is that a type can describe data more confidently than the
runtime deserves. External values still need validation, and highly clever
types can become harder to maintain than the code they protect.

## Subtopics

- [Type System Fundamentals](type-system-fundamentals.md) — inference,
  annotations, primitive and object types, tuples, readonly values, and safe
  alternatives to `any`.
- [Unions and Narrowing](unions-and-narrowing.md) — control-flow analysis, type
  guards, discriminated unions, exhaustiveness, and literal types.
- [Generics and Type Transformations](generics-and-type-transformations.md) —
  constraints, utility types, mapped types, conditional types, and templates.
- [Objects, Interfaces, and Classes](objects-interfaces-and-classes.md) —
  structural typing, contracts, access modifiers, abstract classes, and
  decorators.
- [Runtime Validation and Boundaries](runtime-validation-and-boundaries.md) —
  parsing unknown data, schema ownership, assertions, serialization, and trust.
- [Compiler, Modules, and Project Configuration](compiler-modules-and-project-configuration.md)
  — strictness, module resolution, declaration files, builds, and project
  references.
- [Async Code and Error Handling](async-code-and-error-handling.md) — typed
  promises, concurrency, cancellation, error narrowing, and result types.
- [Architecture and API Design](architecture-and-api-design.md) — domain
  modeling, DTO separation, dependency direction, repositories, and contracts.
- [Testing and Code Quality](testing-and-quality.md) — tests, type tests,
  linting, generated code, and continuous integration.
- [Production TypeScript Services](production-typescript-services.md) — build
  artifacts, source maps, validation, observability, migrations, and deployment.
- [TypeScript Questions](questions.md) — concise mid- and senior-level
  interview questions and answers.

## Core Vocabulary

| Term | Meaning |
| --- | --- |
| **Type inference** | The compiler derives a type without an explicit annotation. |
| **Structural typing** | Compatibility is based on members and their types rather than declared type names. |
| **Narrowing** | Control-flow analysis reduces a broad type to a more specific type. |
| **Generic** | A type or function parameterized by another type while preserving relationships. |
| **Type assertion** | A compile-time instruction to treat a value as a type; it performs no runtime check. |
| **Declaration file** | A `.d.ts` file that describes types without containing the corresponding runtime implementation. |
| **Runtime validation** | Executable code that checks external data before the application trusts it. |

## Suggested Learning Path

1. Learn JavaScript runtime behavior and TypeScript inference.
2. Practice unions, narrowing, null handling, and exhaustiveness.
3. Use generics and standard utility types to express real relationships.
4. Model clear runtime boundaries and parse external data from `unknown`.
5. Configure strict compilation, modules, tests, and automated quality checks.
6. Apply the type system to architecture without coupling every layer to one
   shared model.

Continue with [JavaScript](../javascript/index.md) for runtime concepts or
[NestJS](../../libraries-frameworks/nestjs/index.md) for framework-specific
TypeScript patterns.
