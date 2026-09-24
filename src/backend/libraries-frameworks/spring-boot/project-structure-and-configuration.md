# Project Structure and Configuration

## Organize Around Capabilities

The generated `controller`, `service`, and `repository` layers are useful for a
small example, but a large global layer structure scatters one feature across
the repository. Grouping by capability keeps related code close:

```text
src/main/java/com/example/store/
  StoreApplication.java
  shared/
  catalog/
    CatalogController.java
    CatalogService.java
    Product.java
    ProductRepository.java
  ordering/
    api/
    application/
    domain/
    infrastructure/
src/main/resources/
  application.yaml
  db/migration/
```

Use deeper application, domain, and infrastructure packages where the domain
complexity earns them. Package names should reveal ownership and dependency
direction, not add ceremony.

## Externalized Configuration

Spring Boot can load configuration from packaged files, external files,
environment variables, system properties, command-line arguments, and imported
sources. Later, higher-precedence sources can override earlier ones.

```yaml
orders:
  payment:
    base-url: https://payments.example.com
    connect-timeout: 500ms
    read-timeout: 2s
```

Prefer typed configuration properties for a related group:

```java
@ConfigurationProperties("orders.payment")
public record PaymentProperties(
        URI baseUrl,
        Duration connectTimeout,
        Duration readTimeout) {
}
```

Enable property scanning in the main application or register the type explicitly.
Add Jakarta Validation constraints and `@Validated` when invalid configuration
should fail startup.

Typed properties provide conversion, metadata, validation, and discoverability.
Use `@Value` sparingly for isolated values; scattered string expressions are
harder to audit and refactor.

## Profiles

Profiles conditionally activate beans or configuration documents. They are
useful for broad environment modes or optional capabilities:

```yaml
spring:
  config:
    activate:
      on-profile: local
```

Avoid building an untestable matrix such as `prod`, `prod-eu`, `prod-blue`, and
`prod-special-customer`. Prefer normal properties for independent choices and
keep profile-specific behavior small.

Do not use profiles as the only security boundary. A production secret or
dangerous endpoint must remain protected even if a profile is misconfigured.

## Secrets

Do not store production secrets in source-controlled configuration or container
images. Inject them from the deployment platform or a secret manager, restrict
access, and plan rotation. Avoid printing the environment or bound properties;
diagnostic endpoints and startup logs can expose sensitive data.

## Configuration Classes

Use focused configuration classes for infrastructure integration:

```java
@Configuration(proxyBeanMethods = false)
@EnableConfigurationProperties(PaymentProperties.class)
class PaymentConfiguration {

    @Bean
    PaymentClient paymentClient(PaymentProperties properties) {
        return new PaymentClient(properties.baseUrl());
    }
}
```

`proxyBeanMethods = false` avoids full configuration-class method interception
when `@Bean` methods do not call one another to obtain managed instances. Prefer
method parameters for bean dependencies.

## Build and Runtime Configuration

Keep build-time and runtime concerns distinct. The build selects code and
dependency versions; runtime configuration selects endpoints, credentials,
limits, and feature behavior. A single verified artifact should be promotable
across environments.

Validate required configuration before serving traffic. Provide safe defaults
only when a default is genuinely valid; missing credentials or an invalid URL
should fail clearly rather than surface during the first request.

