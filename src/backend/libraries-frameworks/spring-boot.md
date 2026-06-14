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
