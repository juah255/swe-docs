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
