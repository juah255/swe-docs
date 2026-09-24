# Fundamentals and Auto-configuration

## The Application Context

Spring's `ApplicationContext` creates, connects, and manages application objects
called beans. It also supplies infrastructure for events, resources,
configuration, validation, transactions, and lifecycle callbacks.

A Spring Boot application starts by preparing an environment, creating the
appropriate application context, registering configuration, refreshing the
context, and running startup callbacks. A failure during bean creation normally
prevents the application from becoming ready.

## `@SpringBootApplication`

The main annotation combines three concerns:

- `@SpringBootConfiguration` marks the primary Boot configuration.
- `@EnableAutoConfiguration` opts into conditional configuration.
- `@ComponentScan` discovers components from the application's package.

Use one primary application configuration. Broad component scans can pull test
fixtures or unrelated modules into the context, so prefer deliberate package
boundaries over scanning the entire organization namespace.

## Starters and Dependency Management

A starter is a convenient dependency descriptor, not runtime code by itself.
For example, a web starter brings compatible web, JSON, validation, and logging
dependencies. Boot's dependency management aligns transitive versions tested
together.

Avoid overriding managed versions casually. A locally newer library can be
binary-incompatible with the Spring generation selected by the Boot release.
When an override is required, test the affected integration and document why.

## How Auto-configuration Works

Auto-configuration classes use conditions such as:

- a class is present or absent;
- a bean already exists or is missing;
- an application property has a value;
- the application is servlet, reactive, or non-web;
- a resource or JNDI entry is available.

If a JDBC driver and suitable APIs are present and no custom `DataSource` exists,
Boot can configure one. When the application declares its own relevant bean,
auto-configuration commonly backs off.

```java
@Configuration(proxyBeanMethods = false)
class ClockConfiguration {

    @Bean
    Clock applicationClock() {
        return Clock.systemUTC();
    }
}
```

Define application beans to customize intended extension points. Avoid importing
internal auto-configuration classes or depending on their implementation
details.

## Diagnosing Conditions

Start with the condition evaluation report when expected configuration is
missing or an unexpected bean appears. Running with `--debug` reports which
conditions matched and why. Actuator's `conditions` endpoint can provide similar
diagnostics when it is safely exposed.

Also inspect:

- the resolved dependency graph;
- registered bean names and types;
- active profiles and property sources;
- configuration property binding failures;
- component-scan boundaries.

Excluding an auto-configuration is a last-mile choice, not the first debugging
step:

```java
@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
public class ToolApplication {
}
```

## Lifecycle Hooks

`ApplicationRunner` and `CommandLineRunner` execute after the context starts.
Use them for bounded startup work, not for indefinite background loops.

```java
@Component
class ReferenceDataVerifier implements ApplicationRunner {

    @Override
    public void run(ApplicationArguments args) {
        // Verify required reference data and fail clearly if it is invalid.
    }
}
```

Heavy database migrations, remote synchronization, and one-off maintenance jobs
usually belong in deployment jobs or dedicated applications. Keeping startup
fast and deterministic improves rollouts and recovery.

## Framework Proxies

Several Spring features are applied through proxies, including method security,
transactions, caching, retries, and async execution. A call from one method to
another on the same object does not pass through the proxy, so an annotation on
the called method may not take effect.

Design a clear public service boundary rather than working around proxy behavior
with self-injection. Remember that `private` methods and objects created with
`new` outside the container are not normal interception points.

