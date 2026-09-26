# Testing and Code Quality

A useful PHP test suite keeps domain logic fast and framework-independent while
using integration tests where behavior depends on the container, database,
queue, filesystem, or HTTP stack.

## Test Layers

- Unit tests exercise one object or function with controlled collaborators.
- Integration tests verify databases, caches, queues, and external adapters.
- HTTP tests cover routing, middleware, validation, authentication, and response
  contracts.
- End-to-end tests protect a small number of critical user journeys.
- Static analysis and automated style checks catch defects without execution.

PHPUnit is the established testing framework; Pest offers another syntax on top
of the ecosystem. Framework-specific tools can boot an application and provide
HTTP or database helpers.

## Plain Unit Tests

```php
final class DiscountPolicyTest extends TestCase
{
    public function testPremiumCustomerReceivesDiscount(): void
    {
        $policy = new DiscountPolicy(
            new DateTimeImmutable('2026-01-15T10:00:00Z'),
        );

        $discount = $policy->for(CustomerTier::Premium, Money::usd(10_000));

        self::assertSame(1_000, $discount->minorUnits);
    }
}
```

Prefer direct construction and value assertions. Mock external boundaries or
complex collaborators, not every object in the call graph. A test that mirrors
private method calls can pass while behavior is wrong and breaks during harmless
refactoring.

Inject a PSR-20 clock or application clock instead of relying on the current
time. Avoid `sleep()` and shared global state.

## Data Providers and Fixtures

Data providers express the same behavior over meaningful cases. Name each case
so failures describe the scenario.

Keep fixtures small and explicit. Builders or object mothers can improve intent,
but defaults should not hide the one field that makes a test pass. Database tests
need deterministic cleanup through rollback, truncation, or isolated schemas.

## Integration Boundaries

Use the same database engine and migration history as production for SQL,
locking, constraint, and type behavior. Containerized dependencies can provide a
repeatable environment.

Fake payment, email, and HTTP services at unit boundaries. Add focused contract
tests against a realistic server for serialization, authentication, timeout,
and error behavior. Ordinary tests should not depend on the public internet.

For queues, test handler behavior and separately verify serialization, routing,
retry, idempotency, and dead-letter configuration.

## Static Analysis

PHPStan and Psalm infer types beyond native declarations. Increase strictness
gradually, fix findings rather than growing a permanent ignore file, and define a
baseline only as a measured migration aid.

Static analysis is especially valuable for:

- array shapes and generic collections;
- impossible null access and return paths;
- incorrect interface implementations;
- dead branches and unused results;
- framework container and ORM metadata through supported extensions.

It does not validate runtime configuration, SQL semantics, permissions, or
external payloads.

## Formatting and Automated Checks

Adopt one coding standard, commonly PER Coding Style or an established project
standard, and enforce it automatically. A delivery pipeline commonly runs:

```bash
composer validate --strict
vendor/bin/phpunit
vendor/bin/phpstan analyse
vendor/bin/php-cs-fixer check --diff
composer audit
```

Use the commands configured by the actual project. Add mutation testing or
property-based tests where their signal justifies their cost. Code coverage shows
executed lines, not whether important behavior was asserted.

## High-Value Cases

Test malformed and boundary input, authorization between users or tenants,
duplicate submissions, transaction rollback, retry classification, concurrent
updates, upload limits, time zones, serialization compatibility, and safe error
responses. These paths reveal more than another happy-path controller test.

