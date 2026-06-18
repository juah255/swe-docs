# OOP Overview

**Object-oriented programming** is a programming style that organizes code around objects. An object combines **data** and **behavior** in one unit.

## Core Ideas

- **Class**: a blueprint for creating objects.
- **Object**: an instance of a class.
- **Property**: data stored on an object.
- **Method**: behavior or function attached to an object.
- **Constructor**: special method used to initialize a new object.

## Four Pillars

### Encapsulation

**Encapsulation** hides internal details and exposes a clear public interface.

Example:

```text
User.balance is private
User.deposit(amount) changes it safely
```

### Abstraction

**Abstraction** shows only the important behavior and hides unnecessary implementation details.

Example:

```text
paymentGateway.charge(order)
```

The caller does not need to know how the gateway talks to the bank.

### Inheritance

**Inheritance** lets one class reuse or extend behavior from another class.

Example:

```text
AdminUser extends User
```

Use inheritance carefully. Prefer composition when classes do not have a true `is-a` relationship.

### Polymorphism

**Polymorphism** allows different classes to be used through the same interface.

Example:

```text
EmailNotification.send()
SmsNotification.send()
PushNotification.send()
```

All notification types can be handled as `Notification`.

## When OOP Helps

- Modeling business concepts such as users, orders, invoices, and products
- Keeping related data and behavior together
- Defining clear boundaries between modules
- Reusing behavior through interfaces, composition, or inheritance
- Making code easier to test through dependency injection

## Common Mistakes

- Creating too many classes for simple logic
- Putting all logic into large service classes
- Using inheritance where composition is simpler
- Exposing internal state directly
- Mixing business logic, database logic, and HTTP logic in the same class

## Mid/Senior Interview Questions and Answers

### 1. How do you know when OOP is helping rather than adding ceremony?

**Answer:** OOP helps when objects represent stable domain concepts, protect
invariants, and give clear collaboration boundaries. It becomes ceremony when
classes only wrap simple functions without improving clarity, testability, or
change isolation.

Senior engineers choose object boundaries around behavior and ownership, not
only around nouns.

### 2. Why is encapsulation important in business code?

**Answer:** Encapsulation prevents invalid state changes by exposing controlled
methods instead of raw mutable fields.

For example, an `Order` should not allow arbitrary status assignment if only
certain transitions are legal. Methods such as `pay()`, `ship()`, and
`cancel()` can enforce those rules.

### 3. When should inheritance be avoided?

**Answer:** Avoid inheritance when the relationship is not a true substitutable
`is-a` relationship or when behavior needs to vary independently at runtime.

Composition is usually better for roles, permissions, strategies, integrations,
and optional behavior because it avoids fragile base classes and deep
hierarchies.

### 4. What makes an object easy to test?

**Answer:** It has clear dependencies, minimal hidden global state, deterministic
behavior, and focused responsibilities. Dependencies should be injected so tests
can use fakes or mocks without reaching real databases or external services.

Good OOP design makes important behavior testable without requiring the whole
application to boot.
