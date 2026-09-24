# Testing

A balanced Spring Boot suite uses fast tests for application logic, focused
Spring slices for framework integration, and a smaller number of full-system
tests against realistic dependencies.

## Plain Unit Tests

Construct services directly with fakes or mocks when testing branching and
domain behavior:

```java
class CheckoutServiceTest {

    private final OrderRepository orders = mock(OrderRepository.class);
    private final PaymentGateway payments = mock(PaymentGateway.class);
    private final CheckoutService service =
        new CheckoutService(orders, payments);

    @Test
    void rejectsAnAlreadyPaidOrder() {
        // arrange, act, and assert without loading Spring
    }
}
```

Loading an application context does not improve a test whose subject only needs
ordinary Java objects.

## Test Slices

Slices load a focused part of the application:

- `@WebMvcTest` for MVC controllers and related web infrastructure;
- `@WebFluxTest` for reactive controllers;
- `@DataJpaTest` for JPA repositories and mappings;
- `@JsonTest` for JSON serialization;
- other technology-specific slices for supported integrations.

```java
@WebMvcTest(OrderController.class)
class OrderControllerTest {

    @Autowired
    MockMvc mvc;

    @MockitoBean
    OrderService orders;
}
```

The annotation used to replace a bean with Mockito varies across supported
Spring generations; older projects may use Boot's `@MockBean`. Follow the
project's framework version rather than copying an incompatible example.

Slices are not architectural rules. Import the small configuration required by
the subject, but avoid gradually rebuilding the full application in every slice.

## Full Application Tests

`@SpringBootTest` loads the application context. A mock web environment is fast
for in-process checks; a random port starts a real server and lets an HTTP client
exercise the network stack.

Server and test client run on different threads in a real-server test. A test
transaction does not automatically roll back server-side work. Clean data
explicitly or isolate it per test.

Use full tests for wiring, security chains, serialization, configuration, and
multi-layer workflows—not for every edge case already covered by unit tests.

## Real Dependencies with Testcontainers

An embedded database can differ from production in SQL, locking, indexes, and
types. Testcontainers can run the actual database or broker in a container.
Spring Boot service connections can supply connection details for supported
containers.

Keep migrations enabled so integration tests verify the production schema
history. Reuse containers where safe, but reset application state deterministically.

## Security Tests

Test unauthenticated, insufficient-scope, authorized, cross-user, and
cross-tenant cases. Include CSRF behavior for cookie-authenticated endpoints and
claim-to-authority mapping for resource servers. A controller success test with
security filters disabled does not validate policy.

## Contract and Messaging Tests

Verify request and event schemas, headers, compatibility, duplicate handling,
and malformed input. A broker integration test should cover serialization and
listener configuration; unit tests should cover handler logic and retries
without waiting on real clocks.

## Keeping Tests Useful

- Use a controllable `Clock` instead of sleeping.
- Avoid test order, shared mutable state, and fixed ports.
- Assert behavior and contracts rather than incidental implementation calls.
- Keep fixtures small and name builders by domain intent.
- Check important query counts or plans without making every test brittle.
- Run migration, startup, and production-configuration smoke tests in delivery.

