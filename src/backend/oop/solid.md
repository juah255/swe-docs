# SOLID

**SOLID** is a set of object-oriented design principles that help keep code easier to change, test, and maintain.

## Single Responsibility Principle

A class should have **one reason to change**.

Bad example:

```text
InvoiceService calculates totals, saves invoices, and sends emails.
```

Better:

- `InvoiceCalculator`
- `InvoiceRepository`
- `InvoiceMailer`

## Open/Closed Principle

Code should be **open for extension** but **closed for modification**.

Instead of editing a large `if/else` block every time a new payment method is added, define a shared interface:

```text
PaymentMethod.pay(order)
```

Then add new implementations such as:

- `CardPayment`
- `BkashPayment`
- `BankTransferPayment`

## Liskov Substitution Principle

A child class should be usable anywhere its parent class is expected.

If `Square` extends `Rectangle` but breaks the expected behavior of width and height, the inheritance is wrong.

Rule of thumb:

> A subclass should not surprise code that already works with the parent class.

## Interface Segregation Principle

Clients should not be forced to depend on methods they do not use.

Bad example:

```text
Printer.print()
Printer.scan()
Printer.fax()
```

A simple printer should not have to implement `scan()` or `fax()`.

Better:

- `Printable`
- `Scannable`
- `Faxable`

## Dependency Inversion Principle

High-level business logic should depend on **abstractions**, not concrete implementations.

Example:

```text
OrderService depends on PaymentGateway
StripePaymentGateway implements PaymentGateway
```

This makes it easier to test `OrderService` and replace Stripe with another provider later.

## Practical Interview Summary

- **S**: one class, one responsibility
- **O**: add new behavior without rewriting old code
- **L**: child classes must behave like their parent
- **I**: keep interfaces small and focused
- **D**: depend on abstractions, not concrete classes
