# Architecture and API Design

TypeScript is most useful when its types express ownership and valid state
across application boundaries. A large shared interface reused everywhere may
remove duplication, but it can also couple HTTP, domain, and persistence layers
that change for different reasons.

## Separate Layer Models

A backend request commonly passes through several representations:

```text
HTTP request DTO -> application command -> domain entity -> persistence record
                                                              |
HTTP response DTO <- response mapper <-------------------------+
```

- A **request DTO** describes validated client input.
- An **application command** describes a use case.
- A **domain entity or value** protects business invariants.
- A **persistence record** follows the storage schema.
- A **response DTO** exposes only the public contract.

These may share fields, but they do not share responsibility. Explicit mapping
prevents database columns and internal flags from leaking into APIs.

## Make Invalid States Harder to Represent

Use unions and separate types instead of unrelated optional fields:

```ts
type Subscription =
  | { status: "trial"; trialEndsAt: Date }
  | { status: "active"; renewalDate: Date }
  | { status: "cancelled"; cancelledAt: Date; reason: string };
```

Now an active subscription cannot accidentally omit its renewal date or carry a
trial-only field. Runtime constructors must still validate data entering the
model.

## Value Objects and Brands

Primitive obsession makes unrelated IDs, money, email addresses, and timestamps
look interchangeable. Use branded primitives for lightweight identity and
classes or validated objects when behavior and invariants matter.

```ts
type Money = Readonly<{
  amountMinor: bigint;
  currency: CurrencyCode;
}>;
```

Represent money with an exact unit and define rounding at the boundary. A
TypeScript alias alone cannot enforce a currency code or numeric range at
runtime.

## Consumer-Owned Interfaces

Define an interface around what a use case needs:

```ts
interface RegisterUserStore {
  existsByEmail(email: Email): Promise<boolean>;
  insert(user: NewUser): Promise<User>;
}

interface RegistrationEvents {
  publishUserRegistered(event: UserRegistered): Promise<void>;
}
```

A database adapter can implement several small consumer interfaces. This avoids
one large repository contract that changes whenever any use case needs a new
operation.

## Dependency Direction

Application and domain code should depend on contracts, not framework or
database implementations. Wire concrete dependencies in a composition root:

```ts
const users = new PostgresUserStore(database);
const events = new BrokerRegistrationEvents(broker);
const registerUser = new RegisterUser({ users, events, clock });
```

TypeScript's structural compatibility means the classes do not need explicit
`implements` clauses, though using them can document intent and catch drift.

## API Responses

Use stable public shapes and machine-readable error codes:

```ts
type ApiError = {
  error: {
    code: "INVALID_REQUEST" | "NOT_FOUND" | "CONFLICT";
    message: string;
    fields?: Record<string, string>;
  };
};
```

Do not expose an internal error union automatically. Public contracts need
versioning and security review, while internal failure detail belongs in logs
and traces.

## Generated Contracts

Code generation can connect OpenAPI, GraphQL, protocol buffers, events, or
database schemas to TypeScript. Decide whether generated code is:

- checked into source control or created during the build;
- wrapped behind an application-owned adapter;
- validated for backward compatibility;
- regenerated and checked for a clean diff in CI.

Generated types describe the source schema but do not always validate runtime
values. Understand what the generator produces: types, parsers, serializers, or
some combination.

## Versioning and Compatibility

For public APIs and events:

- add optional fields before requiring consumers to use them;
- do not change the meaning of an existing field silently;
- distinguish absent fields from `null` intentionally;
- preserve unknown enum or union values when forward compatibility requires it;
- run consumer or schema compatibility checks before deployment.

An exhaustive internal union can conflict with an external protocol that may
gain new values. Parse unknown external variants into an explicit fallback or
reject them according to the protocol policy.

## Architectural Pitfalls

- reusing ORM entities directly as API responses;
- deriving every model from one central interface;
- making every property optional to support partial updates;
- letting framework decorators replace explicit application boundaries;
- treating generated types as runtime validation without checking;
- building generic repository abstractions that cannot express real queries;
- using advanced types to hide unclear domain rules.

Good architecture uses types to reveal boundaries, not erase them.
