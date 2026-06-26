# Design Patterns Questions

## What is a design pattern?

A **design pattern** is a reusable solution to a recurring design problem. It is
not copy-paste code but a proven approach to how objects and classes collaborate.
Patterns also give a shared vocabulary, so saying "use a `Strategy`" communicates
intent quickly.

## What are the three categories of patterns?

- **Creational**: how objects are created (Singleton, Factory, Builder).
- **Structural**: how objects are composed (Adapter, Decorator, Facade).
- **Behavioral**: how objects interact and share responsibility (Strategy,
  Observer, Command).

## Strategy vs. Factory

- **Factory** decides which object to **create**.
- **Strategy** defines interchangeable **behavior** after the object exists.

```text
A payment factory chooses CardPayment
The payment strategy lets checkout call any method the same way
```

They are often used together: a factory selects the strategy.

## What are the risks of singleton?

A singleton can introduce **hidden global state**, lifecycle coupling, and tests
that are hard to isolate.

It is safer for immutable configuration or stateless shared services than for
mutable business state. In modern backends, prefer letting a DI container own the
single instance.

## When do design patterns hurt?

Patterns hurt when applied **before the variation is real**. They add indirection:
more interfaces, more files, deeper call stacks, and harder debugging.

```text
Use a pattern when you feel the pain of change,
not in anticipation of pain that may never come.
```

## Is dependency injection a design pattern?

Yes. **Dependency injection** provides a class with its dependencies instead of
letting it create them. It lowers coupling and makes behavior easy to replace and
mock in tests.

A DI container is effectively a configurable factory for the whole object graph,
managing construction and lifecycles.

## Adapter vs. Decorator

- **Adapter** changes an interface so incompatible types work together.
- **Decorator** keeps the same interface but adds behavior by wrapping.

Adapter is about compatibility; decorator is about extension.

## Observer vs. message queue

The **observer** pattern is the in-process version of pub/sub: a publisher
notifies listeners directly. A **message queue** moves that decoupling across
processes and adds durability and retries.

Synchronous observers risk one listener breaking the main flow, which is why many
backends push events to a queue instead.

## Mid/Senior Interview Questions and Answers

### 1. How do you decide which pattern, if any, to apply?

**Answer:** Start from the concrete change you expect. Identify whether the problem
is about creation, composition, or interaction, then pick the lightest pattern in
that category that makes the change easier.

If you cannot name the specific variation the pattern enables, prefer plain code.
A readable function beats a premature abstraction, and patterns can always be
introduced later when the need is real.

### 2. How would you refactor a large conditional that selects behavior?

**Answer:** Replace it with a strategy interface and one implementation per branch,
then choose the implementation through a factory or a lookup map keyed by the
condition.

This removes the growing `switch`, isolates each behavior for testing, and follows
the open/closed principle. The trade-off is more classes, so it is worth doing once
the branches are stable and likely to grow.

### 3. When is the singleton pattern actually appropriate?

**Answer:** When a single instance is genuinely correct and the state is immutable
or stateless, such as configuration, a logger, or a connection pool.

It is inappropriate for mutable business state because of hidden global state and
test isolation problems. Even when one instance is needed, having a DI container
own it keeps it injectable and replaceable.

### 4. How do patterns relate to SOLID principles?

**Answer:** Patterns are concrete ways to satisfy SOLID. Strategy and factory
support open/closed, dependency injection enables dependency inversion, and small
focused interfaces in adapter or decorator support interface segregation.

Understanding the principles matters more than memorizing patterns, because the
principles explain why a pattern helps and when applying one would actually hurt.

### 5. Which patterns are already provided by modern frameworks?

**Answer:** Many. DI containers provide creational wiring, middleware pipelines are
chain of responsibility, ORMs use repository and proxy, and event systems provide
observer.

The senior skill is recognizing these patterns inside the tools you already use,
so you apply the remaining ones deliberately rather than reimplementing what the
framework gives you for free.
