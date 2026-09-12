# Compiler, Modules, and Project Configuration

Compiler configuration is part of a TypeScript application's correctness. It
defines which unsafe programs are accepted and how imports map to the
JavaScript that Node.js eventually executes.

## Start With Strictness

Enable the `strict` family for new backend projects:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

`strict` includes several important checks, including strict null handling and
implicit-`any` detection. The additional options above expose unsafe indexed
access, distinguish optional from explicitly undefined properties, require
override intent, and catch switch fallthrough.

An older codebase can migrate package by package or enable individual checks
gradually. Do not weaken the shared configuration silently for one difficult
file; isolate and track the exception.

## Target and Runtime

`target` controls the JavaScript syntax level emitted by the compiler and the
default library assumptions. Choose it from the oldest runtime the deployment
actually supports.

Type declarations for an API do not make that API available at runtime. A
successful compile can still call a missing platform feature if the configured
libraries and installed runtime types are newer than production.

Declare and test the supported Node.js version in package metadata, CI, and the
deployment image.

## Module Format and Resolution

`module` controls emitted module syntax, while `moduleResolution` controls how
the compiler finds imports. These choices must agree with Node.js,
`package.json`, file extensions, and any bundler or test runner.

For a Node.js service, use the Node-aware settings appropriate to the chosen
module system. For a bundled application, bundler-oriented resolution may be
appropriate. Avoid copying settings without understanding who resolves the
runtime import.

TypeScript can accept an import that a production runtime cannot resolve when
the development toolchain applies aliases or extension rules that production
does not.

## Path Aliases

`paths` can make internal imports shorter, but it generally teaches the compiler
how to resolve a name; it does not automatically rewrite emitted imports or
configure Node.js.

If aliases are used, configure the runtime, bundler, test runner, and editor
consistently. Package boundaries or relative imports are often simpler than a
large alias map.

## Declaration Files

`.d.ts` files describe runtime JavaScript without providing implementation.
They may ship with a package, come from an external type package, or describe an
internal untyped module.

An inaccurate declaration file is a false promise. Keep declarations near the
runtime code they describe and test important wrappers at runtime.

Ambient declarations affect code globally or by module name. Keep them narrow;
an overly broad declaration such as `declare module "*"` can hide real import
and typing errors.

## Build Without Type Checking

Fast transpilers can erase TypeScript syntax without performing complete type
checking. That is useful for local execution and bundling, but CI must run a
separate no-emit compiler check if the build tool does not check types.

```text
lint -> type-check -> test -> build -> inspect artifact
```

Do not assume that producing JavaScript means the TypeScript program was
verified.

## Source and Output Layout

A simple service might use:

```text
project/
├── package.json
├── tsconfig.json
├── src/
│   ├── api/
│   ├── application/
│   ├── domain/
│   ├── infrastructure/
│   └── server.ts
├── test/
└── dist/
```

Keep emitted files out of source directories. Ensure the artifact contains
runtime files such as migrations, templates, schemas, and package metadata—not
only emitted `.js` files.

## Project References

Large repositories can use project references to create explicit build units
with incremental compilation. Each referenced project should have a clear
public API and should not reach into another package's private source files.

References add configuration overhead, so use them when package boundaries and
build performance justify the complexity.

## Namespaces

TypeScript namespaces predate standardized JavaScript modules. Modern backend
code should normally use ES modules or CommonJS modules. Namespaces still
appear in legacy code and some ambient declaration patterns.

## Configuration Checklist

- Keep one reviewed base configuration.
- Enable strict checking and intentional extra safety flags.
- Match target, modules, resolution, and runtime behavior.
- Run a real type check even when another tool transpiles.
- Keep generated declarations and source maps with the correct artifact.
- Test the exact built entry point, not only source files through a dev runner.
