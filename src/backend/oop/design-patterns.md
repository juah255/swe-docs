# OOP Design Patterns

**Design patterns** are common solutions to recurring software design problems. They are useful when they simplify code, not when they add ceremony.

## Creational Patterns

### Factory

Use a **factory** when object creation depends on a condition.

Example:

```text
PaymentFactory.create("card") -> CardPayment
PaymentFactory.create("cash") -> CashPayment
```

### Builder

Use a **builder** when an object has many optional fields or complex setup.

Example:

```text
OrderBuilder
  .withCustomer(customer)
  .withItems(items)
  .withCoupon(coupon)
  .build()
```

### Singleton

Use a **singleton** when only one shared instance should exist.

Common examples:

- Configuration
- Logger
- Database client

Avoid using singletons for mutable business state.

## Structural Patterns

### Adapter

Use an **adapter** to make one interface work like another.

Example:

```text
ThirdPartySmsClient -> NotificationSender
```

### Facade

Use a **facade** to provide a simple interface over a complex subsystem.

Example:

```text
CheckoutService.placeOrder()
```

Internally it may call inventory, payment, order, and notification services.

### Decorator

Use a **decorator** to add behavior without changing the original class.

Example:

```text
CachedProductRepository wraps ProductRepository
```

## Behavioral Patterns

### Strategy

Use a **strategy** when behavior changes at runtime.

Examples:

- Payment method
- Shipping cost calculation
- Discount rule
- Notification channel

### Observer

Use an **observer** when one event should notify multiple listeners.

Example:

```text
OrderPlaced -> SendEmail, ReduceStock, NotifyAdmin
```

### Command

Use a **command** to represent an action as an object.

Examples:

- Queue jobs
- Undo/redo actions
- Audit logs
- Retryable operations

## Mid/Senior Interview Questions and Answers

### 1. When should a factory be used?

**Answer:** Use a factory when object creation depends on runtime input,
configuration, or complex setup that callers should not know about.

Avoid factories when a direct constructor is clear. A pattern should remove
coupling or complexity, not add ceremony.

### 2. What problem does the strategy pattern solve?

**Answer:** Strategy separates interchangeable behavior behind a shared
interface. It is useful when an algorithm or policy varies, such as payment,
pricing, shipping, tax, or notification behavior.

It replaces fragile conditional trees when new behaviors are added regularly.

### 3. Why can singleton be dangerous?

**Answer:** Singleton can hide global mutable state and make tests order
dependent. It also couples callers to a specific instance lifecycle.

Singleton is acceptable for immutable configuration or process-level shared
infrastructure, but avoid it for business state.

### 4. How do observer and command differ?

**Answer:** Observer notifies listeners when an event happens. Command
represents an action as an object that can be queued, retried, logged, or
executed later.

Order placement might publish an `OrderPlaced` event to observers, while a
`SendReceiptEmailCommand` can be placed on a job queue.
