# Behavioral Patterns

**Behavioral patterns** describe how objects communicate and how responsibility is
divided at runtime. They focus on the flow of control and the assignment of
behavior rather than on construction or structure.

## Strategy

**Intent:** Define a family of interchangeable algorithms behind one interface and
select the implementation at runtime.

**When to use:** When behavior changes based on a runtime condition: payment
methods, pricing rules, notification channels, or login methods.

**Backend example:**

```text
PaymentStrategy.pay(order)
  CardPayment | WalletPayment | BankTransferPayment
```

**Trade-offs:** Removes large conditionals and isolates each algorithm for easy
testing. It adds classes and requires a way to choose the strategy, which is
overhead when there are only one or two stable variants.

## Observer

**Intent:** Let an object notify a set of listeners automatically when its state
changes, without knowing who they are.

**When to use:** For event-driven side effects where one action triggers several
independent reactions.

**Backend example:**

```text
order placed -> send email -> notify admin -> update analytics
```

**Trade-offs:** Strongly decouples the publisher from listeners. The danger is
failure handling and ordering: if observers run synchronously, one failing
listener can break the main operation, so many systems push events to a queue
instead.

## Command

**Intent:** Encapsulate a request as an object, allowing it to be queued, logged,
retried, or undone.

**When to use:** For task queues, job processing, undo/redo, or when requests need
to be recorded and replayed.

**Backend example:**

```text
SendEmailCommand, ChargeCardCommand placed on a queue
a worker calls command.execute() later
```

**Trade-offs:** Decouples the sender from the receiver and makes operations
first-class, which enables queuing and auditing. It adds a class per action and
can be excessive for simple, immediate calls.

## Template Method

**Intent:** Define the skeleton of an algorithm in a base class and let subclasses
override specific steps.

**When to use:** When several flows share the same overall sequence but differ in a
few steps, such as import pipelines or report generation.

**Backend example:**

```text
ImportJob.run(): validate -> parse -> transform -> save
CsvImportJob overrides parse(); JsonImportJob overrides parse()
```

**Trade-offs:** Removes duplication of the shared flow and enforces a consistent
sequence. It relies on inheritance, which can be rigid; strategy or composition is
often more flexible when steps vary widely.

## State

**Intent:** Let an object change its behavior when its internal state changes, so
it appears to change class.

**When to use:** When an entity moves through a lifecycle with state-specific rules,
such as an order or a subscription.

**Backend example:**

```text
Order: Pending -> Paid -> Shipped -> Delivered
each state allows or rejects actions like cancel() or refund()
```

**Trade-offs:** Replaces tangled conditionals on a status field with clear,
per-state behavior and legal transitions. It adds a class per state, which is
overhead for simple two-state flags.

## Iterator

**Intent:** Provide a way to traverse the elements of a collection sequentially
without exposing its underlying representation.

**When to use:** When you need uniform traversal over a custom collection, or
memory-efficient streaming over large or paginated data.

**Backend example:**

```text
PagedResults yields one page of records at a time
callers loop without knowing about the underlying API paging
```

**Trade-offs:** Decouples traversal from storage and supports lazy iteration over
large datasets. Most languages already provide iterators natively, so a custom one
is only worth writing for non-trivial sources such as paginated APIs.

## Chain of Responsibility

**Intent:** Pass a request along a chain of handlers, each of which can process it
or forward it to the next.

**When to use:** For request pipelines where multiple independent steps may handle
or transform a request: middleware, validation, or authorization stages.

**Backend example:**

```text
request -> AuthHandler -> RateLimitHandler -> ValidationHandler -> route
```

**Trade-offs:** Decouples senders from handlers and lets the pipeline be
reconfigured easily. The downside is that flow can be hard to trace, and a request
may fall through unhandled if no link in the chain processes it.

## Mid/Senior Interview Questions and Answers

### 1. How do you choose between strategy and template method?

**Answer:** Strategy uses composition: it injects an interchangeable algorithm,
which is flexible and testable. Template method uses inheritance: it fixes the
overall flow in a base class and lets subclasses fill in steps.

Prefer strategy when behavior must vary independently and at runtime. Template
method fits when the sequence is fixed and only a few steps differ, but it couples
the variants to a base class hierarchy.

### 2. What are the failure-handling risks of the observer pattern?

**Answer:** If observers run synchronously in the same transaction, one failing or
slow listener can break or stall the main operation. Ordering between observers can
also create hidden coupling.

In production backends this is usually solved by emitting events to a message
queue, so side effects run asynchronously and can be retried independently of the
core workflow.

### 3. Why is the command pattern useful for job processing?

**Answer:** It turns a request into a serializable object that captures everything
needed to run it. That object can be placed on a queue, persisted, retried after a
crash, logged for audit, or even reversed for undo.

This first-class representation is what enables reliable background processing and
replay, which a direct method call cannot offer.

### 4. When should you reach for the state pattern instead of a status field?

**Answer:** Reach for it when an entity has several states, each with distinct
allowed actions and transitions, and the conditional logic on the status field is
growing complex.

The state pattern centralizes each state's rules and makes illegal transitions
explicit. For a simple boolean or two-state flag, it is unnecessary overhead.

### 5. What is a common bug in chain of responsibility implementations?

**Answer:** A request that no handler processes and that silently falls off the end
of the chain. Without a default or terminal handler, such requests disappear
without error.

Tracing is also harder because behavior is spread across links. Mitigate both with
a guaranteed final handler and clear logging of which link handled each request.
