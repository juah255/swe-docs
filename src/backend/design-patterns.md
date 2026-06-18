# Design Patterns

### What is dependency injection?

**Dependency injection** is a design pattern where objects are provided to a class instead of the class creating them manually.

## Strategy Pattern

Useful when **behavior changes based on runtime conditions**.

Examples:

- Payment methods
- Notification channels
- Login methods
- Pricing rules

## Factory Pattern

Useful for **creating different services or classes** based on a condition.

## Singleton Pattern

Useful for **shared instances** such as:

- Config
- Logger
- Database client

## Observer Pattern

Useful for **event-based systems**.

Example:

```text
order placed -> send email -> notify admin
```

## Mid/Senior Interview Questions and Answers

### 1. When is dependency injection better than creating dependencies directly?

**Answer:** Dependency injection is better when a class depends on external
resources, alternative implementations, or behavior that should be mocked in
tests.

Creating simple value objects directly is fine. Inject dependencies that affect
I/O, policy, infrastructure, or collaboration boundaries.

### 2. How do you choose between strategy and factory?

**Answer:** Factory decides which object to create. Strategy defines
interchangeable behavior after the object exists.

A payment factory may choose `CardPayment`, while the payment strategy interface
lets checkout call all payment methods through the same behavior.

### 3. What is the main risk of singleton?

**Answer:** Singleton can introduce hidden global state, lifecycle coupling, and
hard-to-isolate tests.

It is safer for immutable configuration or stateless shared services than for
mutable business state.

### 4. How does observer support decoupling?

**Answer:** Observer lets the publisher emit an event without knowing all
listeners. This decouples the core workflow from side effects such as email,
analytics, notifications, or audit logs.

Use care with failure handling. If observers run synchronously, a listener
failure can break the main operation.
