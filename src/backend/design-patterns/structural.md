# Structural Patterns

**Structural patterns** describe how objects and classes are composed into larger
structures while keeping those structures flexible and efficient. They focus on
relationships between components rather than how components are created.

## Adapter

**Intent:** Convert the interface of one class into another interface the client
expects, so incompatible types can work together.

**When to use:** When integrating a third-party library or legacy module whose
interface does not match your code, and you cannot change the original.

**Backend example:**

```text
PaymentGateway (your interface)
StripeAdapter implements PaymentGateway by wrapping the Stripe SDK
```

**Trade-offs:** Isolates external dependencies behind your own contract, which
protects core code from vendor changes. The cost is an extra translation layer
that must be kept in sync if either side changes.

## Decorator

**Intent:** Attach additional behavior to an object dynamically by wrapping it,
without modifying the original class.

**When to use:** When you want to add cross-cutting concerns such as logging,
caching, retries, or metrics to an existing object without subclassing.

**Backend example:**

```text
repo = OrderRepository()
repo = CachingRepository(repo)
repo = LoggingRepository(repo)
```

**Trade-offs:** Composes behavior flexibly and follows the open/closed principle.
Many small wrappers can make the call stack deep and harder to trace, and order of
wrapping can matter in non-obvious ways.

## Facade

**Intent:** Provide a single simplified interface over a complex subsystem.

**When to use:** When clients should not need to coordinate many low-level
components, or when you want a clean entry point to a complicated module.

**Backend example:**

```text
CheckoutFacade.placeOrder(cart)
  internally calls inventory, pricing, payment, and shipping services
```

**Trade-offs:** Reduces coupling and gives callers a clear, narrow API. The risk
is that the facade grows into a god object that hides too much and becomes a
bottleneck for every change.

## Proxy

**Intent:** Provide a placeholder or surrogate that controls access to another
object.

**When to use:** For lazy loading, access control, caching, or remote access where
you want to intercept calls to the real object.

**Backend example:**

```text
RemoteServiceProxy adds auth, retries, and a timeout
before forwarding to the real remote service
```

**Trade-offs:** Adds control and optimization transparently to the client. It can
mask the true cost of an operation (a "cheap" call may trigger network or disk
work) and adds a layer that must mirror the real interface.

## Composite

**Intent:** Compose objects into tree structures and let clients treat individual
objects and groups uniformly.

**When to use:** When data is naturally hierarchical and you want the same
operations to work on a leaf or a whole subtree.

**Backend example:**

```text
Permission node and PermissionGroup both expose isAllowed(action)
the group delegates to its children
```

**Trade-offs:** Simplifies client code that walks hierarchies. It can make the
design overly general, and enforcing constraints that apply only to certain node
types becomes awkward when everything shares one interface.

## Bridge

**Intent:** Decouple an abstraction from its implementation so the two can vary
independently.

**When to use:** When both the abstraction and its implementation have multiple
dimensions of variation that would otherwise cause a class explosion.

**Backend example:**

```text
Report (abstraction) -> PdfRenderer | HtmlRenderer (implementation)
SummaryReport and DetailReport each work with any renderer
```

**Trade-offs:** Prevents a combinatorial explosion of subclasses and lets each
side evolve separately. The indirection adds upfront complexity that only pays off
when both dimensions truly vary.

## Mid/Senior Interview Questions and Answers

### 1. How do adapter and facade differ?

**Answer:** An adapter changes an interface so two incompatible types can work
together; it wraps one component to match an expected contract. A facade
simplifies access to a whole subsystem by exposing one narrow interface over many
components.

Adapter is about compatibility for a single dependency. Facade is about hiding
complexity across several. They are sometimes combined, but solve different
problems.

### 2. When would you use a decorator instead of inheritance?

**Answer:** Use a decorator when you want to add behavior at runtime, combine
behaviors freely, or keep cross-cutting concerns out of the core class.
Inheritance fixes behavior at compile time and can lead to a rigid class
hierarchy.

Decorators shine for stacking concerns such as caching plus logging plus retries
on a repository, where every combination would otherwise need its own subclass.

### 3. What problems can a proxy hide from callers?

**Answer:** A proxy can hide latency and failure modes. A call that looks like a
simple method may trigger network requests, retries, cache misses, or remote
errors that the client does not expect.

Senior engineers document and surface these costs, for example through timeouts,
metrics, and clear error handling, so the abstraction does not become a
performance or reliability trap.

### 4. When does a facade become an anti-pattern?

**Answer:** When it grows into a god object that every feature must touch. A
facade that accumulates unrelated responsibilities becomes a change bottleneck and
hides too much, making the system harder to reason about.

Keep facades focused on a coherent use case. If one facade is doing many unrelated
jobs, split it along those responsibilities.

### 5. What problem does the bridge pattern solve that simple inheritance cannot?

**Answer:** Bridge prevents a class explosion when two independent dimensions
vary. With inheritance alone, every combination of abstraction and implementation
needs its own subclass, which grows multiplicatively.

By composing the implementation into the abstraction, each dimension can add new
variants without affecting the other. It is worth the extra indirection only when
both dimensions genuinely change independently.
