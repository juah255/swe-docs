# Spring Boot

Spring Boot is an opinionated way to build production-ready applications on the
Spring Framework. It combines Spring's dependency injection and programming
model with auto-configuration, curated dependency management, embedded servers,
externalized configuration, testing support, and operational endpoints.

## What Spring Boot Adds

Spring Framework supplies the application context, dependency injection,
transactions, web frameworks, data abstractions, and integration APIs. Spring
Boot makes those pieces easier to assemble and operate.

| Spring Boot feature | Purpose |
| --- | --- |
| Starters | Curated dependency sets for common capabilities |
| Auto-configuration | Configures beans when matching classes and settings exist |
| Embedded servers | Packages an HTTP application as an executable process |
| External configuration | Separates deploy-time values from application code |
| Actuator | Adds health, metrics, and diagnostic endpoints |
| Test support | Provides full-context and focused application test slices |

Boot does not remove Spring's underlying behavior. When something surprising
happens, inspect the beans, condition evaluation, proxy boundaries, HTTP stack,
and persistence context rather than treating auto-configuration as magic.

## Minimal Application

```java
package com.example.orders;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class OrdersApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrdersApplication.class, args);
    }
}
```

`@SpringBootApplication` combines application configuration, auto-configuration,
and component scanning. Put the main class in a root package so the intended
controllers, services, repositories, and configuration are discovered.

## A Typical Request

```text
client
  -> load balancer / reverse proxy
  -> embedded servlet or reactive server
  -> security and application filters
  -> controller
  -> application service
  -> repository / external client / message broker
  -> response and observability instrumentation
```

Controllers should translate transport concerns, services should coordinate use
cases and transaction boundaries, and repositories should express persistence.
These are design responsibilities, not mandatory package names.

## Common Application Styles

- **Spring MVC** for servlet-based APIs and server-rendered applications.
- **Spring WebFlux** for reactive, non-blocking request pipelines.
- **Batch and messaging applications** that may not expose HTTP at all.
- **Modular monoliths** with explicit in-process module boundaries.
- **Microservices** when independent deployment is justified by ownership or
  operational needs.

Do not combine MVC and WebFlux only to appear asynchronous. Pick an execution
model that matches the libraries, workload, team, and operational environment.

## Version Awareness

This section uses modern Java, Jakarta packages, and bean-based security
configuration. Spring Boot maintains several stable release lines, and major
versions can change Java requirements, dependency generations, package names,
and defaults. Use Boot's dependency management and read the reference
documentation for the exact version deployed by the project.

## Suggested Learning Path

1. Learn the application context, beans, dependency injection, and
   auto-configuration.
2. Understand configuration properties and profiles.
3. Build a Spring MVC API with validation and consistent errors.
4. Add persistence with explicit transactions and migrations.
5. Configure authentication and authorization with Spring Security.
6. Test at unit, slice, and integration levels.
7. Add messaging, caching, observability, and production controls as needed.

