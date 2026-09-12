# Objects, Interfaces, and Classes

TypeScript is structurally typed: values are compatible when their visible
members are compatible, regardless of where their types were declared. This
supports flexible composition but does not automatically protect domain
meanings that share the same representation.

## `type` and `interface`

Both can describe object shapes:

```ts
interface User {
  readonly id: string;
  name: string;
}

type UserSummary = {
  id: string;
  displayName: string;
};
```

Interfaces can be extended, implemented by classes, and declaration-merged.
Type aliases can express unions, primitives, tuples, mapped types, conditional
types, and intersections as well as object shapes.

For ordinary object contracts, either can work. Choose a consistent convention
based on whether declaration merging and open extension are intended.

## Structural Typing

```ts
interface HasId {
  id: string;
}

const order = { id: "order-1", total: 120 };
const identifiable: HasId = order;
```

The extra `total` property does not prevent assignment. Structural typing is
convenient for small interfaces owned by consumers, but two identifiers with
the same primitive type can be mixed accidentally.

## Branded Types

A brand adds a compile-time distinction without changing runtime storage:

```ts
declare const userIdBrand: unique symbol;
declare const orderIdBrand: unique symbol;

type UserId = string & { readonly [userIdBrand]: true };
type OrderId = string & { readonly [orderIdBrand]: true };
```

Create branded values through a parser or trusted factory. A brand is not
runtime validation; an assertion can still forge it.

## Excess Property Checking

Fresh object literals receive an additional check for unknown properties:

```ts
type Credentials = { email: string; password: string };

authenticate({
  email: "reader@example.com",
  password: "secret",
  // rememberMe: true, // Reported if not part of Credentials
});
```

This check is helpful but is not exact-object typing. Values held in variables
may contain additional fields and still be structurally compatible. Runtime
schemas must decide whether to reject, strip, or preserve unknown keys.

## Classes and Runtime Identity

TypeScript classes produce JavaScript constructor functions and prototypes, so
they exist at runtime and can be used with `instanceof`:

```ts
class Account {
  #balance: number;

  constructor(
    public readonly id: string,
    openingBalance: number,
  ) {
    this.#balance = openingBalance;
  }

  debit(amount: number): void {
    if (amount > this.#balance) throw new RangeError("insufficient funds");
    this.#balance -= amount;
  }
}
```

JavaScript `#private` fields are enforced at runtime. TypeScript's `private` and
`protected` modifiers are primarily compile-time access restrictions.

Parameter properties are concise, but many of them can make constructors hard
to scan. Prefer explicit fields when initialization or validation is complex.

## Abstract Classes and Interfaces

An abstract class can provide state and partial implementation. An interface
describes a contract without emitting runtime code:

```ts
interface UserRepository {
  findById(id: UserId): Promise<User | null>;
  save(user: User): Promise<void>;
}

abstract class JobHandler<Job> {
  abstract handle(job: Job): Promise<void>;

  async run(job: Job): Promise<void> {
    await this.handle(job);
  }
}
```

Prefer a small interface near its consumer. Use an abstract class only when
shared implementation and a controlled inheritance relationship are valuable.

## Composition and Dependency Injection

Constructor or factory injection keeps dependencies visible:

```ts
type UserServiceDependencies = {
  users: UserRepository;
  clock: Clock;
  events: EventPublisher;
};

function createUserService(dependencies: UserServiceDependencies): UserService {
  return new UserService(dependencies);
}
```

Structural typing makes fakes easy to supply in tests. Avoid large interfaces
implemented by every adapter; define the smallest operations a use case needs.

## Decorators

TypeScript can work with standardized decorators and a legacy experimental
decorator system. They have different signatures, configuration, and metadata
behavior and should not be mixed casually.

Legacy decorator-based frameworks may require compiler options such as
`experimentalDecorators` and `emitDecoratorMetadata`, plus a metadata library.
Standard decorators use the current ECMAScript model and do not provide the
same emitted type metadata.

Decorators execute at class definition or instance behavior boundaries. They
can hide registration, authorization, transactions, or validation, so document
their order and test the composed behavior rather than assuming each decorator
works in isolation.

## Practical Rules

- Use `type` for unions and transformations; use either convention consistently
  for object contracts.
- Use brands when structurally identical values have important domain meaning.
- Prefer small consumer-owned interfaces and composition.
- Remember that most TypeScript visibility disappears after compilation.
- Choose one decorator model based on the framework and compiler configuration.
