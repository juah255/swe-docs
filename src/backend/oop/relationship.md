# OOP Relationships

OOP relationships describe how classes and objects are connected.

## Association

**Association** means one class uses or knows about another class.

Example:

```text
Teacher teaches Student
```

Both can exist independently.

## Aggregation

**Aggregation** is a weak `has-a` relationship. The child can exist without the parent.

Example:

```text
Department has Teachers
```

If the department is removed, the teachers can still exist.

## Composition

**Composition** is a strong `has-a` relationship. The child belongs to the parent lifecycle.

Example:

```text
Order has OrderItems
```

If the order is deleted, its order items usually do not exist independently.

## Inheritance

**Inheritance** is an `is-a` relationship.

Example:

```text
AdminUser is a User
```

Use inheritance when the child truly behaves like the parent.

## Dependency

**Dependency** means one class temporarily uses another class to do work.

Example:

```text
OrderService uses PaymentGateway
```

The service depends on the gateway, but it does not own it.

## Composition vs. Inheritance

Prefer **composition** when behavior can be built by combining smaller objects.

Example:

```text
User has Role
User has Permission
```

This is often more flexible than creating many subclasses such as:

```text
AdminUser
VendorUser
CustomerUser
ModeratorUser
```

## Quick Comparison

| Relationship | Meaning | Example |
| --- | --- | --- |
| Association | Uses or knows about | `Teacher` and `Student` |
| Aggregation | Weak has-a | `Department` has `Teacher` |
| Composition | Strong has-a | `Order` has `OrderItem` |
| Inheritance | Is-a | `AdminUser` extends `User` |
| Dependency | Temporarily uses | `OrderService` uses `PaymentGateway` |

## Mid/Senior Interview Questions and Answers

### 1. How do you choose between composition and inheritance?

**Answer:** Use inheritance only when the child can truly substitute for the
parent without surprising callers. Use composition when behavior or capabilities
can vary independently.

In business systems, composition is often safer because roles, permissions,
payment methods, and notification channels change over time.

### 2. What is the lifecycle difference between aggregation and composition?

**Answer:** In aggregation, the child can exist independently of the parent. In
composition, the child is owned by the parent lifecycle.

For example, a teacher may exist without a department, but an order item usually
has no independent meaning without its order.

### 3. Why can deep inheritance hierarchies become risky?

**Answer:** Deep hierarchies spread behavior across many levels and make changes
to base classes affect many subclasses. They can also force unrelated concepts
into the same tree.

Senior teams prefer shallow inheritance, interfaces, and composition when
behavior must evolve independently.

### 4. What is a dependency relationship in service design?

**Answer:** A dependency means one class uses another to perform work but does
not own its lifecycle. For example, `OrderService` depends on
`PaymentGateway`.

Injecting dependencies makes service behavior easier to test and replace.
