# Object-Oriented PHP

## Classes and Encapsulation

A class should protect useful invariants and expose behavior, not only group
public fields.

```php
final class Order
{
    /** @var list<OrderLine> */
    private array $lines = [];

    public function __construct(
        private readonly OrderId $id,
        private OrderStatus $status = OrderStatus::Draft,
    ) {
    }

    public function addLine(OrderLine $line): void
    {
        if ($this->status !== OrderStatus::Draft) {
            throw new LogicException('Only draft orders can be changed');
        }

        $this->lines[] = $line;
    }
}
```

Constructor property promotion reduces repetition. It does not make every
dependency or domain value suitable as public state.

## Interfaces and Composition

Interfaces define roles used by callers:

```php
interface PaymentGateway
{
    public function charge(PaymentRequest $request): PaymentResult;
}

final class CheckoutService
{
    public function __construct(
        private PaymentGateway $payments,
        private OrderRepository $orders,
    ) {
    }
}
```

Inject dependencies through the constructor and depend on a focused interface
when multiple implementations or a boundary justify it. Do not create an
interface mechanically for every class.

Prefer composition to deep inheritance. Inheritance exposes protected details
and couples subclasses to a parent lifecycle. Use an abstract class only when
there is a stable shared abstraction and substitutability is real.

## `final` and Visibility

`public`, `protected`, and `private` control access. Keep state private unless a
wider contract is intentional. Mark a class or method `final` when extension is
not supported; this prevents consumers from depending on internal behavior.

Newer PHP versions add richer property capabilities such as asymmetric
visibility and property hooks. They can express useful APIs, but adopting them
raises the project's minimum PHP version. Prefer methods when access behavior is
complex or has important side effects.

## Readonly State

A readonly property can be initialized once from its allowed scope. A readonly
class applies compatible restrictions to all instance properties.

```php
final readonly class Money
{
    public function __construct(
        public int $minorUnits,
        public Currency $currency,
    ) {
    }
}
```

Readonly is shallow. If a property contains a mutable object, that object can
still change internally. Arrays cannot be modified through a readonly property
after initialization because that changes the property value.

## Enums

Enums model a closed set of cases:

```php
enum OrderStatus: string
{
    case Draft = 'draft';
    case Paid = 'paid';
    case Cancelled = 'cancelled';

    public function canCancel(): bool
    {
        return $this === self::Draft || $this === self::Paid;
    }
}
```

Use `tryFrom()` for untrusted backed values and handle failure. An enum is a
runtime object; persist its backed value through an explicit mapping and plan
database migrations when cases change.

## Traits

Traits reuse method implementations across unrelated classes. They can be
helpful for small, stateless mechanics, but they inject behavior and state into
the consuming class and can create conflicts or hidden coupling.

Prefer a collaborator when behavior has dependencies, independent identity, or
needs substitution. A trait should not become a substitute for a missing domain
abstraction.

## Magic Methods and Dynamic Behavior

Methods such as `__get`, `__set`, `__call`, `__invoke`, `__serialize`, and
`__unserialize` support framework and language protocols. Use them sparingly:
dynamic property access can hide typos, weaken static analysis, and make APIs
undiscoverable.

Avoid unsafe deserialization of attacker-controlled data. A class's magic
deserialization hooks can execute behavior as the object graph is restored.

## Dependency Injection Containers

A container creates application objects and wires their dependencies. It should
mainly be used at the composition root. Passing the container into services and
looking up dependencies on demand is the service locator pattern; it hides the
class's real requirements.

Business objects should remain constructible with ordinary PHP wherever
possible. Framework configuration can bind interfaces to infrastructure
implementations at the application edge.

