# OOP Questions

## What is OOP?

**OOP** is a programming approach that organizes software around objects. Objects combine data and behavior.

## What are the four pillars of OOP?

- **Encapsulation**: hide internal state and expose controlled methods.
- **Abstraction**: hide implementation details behind a simple interface.
- **Inheritance**: reuse or extend behavior from a parent class.
- **Polymorphism**: use different implementations through the same interface.

## Class vs. Object

- **Class**: blueprint or template.
- **Object**: actual instance created from a class.

Example:

```text
User is a class
user1 is an object
```

## Encapsulation vs. Abstraction

- **Encapsulation** is about hiding data and controlling access.
- **Abstraction** is about hiding complexity and showing only what is needed.

Example:

```text
Encapsulation: balance is private
Abstraction: paymentService.pay(order) hides payment steps
```

## Inheritance vs. Composition

- **Inheritance** means `is-a`.
- **Composition** means `has-a`.

Prefer composition when behavior needs to vary flexibly.

## Method Overloading vs. Method Overriding

- **Overloading**: same method name with different parameters.
- **Overriding**: child class changes parent method behavior.

## Abstract Class vs. Interface

- **Abstract class** can contain shared state and shared implementation.
- **Interface** defines a contract that classes must implement.

Use an interface when different classes only need to share behavior.

Use an abstract class when related classes need shared base logic.

## What is dependency injection?

**Dependency injection** means passing required dependencies into a class instead of creating them inside the class.

Example:

```text
OrderService receives PaymentGateway
```

Benefits:

- Easier testing
- Lower coupling
- Easier replacement of implementations

## What is polymorphism in real life?

Example:

```text
NotificationSender.send()
```

Implementations:

- `EmailSender`
- `SmsSender`
- `PushSender`

The caller uses the same method, but the behavior changes by implementation.

## Mid/Senior Interview Questions and Answers

### 1. How would you refactor a large service class?

**Answer:** First identify separate reasons to change: validation, business
rules, persistence, external integrations, notifications, and formatting. Then
extract cohesive collaborators with clear interfaces.

Do not split randomly by method count. Split around responsibilities and test
the current behavior before refactoring risky code.

### 2. How do you model domain invariants in OOP?

**Answer:** Put invariants close to the data they protect. A domain object can
expose methods that enforce legal transitions instead of allowing arbitrary
field mutation.

Database constraints should still enforce critical invariants at persistence
boundaries.

### 3. How do interfaces help in large systems?

**Answer:** Interfaces define contracts between modules and let high-level code
depend on behavior instead of concrete infrastructure.

They are most useful at boundaries that change or need substitution, such as
payment gateways, repositories, queues, storage, and external APIs.

### 4. What is the risk of overusing design patterns?

**Answer:** Overusing patterns can create unnecessary indirection, more files,
harder debugging, and code that is abstract before requirements justify it.

Senior engineers use patterns when they make change easier, not to make code
look more formal.
