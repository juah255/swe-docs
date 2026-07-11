# Creational Patterns

**Creational patterns** deal with how objects are created. They decouple the code
that uses an object from the code that constructs it, which makes systems easier
to extend and test when construction logic grows complex.

Dependency injection is a practical creational pattern for passing dependencies
into an object instead of letting the object construct them itself. In backend
code, it is one of the most common ways to keep services testable and replaceable.

## Singleton

**Intent:** Ensure a class has only one instance and provide a single global
access point to it.

**When to use:** For genuinely shared, expensive-to-create resources where one
instance is correct: configuration, a logger, a connection pool, or a cache
client.

**Backend example:**

```text
Config.instance() returns the same loaded configuration everywhere
DbPool.instance() returns one shared connection pool
```

**Trade-offs:** Introduces hidden global state and lifecycle coupling that makes
tests hard to isolate. Safe for immutable config or stateless shared services,
risky for mutable business state. In most modern backends a DI container managing
a single scoped instance is preferable to a hand-rolled singleton.

## Factory Method

**Intent:** Define a method for creating an object, but let the method decide
which concrete class to instantiate.

**When to use:** When the concrete type depends on a runtime condition and you
want callers to stay unaware of the specific class.

**Backend example:**

```text
NotificationFactory.create(channel)
  -> EmailNotifier | SmsNotifier | PushNotifier
```

**Trade-offs:** Centralizes creation and supports the open/closed principle when
adding new types. Adds a layer of indirection, and a sprawling factory with a
large `switch` can become a maintenance hotspot if types change frequently.

## Abstract Factory

**Intent:** Provide an interface for creating **families of related objects**
without specifying their concrete classes.

**When to use:** When the system must work with multiple product families and you
need to guarantee that objects from the same family are used together.

**Backend example:**

```text
CloudProviderFactory
  AwsFactory   -> S3Storage,  SqsQueue,  DynamoStore
  GcpFactory   -> GcsStorage, PubSubQueue, FirestoreStore
```

**Trade-offs:** Keeps a family of choices consistent and swappable behind one
interface. The downside is rigidity: adding a new product type means changing the
abstract factory and every concrete factory that implements it.

## Builder

**Intent:** Separate the construction of a complex object from its representation,
assembling it step by step.

**When to use:** When an object has many optional fields or requires a controlled,
multi-step assembly, and telescoping constructors become unreadable.

**Backend example:**

```text
HttpRequest.builder()
  .url("/orders")
  .method("POST")
  .header("Authorization", token)
  .body(payload)
  .build()
```

**Trade-offs:** Produces readable, immutable objects and avoids long argument
lists. It adds boilerplate, so for objects with few fields a plain constructor or
keyword arguments are simpler.

## Prototype

**Intent:** Create new objects by **cloning** an existing instance instead of
constructing from scratch.

**When to use:** When object creation is expensive and a configured instance can
serve as a template, or when you need copies that vary slightly from a baseline.

**Backend example:**

```text
defaultReportConfig.clone() then override a few fields per tenant
```

**Trade-offs:** Avoids costly re-initialization and captures complex setup once.
The main hazard is **shallow vs deep copy**: cloning shared mutable references can
cause subtle bugs when the copy mutates state the original still points to.

## Dependency Injection

**Dependency Injection (DI):** It is a design pattern where a class or function receives its dependencies from the outside instead of creating them itself.

**Intent:** Provide an object with its dependencies from the outside instead of
having it create them internally.

**When to use:** When a class depends on other services, repositories, clients,
or helpers and you want to make those dependencies explicit, swappable, and
easy to fake in tests.

**Backend example:**

```text
OrderService(paymentGateway, orderRepository, eventBus)
```

The `OrderService` receives its collaborators through the constructor rather
than calling `new StripePaymentGateway()` or `new PostgresOrderRepository()`
inside its own methods.

**Common forms:**

- **Constructor injection**: pass dependencies when creating the object.
- **Setter injection**: assign dependencies after construction.
- **Method injection**: pass dependencies to the specific method that needs them.

**Trade-offs:** Improves testability, clarity, and separation of concerns by
making dependencies explicit. It adds wiring code, and overly large dependency
lists can be a sign that the class is doing too much.

In practice, a DI container often manages object creation and scope, but the
pattern still matters even without a framework.

## Mid/Senior Interview Questions and Answers

### 1. When is a singleton acceptable in a backend service?

**Answer:** It is acceptable for immutable configuration or stateless shared
services such as a logger or a connection pool, where a single instance is
genuinely correct.

It becomes a problem when it holds mutable business state, because that creates
hidden global state and makes tests hard to isolate. Prefer letting a DI
container own the single instance so it stays injectable and replaceable.

### 2. How do factory method and abstract factory differ?

**Answer:** Factory method creates one product and defers the concrete choice to a
single method. Abstract factory creates a family of related products and
guarantees they come from the same family.

Use factory method when you vary a single type by condition. Use abstract factory
when several related objects must stay consistent, such as a full set of cloud
provider clients.

### 3. When would you choose a builder over a constructor?

**Answer:** Choose a builder when an object has many optional fields or needs
controlled, multi-step assembly, and constructors would otherwise become long and
error-prone argument lists.

For objects with a few required fields, a builder is overkill. Many languages
offer named or default arguments that solve the same readability problem with
less code.

### 4. What is the most common bug with the prototype pattern?

**Answer:** Shallow copying. Cloning copies top-level fields but leaves nested
mutable objects shared between the original and the copy, so mutating one
silently affects the other.

The fix is a deliberate deep copy of mutable members, or making the cloned
fields immutable so sharing is safe.

### 5. How do dependency injection containers relate to creational patterns?

**Answer:** A DI container is essentially a configurable factory for the whole
object graph. It centralizes construction, manages lifecycles such as singleton or
per-request scope, and wires dependencies.

It replaces much hand-written factory and singleton code. The patterns still
matter conceptually, but the container handles creation so business code can
depend on abstractions and stay free of construction details.
