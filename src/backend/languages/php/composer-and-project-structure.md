# Composer and Project Structure

Composer resolves packages, records application dependencies, verifies platform
requirements, and generates an autoloader. It does not sandbox third-party code:
packages and permitted plugins or scripts execute with the build user's access.

## `composer.json`

Declare the runtime, extensions, packages, development tools, and autoload rules:

```json
{
  "require": {
    "php": "^8.3",
    "ext-json": "*",
    "psr/log": "^3.0"
  },
  "require-dev": {
    "phpunit/phpunit": "^12.0"
  },
  "autoload": {
    "psr-4": {
      "App\\": "src/"
    }
  },
  "autoload-dev": {
    "psr-4": {
      "App\\Tests\\": "tests/"
    }
  }
}
```

Use constraints compatible with the real deployment matrix. Declare required
`ext-*` packages instead of assuming every PHP installation has the same
extensions.

## Install Versus Update

- `composer update` resolves constraints and writes a new lock file.
- `composer install` installs the versions already recorded in the lock file.

Commit `composer.lock` for applications so local, CI, and production builds use
the same dependency graph. Reusable libraries commonly omit the lock from the
published contract so CI can test multiple allowed dependency versions.

Review lock changes like source code. An apparently small direct update may
change many transitive packages.

## PSR-4 Autoloading

PSR-4 maps a namespace prefix to a directory. A class named
`App\Billing\InvoiceService` under the example mapping belongs at
`src/Billing/InvoiceService.php`.

Include Composer's generated autoloader at the front controller or CLI entry
point:

```php
require dirname(__DIR__) . '/vendor/autoload.php';
```

Regenerate autoload metadata after changing mappings. Production builds should
use optimized autoloading. An authoritative class map is faster for misses but
is incompatible with classes generated after the build, so enable it only when
the application supports that mode.

## Useful Verification

```bash
composer validate --strict
composer install --no-dev --prefer-dist --optimize-autoloader
composer check-platform-reqs --no-dev
composer audit
```

Do not hide platform incompatibilities with `--ignore-platform-reqs` in a
production build. `composer audit` identifies known advisories but does not prove
a dependency is safe or correctly configured.

## Project Layout

A framework may provide its own conventions. A framework-neutral service might
look like:

```text
bin/                 # CLI entry points
config/              # application wiring and settings
public/index.php     # HTTP front controller
src/
  Catalog/
  Ordering/
  Shared/
tests/
migrations/
composer.json
composer.lock
```

Group code by business capability as the system grows. A repository-wide
`Controllers`, `Services`, and `Repositories` split can scatter every change
across unrelated folders.

Keep domain and application code independent of superglobals and framework
containers. Adapt HTTP, database, queue, and vendor APIs at the edges.

## PHP-FIG Standards

Common interoperability standards include PSR-3 logging, PSR-4 autoloading,
PSR-6 and PSR-16 caching, PSR-7 HTTP messages, PSR-11 containers, PSR-15 HTTP
handlers and middleware, PSR-17 factories, PSR-18 HTTP clients, and PSR-20 clocks.

These interfaces make components replaceable at integration boundaries. They do
not require the application to wrap every library behind another abstraction.

