# Spring MVC and REST APIs

Spring MVC is the servlet-based web framework commonly used for synchronous
HTTP APIs and server-rendered applications. A controller should translate HTTP
input and output while delegating business workflows to application services.

## Controllers and Routing

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService orders;

    public OrderController(OrderService orders) {
        this.orders = orders;
    }

    @GetMapping("/{id}")
    OrderResponse get(@PathVariable UUID id) {
        return OrderResponse.from(orders.get(id));
    }

    @PostMapping
    ResponseEntity<OrderResponse> create(
            @Valid @RequestBody CreateOrderRequest request) {
        OrderResponse body = OrderResponse.from(orders.create(request));
        URI location = URI.create("/api/orders/" + body.id());
        return ResponseEntity.created(location).body(body);
    }
}
```

Use the HTTP method, status, headers, and representation deliberately. A create
operation commonly returns `201 Created` and a `Location` header; an asynchronous
operation may return `202 Accepted` with a job resource.

## Transport Models

Avoid exposing JPA entities directly as API contracts. Dedicated request and
response models prevent accidental field exposure, lazy-loading surprises,
recursive serialization, and persistence changes leaking into clients.

```java
public record CreateOrderRequest(
        @NotEmpty List<@Valid OrderLineRequest> lines,
        @Size(max = 500) String note) {
}
```

Bean Validation checks the shape of input. Service and domain logic must still
enforce authorization, current state, cross-record rules, and concurrency-safe
database invariants.

## Request Binding

Spring MVC can bind path variables, query parameters, headers, form data,
multipart files, and request bodies. Declare constraints and size limits at the
edge. Do not accept arbitrary sort properties or SpEL-like expressions from a
client; map public options to known internal fields.

Use pagination for collections and impose a maximum page size. Offset pagination
is simple, while keyset pagination is often more stable and efficient for large,
frequently changing datasets.

## Consistent Errors

Centralize exception-to-response mapping with `@RestControllerAdvice`:

```java
@RestControllerAdvice
class ApiExceptionHandler {

    @ExceptionHandler(OrderNotFound.class)
    ProblemDetail orderNotFound(OrderNotFound exception) {
        ProblemDetail problem = ProblemDetail.forStatus(404);
        problem.setTitle("Order not found");
        problem.setDetail(exception.getMessage());
        return problem;
    }
}
```

Use a stable error shape, machine-readable codes where clients need branching,
and safe details. Do not return stack traces, SQL messages, secrets, or internal
class names. Log an unexpected error once with a correlation or trace ID.

## Filters, Interceptors, and Advice

- Servlet filters run around the servlet chain and are suitable for low-level
  HTTP concerns and Spring Security.
- MVC interceptors run around handler selection and invocation.
- Controller advice shares exception handling, binding, and model behavior.
- Argument resolvers create custom controller parameters.

Use each mechanism for cross-cutting transport behavior, not hidden business
logic. Filter order is significant, especially around security, CORS, body
wrapping, and observability.

## External HTTP Calls

Use a managed HTTP client with explicit connect, response, and overall deadlines.
Bound its connection pool and response size. Retry only operations known to be
safe, and propagate cancellation or request deadlines where supported.

Keep the client behind an application-facing interface so the domain does not
depend on transport details. Record outcome and latency without logging tokens
or sensitive payloads.

## API Evolution

Prefer additive changes, tolerant readers, and explicit deprecation. Removing or
renaming fields, narrowing accepted input, and changing nullability can break
clients even if the server compiles. Consumer-driven contract tests can help,
but they complement rather than replace an owned compatibility policy.

