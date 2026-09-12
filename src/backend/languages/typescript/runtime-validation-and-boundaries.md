# Runtime Validation and Boundaries

TypeScript checks source code, not incoming bytes. HTTP bodies, query strings,
environment variables, queue messages, database values, files, and third-party
responses can violate their declared types at runtime.

## Start External Data as `unknown`

Treat a value as `unknown` until executable checks establish its shape:

```ts
type CreateUser = {
  email: string;
  age: number | null;
};

function parseCreateUser(value: unknown): CreateUser {
  if (typeof value !== "object" || value === null) {
    throw new ValidationError("body must be an object");
  }

  if (!("email" in value) || typeof value.email !== "string") {
    throw new ValidationError("email must be a string");
  }

  if (
    !("age" in value) ||
    (typeof value.age !== "number" && value.age !== null)
  ) {
    throw new ValidationError("age must be a number or null");
  }

  return { email: value.email, age: value.age };
}
```

Handwritten parsers work for small values. Schema libraries or generated
validators are usually better for nested structures, reusable schemas, and
detailed error reporting.

## Parse, Do Not Merely Assert

A type assertion changes the compiler's view but performs no check:

```ts
const body = JSON.parse(raw) as CreateUser; // Not validated
```

`JSON.parse()` returns a runtime value whose contents are untrusted. Isolate the
unsafe parsing API, treat its result as `unknown`, and validate before use.

The non-null assertion operator (`value!`) also performs no check. Use it only
when a real invariant is enforced elsewhere and can be explained clearly.

Double assertions such as `value as unknown as Target` bypass compatibility
checks and should be treated as a visible escape hatch.

## Schema Ownership

Decide which artifact is authoritative:

- a runtime schema that infers a TypeScript type;
- an API specification that generates types and validators;
- a TypeScript type paired with a tool that generates a schema;
- separate runtime and compile-time definitions checked by contract tests.

Maintaining an unrelated interface and validator manually invites drift. Put
generation or equivalence checks in CI.

## Validation Is More Than Shape

A value can have the correct primitive type and still be invalid. Check:

- length, range, and numeric finiteness;
- string format and normalization;
- allowed values and state transitions;
- array and object size;
- unknown keys;
- cross-field rules;
- tenant and authorization context.

Runtime validation establishes data validity. Authorization separately decides
whether the caller may perform an action.

## Transport, Domain, and Persistence Models

Do not assume one type should represent every layer:

```text
untrusted HTTP value
    -> validated request DTO
    -> domain command/entity
    -> persistence record
    -> response DTO
```

A request may accept strings that are converted into domain values. A database
record may include internal columns that must never appear in a response. A
domain entity may enforce methods and invariants that do not serialize cleanly.

Explicit mapping makes these trust and ownership transitions visible.

## Serialization Changes Values

JSON does not preserve every JavaScript or TypeScript value:

- `Date` becomes a string through its JSON representation;
- `bigint` is not serialized by default;
- `undefined`, functions, and symbols may be omitted;
- maps, sets, class prototypes, and private fields are not reconstructed;
- numbers do not preserve arbitrary integer precision.

Define wire formats explicitly. Use strings for large identifiers or decimal
values when the protocol requires exact representation, and parse dates rather
than asserting that incoming strings are `Date` objects.

## Database Boundaries

Generated database types describe what a client believes a query returns. They
do not replace constraints or migration discipline. Raw queries, legacy rows,
JSON columns, nullable fields, and schema drift can still violate assumptions.

Keep database constraints for invariants that must hold across every writer.
Validate schemaless columns and map records into domain values at a clear
adapter boundary.

## Error Responses

Validation errors should return stable machine-readable codes and safe field
details. Do not expose schema internals, stack traces, SQL messages, or entire
rejected payloads.

Log enough context to diagnose failures without recording credentials, tokens,
or sensitive personal data.

## Boundary Checklist

- Accept external data as `unknown`.
- Apply size limits before expensive parsing.
- Validate and normalize once at entry.
- Convert into trusted application types.
- Keep authorization separate and explicit.
- Map domain values into intentional response DTOs.
- Test malformed, extra, missing, and adversarial inputs.
