# Spring boot

Spring Boot project structure, configuration, and operational notes.

## Core Concepts

### What is Spring Boot?

Spring Boot is an opinionated framework built on top of the Spring Framework.
It removes most of the manual configuration required by classic Spring by
providing auto-configuration, embedded servers (Tomcat, Jetty, Undertow),
starter dependencies, and production-ready defaults.

A Spring Boot application is a normal Java program with a `main` method that
boots an ApplicationContext:

```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

### `@SpringBootApplication`

`@SpringBootApplication` is a composite annotation that combines:

- `@SpringBootConfiguration` — marks the class as a configuration source.
- `@EnableAutoConfiguration` — triggers Spring Boot's auto-configuration.
- `@ComponentScan` — scans the package (and subpackages) for beans.

Placing the main class at the top-level package usually gives the intended
scan scope.

### Beans and Dependency Injection

The IoC container manages objects called **beans**. Beans are declared by
stereotype annotations (`@Component`, `@Service`, `@Repository`,
`@Controller`, `@RestController`) or by `@Bean` methods in `@Configuration`
classes.

Constructor injection is preferred over field injection because it makes
dependencies explicit and testable:

```java
@Service
public class UserService {
    private final UserRepository users;

    public UserService(UserRepository users) {
        this.users = users;
    }
}
```

Common scopes are `singleton` (default) and `prototype`. Web scopes include
`request` and `session`.

### Starters and Auto-configuration

Starter dependencies (e.g., `spring-boot-starter-web`,
`spring-boot-starter-data-jpa`, `spring-boot-starter-security`) bring in a
curated set of libraries. Auto-configuration then wires sensible defaults
based on what is on the classpath.

Override defaults by defining your own bean of the same type, or by disabling
specific auto-configuration classes with
`@SpringBootApplication(exclude = ...)`.

### Configuration and Profiles

Configuration lives in `application.properties` or `application.yml`. Values
can be injected with `@Value("${...}")` or grouped into typed classes with
`@ConfigurationProperties`.

```yaml
app:
  api:
    base-url: https://api.example.com
    timeout: 5s
```

```java
@ConfigurationProperties(prefix = "app.api")
public record ApiProps(URI baseUrl, Duration timeout) {}
```

Profiles (`application-dev.yml`, `application-prod.yml`) enable
environment-specific configuration, activated via `SPRING_PROFILES_ACTIVE`.

### Web Layer

Controllers handle HTTP:

```java
@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService users;

    public UserController(UserService users) { this.users = users; }

    @GetMapping("/{id}")
    public UserDto get(@PathVariable Long id) {
        return users.findById(id);
    }

    @PostMapping
    public ResponseEntity<UserDto> create(@RequestBody @Valid CreateUserDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(users.create(dto));
    }
}
```

`@ControllerAdvice` with `@ExceptionHandler` centralizes exception-to-response
mapping.

### Spring Data JPA

Spring Data JPA is a Spring module that simplifies database access by letting
you define repository interfaces instead of writing most data-access code
manually.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    User findByEmail(String email);
}
```

When a repository extends `JpaRepository`, Spring automatically provides
common CRUD operations such as `save()`, `findById()`, and `findAll()`. It can
also derive queries from method names, so `findByEmail(String email)` works
without writing SQL manually.

You only define the repository interface. At runtime, Spring Data JPA
generates the implementation automatically using proxy classes.

### Transactions

`@Transactional` starts a transaction around a method call. It is
proxy-based, so self-invocation inside the same class bypasses the proxy and
the transaction is not applied.

```java
@Service
public class OrderService {

    @Transactional
    public void placeOrder(Order order) {
        // save + charge + publish event
    }
}
```

Read-only transactions (`@Transactional(readOnly = true)`) can hint the
persistence provider and improve performance for queries.

### Validation

Spring integrates with Jakarta Bean Validation (`jakarta.validation`).
`@Valid` on a controller argument triggers validation of the DTO:

```java
public record CreateUserDto(
    @NotBlank String name,
    @Email String email,
    @Size(min = 8) String password
) {}
```

Validation failures produce `MethodArgumentNotValidException`, which a
`@ControllerAdvice` typically converts into a standardized error response.

### Security Basics

`spring-boot-starter-security` locks down the application by default.
Configuration is done through a `SecurityFilterChain` bean:

```java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/public/**").permitAll()
            .anyRequest().authenticated())
        .oauth2ResourceServer(oauth -> oauth.jwt(withDefaults()))
        .build();
}
```

Method-level security (`@PreAuthorize`, `@PostAuthorize`) protects service
methods based on authorities or SpEL expressions.

### Actuator and Observability

`spring-boot-starter-actuator` exposes operational endpoints such as
`/actuator/health`, `/actuator/info`, `/actuator/metrics`, and
`/actuator/prometheus`. Endpoints must be secured and selectively exposed:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus
```

Micrometer bridges metrics to Prometheus, Datadog, or CloudWatch.

### Testing

Spring Boot ships focused test slices to avoid loading the full context:

- `@SpringBootTest` — full application context.
- `@WebMvcTest` — controllers, filters, and MVC infrastructure only.
- `@DataJpaTest` — JPA repositories with an embedded database.
- `@MockBean` / `@MockitoBean` — replace beans with mocks in the context.

Testcontainers is commonly used to run real databases and message brokers in
integration tests.

## Mid/Senior Interview Questions and Answers

### 1. What problem does Spring Boot solve?

**Answer:** Spring Boot reduces Spring application setup by providing
auto-configuration, embedded servers, starter dependencies, production
actuator endpoints, and convention-based defaults.

The senior point is understanding what Boot configures automatically and how to
override it intentionally when production requirements differ from defaults.

### 2. How does dependency injection work in Spring?

**Answer:** Spring creates and manages beans in an application context. Classes
declare dependencies, usually through constructors, and Spring injects matching
beans at runtime.

Constructor injection is preferred because it makes required dependencies
explicit and improves testability.

### 3. What are common Spring Data JPA pitfalls?

**Answer:** Common pitfalls include N+1 queries, lazy loading outside
transactions, accidental large object graphs, missing indexes, inefficient
derived queries, and relying only on entity validation instead of database
constraints.

Senior engineers inspect generated SQL and design transactions explicitly.

### 4. How should transactions be handled in Spring services?

**Answer:** Use transactions around service methods that perform a consistent
unit of work. Keep transactions short and avoid remote API calls inside them
unless carefully designed.

Understand proxy-based behavior: self-invocation may bypass `@Transactional`
because the call does not go through the Spring proxy.

### 5. What production features should a Spring Boot service expose?

**Answer:** It should expose health checks, metrics, structured logs,
configuration management, graceful shutdown, timeouts, connection pools, and
clear error handling.

Spring Boot Actuator is commonly used for health and metrics, but endpoints must
be secured appropriately.
