# Spring boot

Spring Boot project structure, configuration, and operational notes.

## Spring Data JPA

Spring Data JPA is a Spring module that simplifies database access by letting you define repository interfaces instead of writing most data-access code manually.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    User findByEmail(String email);
}
```

When a repository extends `JpaRepository`, Spring automatically provides common CRUD operations such as `save()`, `findById()`, and `findAll()`. It can also derive queries from method names, so `findByEmail(String email)` works without writing SQL manually.

You only define the repository interface. At runtime, Spring Data JPA generates the implementation automatically using proxy classes.

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
