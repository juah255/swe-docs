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
