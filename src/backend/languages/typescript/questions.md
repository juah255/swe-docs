# TypeScript Questions

These questions review the TypeScript concepts most relevant to maintainable
backend systems.

## 1. What problem does TypeScript solve?

**Answer:** TypeScript catches many contract and type errors before runtime. It
improves navigation, editor feedback, refactoring, and communication across a
large codebase. It does not validate runtime data or change JavaScript's
execution model because most types are erased during compilation.

## 2. What is the difference between `type` and `interface`?

**Answer:** Both can describe object shapes. Interfaces support declaration
merging and direct extension and implementation patterns. Type aliases can also
represent unions, primitives, tuples, mapped types, conditional types, and
intersections. Either can work for a simple object; consistency and whether
open extension is intended matter more than a universal preference.

## 3. What is structural typing?

**Answer:** Compatibility is based on a value's members rather than the declared
name of its type. An object with all required compatible fields can satisfy an
interface without explicitly implementing it. Branded types can distinguish
domain values such as `UserId` and `OrderId` that otherwise share one structure.

## 4. What are union and intersection types?

**Answer:** A union means a value may be one of several types. An intersection
combines the requirements of multiple types. Discriminated unions are especially
useful for modeling mutually exclusive business states and supporting
exhaustive handling.

## 5. What is the difference between `any`, `unknown`, and `never`?

**Answer:** `any` disables normal checking and permits unsafe operations.
`unknown` can hold any value but must be narrowed before use. `never` represents
an impossible value and is useful for exhaustiveness checks and functions that
cannot return normally.

## 6. How do generics improve API design?

**Answer:** Generics preserve a relationship between types, such as the element
type passed to a function and the type it returns. Good generic parameters
connect at least two meaningful parts of a contract. A parameter used only once
may be unnecessary.

## 7. What are type guards and narrowing?

**Answer:** Narrowing reduces a broad type using runtime evidence such as
`typeof`, `instanceof`, property checks, or a discriminant. A custom type guard
uses a predicate return type. The compiler trusts that predicate, so the
implementation must verify everything it claims.

## 8. Why is strict mode important?

**Answer:** Strict compiler settings catch missing values, implicit `any`, unsafe
function compatibility, and other errors that permissive settings accept. New
production projects should begin strict; older systems can migrate in controlled
steps without weakening new code.

## 9. Why does a TypeScript service still need runtime validation?

**Answer:** Types are erased, and external systems do not participate in local
type checking. HTTP payloads, queue messages, environment variables, files,
database rows, and third-party responses must be parsed and validated before
the application trusts them.

## 10. What does a type assertion do?

**Answer:** `value as Target` tells the compiler to interpret a value as
`Target`; it neither converts nor validates the runtime value. Non-null and
double assertions are similar escape hatches. Prefer narrowing or a parser when
runtime truth is uncertain.

## 11. What is the difference between `readonly` and runtime immutability?

**Answer:** `readonly` prevents mutation through a TypeScript reference during
checking. It usually does not freeze the runtime object and is shallow unless
nested members are also readonly. Runtime immutability requires an appropriate
construction or freezing strategy.

## 12. When are mapped and conditional types useful?

**Answer:** Mapped types transform properties across an object type, while
conditional types choose a result based on a type relationship. They are useful
when contracts genuinely derive from one another. Deep or distributive designs
should be simplified when diagnostics and compiler performance become poor.

## 13. What does `satisfies` provide compared with an annotation?

**Answer:** `satisfies` checks that an expression is compatible with a target
type while retaining the expression's more specific inferred type. An explicit
annotation usually changes the variable's visible type to the annotation.

## 14. How do CommonJS, ES modules, and TypeScript configuration interact?

**Answer:** TypeScript's module and resolution settings must agree with
`package.json`, Node.js, file extensions, and the build or test tool. A compiler
or development runner can resolve an import that production Node.js cannot, so
the built artifact must be tested directly.

## 15. Why can a transpiled TypeScript build still contain type errors?

**Answer:** Many fast transpilers remove TypeScript syntax without running the
complete type checker. CI needs a separate no-emit compiler check when the build
tool does not verify types.

## 16. How should errors be typed?

**Answer:** Treat caught errors as `unknown` because JavaScript can throw any
value. Narrow with runtime checks, use custom error classes or stable codes when
callers need policies, and preserve the original cause when adding context.

TypeScript does not normally encode checked exceptions in a promise signature.

## 17. When should you use a result union instead of throwing?

**Answer:** Use a discriminated result union for expected alternatives that a
caller should handle, such as a declined payment. Throw for failures that
interrupt normal processing, such as an unavailable dependency or broken
invariant. Keep the distinction consistent within an application boundary.

## 18. What are common senior-level TypeScript pitfalls?

**Answer:** Common pitfalls include overusing `any` and assertions, trusting
external or generated values without validation, weakening compiler options,
mixing transport and domain models, creating overly complex generic types,
ignoring module/runtime differences, and assuming a clean type check proves
production correctness.
