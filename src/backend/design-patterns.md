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
