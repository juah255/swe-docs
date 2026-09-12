# Testing and Code Quality

Type checking and runtime testing catch different classes of defects. A
successful type check proves that code satisfies its declared contracts; tests
verify that those contracts and implementations produce the intended behavior.

## Test Layers

| Layer | Purpose | Typical dependencies |
| --- | --- | --- |
| Unit | Verify domain and application behavior | Values, fakes, controlled time |
| Integration | Verify adapters and runtime schemas | Real database, broker, files, or service sandbox |
| End-to-end | Verify a critical public flow | Built and configured application |
| Type test | Verify a public compile-time API | Compiler and positive/negative examples |

Use the narrowest level that can expose the failure. Repository mocks cannot
prove database constraints, serialization, or generated-client compatibility.

## Explicit Test Dependencies

Structural typing makes small fakes straightforward:

```ts
class InMemoryUserStore implements RegisterUserStore {
  readonly users = new Map<string, User>();

  async existsByEmail(email: Email): Promise<boolean> {
    return [...this.users.values()].some((user) => user.email === email);
  }

  async insert(user: NewUser): Promise<User> {
    const saved = { ...user, id: createUserId("user-test") };
    this.users.set(saved.id, saved);
    return saved;
  }
}
```

A fake should honor the important semantics of its contract. If uniqueness,
transactions, or ordering matter, either model them or use an integration test
with the real adapter.

## Runtime Schema Tests

Boundary validators need tests for:

- valid minimal and complete values;
- missing and extra properties;
- wrong primitive types;
- `null`, `undefined`, empty, and boundary values;
- oversized or deeply nested input;
- serialization and round-trip behavior;
- safe error output.

Static fixtures typed as the expected input cannot test malformed runtime data
well. Declare invalid cases as `unknown` so the compiler does not prevent the
test from expressing them.

## Type Tests

Public generic libraries and advanced utilities benefit from compile-time tests:

```ts
declare const users: readonly User[];
const firstUser: User | undefined = first(users);

// @ts-expect-error A number is not a UserId.
await repository.findById(42);
```

`@ts-expect-error` reports a failure if the next line unexpectedly becomes
valid. Keep type tests small and focused on public guarantees; do not snapshot
large compiler diagnostics that change between versions.

## Mocking

Mock nondeterministic or external boundaries such as time, IDs, HTTP, and
message publishing. Avoid mocking every internal function, which couples tests
to implementation order.

Reset mocks and module state between tests. Runtime mocks can violate the
declared interface through unsafe casts, so prefer typed factory helpers and
small fakes where possible.

## Static Checks

A backend TypeScript pipeline commonly includes:

1. formatting verification;
2. linting with type-aware rules where valuable;
3. a no-emit compiler check;
4. unit and integration tests;
5. generated-code or schema drift checks;
6. dependency and security checks;
7. a production build and artifact smoke test.

Useful rules report floating promises, unsafe `any` flow, unhandled union
members, misleading async functions, and inconsistent type-only imports. Avoid
rules that add frequent casts merely to silence the tool.

## Generated Code

Do not hand-edit generated clients, database types, or schemas. Put generation
behind a repeatable command and make CI fail when regeneration produces an
unexpected diff.

Wrap unstable generated APIs behind application-owned adapters. This keeps
generator changes from spreading throughout domain code.

## Stable Tests

- Await every asynchronous operation owned by the test.
- Close servers, pools, workers, and message consumers.
- Inject time, randomness, and identifiers.
- Do not depend on test order or public internet access.
- Use the production database engine for database semantics.
- Test cancellation, duplicate events, rollback, and cleanup.
- Execute tests against the supported compiler and Node.js versions.

Coverage reveals unexecuted paths but does not prove type or behavioral
correctness. Prioritize risks at trust boundaries and state transitions.
