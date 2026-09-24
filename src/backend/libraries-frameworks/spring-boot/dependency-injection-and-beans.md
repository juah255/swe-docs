# Dependency Injection and Beans

## Declaring Beans

Spring beans can be discovered with stereotype annotations or created by
`@Bean` methods.

- `@Component` is a general managed component.
- `@Service` communicates application or domain service intent.
- `@Repository` marks persistence adapters and participates in exception
  translation.
- `@Controller` and `@RestController` are web entry points.
- `@Bean` integrates library types or construction requiring explicit logic.

The stereotypes are not architectural enforcement. Package rules and tests can
enforce dependencies when boundaries matter.

## Constructor Injection

Use constructor injection for required collaborators:

```java
@Service
public class CheckoutService {

    private final OrderRepository orders;
    private final PaymentGateway payments;

    public CheckoutService(
            OrderRepository orders,
            PaymentGateway payments) {
        this.orders = orders;
        this.payments = payments;
    }
}
```

This makes dependencies explicit, permits immutable fields, and supports plain
unit construction. Avoid field injection because it hides requirements and
ties tests to reflection or a Spring context.

## Multiple Candidates

When several beans implement an interface, express the choice intentionally:

- use `@Qualifier` for a named role;
- use `@Primary` for a sensible default;
- inject a collection or map when all strategies are needed;
- select via configuration during bean creation.

```java
@Bean
NotificationSender transactionalSender(
        @Qualifier("emailGateway") MessageGateway gateway) {
    return new NotificationSender(gateway);
}
```

Do not resolve ambiguity by depending on accidental bean names.

## Scope and State

The default scope is singleton: one bean instance per application context.
Singleton beans serve concurrent requests, so they should generally be stateless
or use thread-safe state.

Prototype creates a new bean when the container resolves it. Web applications
also offer request and session scopes. Injecting a shorter-lived bean into a
singleton requires a proxy or provider; first ask whether request data should
instead be passed as a method argument.

Thread-local state needs disciplined cleanup and does not automatically flow
across executor threads or reactive pipelines.

## Optional Dependencies and Conditions

Optional collaborators can be modeled with `ObjectProvider`, collections, or
conditional configuration. Avoid sprinkling nullable dependencies throughout
business code.

Library auto-configuration commonly uses conditions to provide a default bean
only when the application has not supplied one. Application code should expose
small interfaces around external systems so replacements remain straightforward.

## Circular Dependencies

A constructor cycle usually signals mixed responsibilities:

```text
OrderService -> PaymentService -> OrderService
```

Do not hide it with field injection or global permission for circular references.
Extract the coordinating workflow, publish a carefully scoped domain event, or
redesign ownership so dependencies point in one direction.

## Lifecycle and Cleanup

The container can call initialization and destruction callbacks. Prefer standard
annotations or bean destroy methods for bounded setup and cleanup. Resource
pools, clients, and executors must close gracefully.

Avoid remote calls in constructors. They make context creation slow and fragile.
If readiness depends on a remote system, represent that through health policy
and a deliberate initialization process.

