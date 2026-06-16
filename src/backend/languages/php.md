# PHP

PHP is widely used for web applications, APIs, CMS platforms, and backend
systems through frameworks such as Laravel and Symfony. Mid-level and senior
interviews usually focus on runtime behavior, typing, Composer, database
access, security, and maintainable application architecture.

## Questions and Answers

### 1. How does the PHP request lifecycle work?

**Answer:** In a common PHP-FPM setup, a web server such as Nginx receives the
HTTP request and forwards it to PHP-FPM. PHP-FPM runs the PHP code and returns a
response to the web server.

PHP traditionally uses a shared-nothing request model. Each request starts with
fresh application state, although code and metadata may be cached by OPcache.

This model simplifies isolation but means expensive bootstrapping should be
optimized with autoloading, OPcache, dependency injection containers, and
framework caching.

### 2. What does `declare(strict_types=1)` do?

**Answer:** `declare(strict_types=1)` enables strict scalar type checking for
function calls made from that file.

Without strict types, PHP may coerce scalar values. With strict types, passing a
string where an `int` is required can throw a `TypeError`.

Use strict types in modern PHP codebases to make type errors visible earlier.
It does not replace validation for external input.

### 3. What is the difference between arrays and objects in PHP?

**Answer:** PHP arrays are ordered maps. They can behave like lists, maps, or a
mix of both. Objects represent instances of classes with properties and methods.

Use arrays for simple lists and associative data. Use objects for domain models,
DTOs, services, and behavior-rich structures.

Senior-level concern: large arrays can be memory-heavy. For large data streams,
prefer generators, pagination, cursors, or chunked processing.

### 4. How does Composer autoloading work?

**Answer:** Composer generates an autoloader that maps class names to files.
Most modern PHP projects use `PSR-4` autoloading.

Example mapping:

```json
{
  "autoload": {
    "psr-4": {
      "App\\": "src/"
    }
  }
}
```

When `App\\Service\\UserService` is referenced, Composer can load it from
`src/Service/UserService.php`.

Run `composer dump-autoload` after changing autoload configuration.

### 5. How should PHP applications handle database access?

**Answer:** Use parameterized queries through PDO, a query builder, or an ORM.
Never concatenate untrusted input into SQL.

Important practices:

- use prepared statements;
- use transactions for multi-step writes;
- set proper connection error modes;
- handle deadlocks and retries where appropriate;
- avoid N+1 queries in ORMs.

Database constraints should still enforce important rules. Application
validation alone is not enough.

### 6. What is dependency injection, and why is it useful?

**Answer:** Dependency injection means passing an object's dependencies from the
outside instead of creating them directly inside the class.

Benefits:

- easier testing;
- lower coupling;
- clearer dependencies;
- easier replacement of implementations;
- better separation between business logic and infrastructure.

Framework service containers automate much of this, but classes should still
have clear constructor dependencies.

### 7. How should errors and exceptions be handled in PHP?

**Answer:** Use exceptions for exceptional failures and let the framework's
central error handler convert them into HTTP responses, logs, or reports.

Good practice:

- throw domain-specific exceptions where useful;
- do not expose internal exception messages to users;
- log enough context for debugging;
- distinguish validation errors from server errors;
- use `finally` for cleanup when needed.

Avoid catching broad exceptions only to hide them. That can make production
issues harder to diagnose.

### 8. What are common PHP security concerns?

**Answer:** Common concerns include:

- SQL injection;
- cross-site scripting (`XSS`);
- cross-site request forgery (`CSRF`);
- insecure session cookies;
- unsafe file uploads;
- weak password hashing;
- mass assignment vulnerabilities.

Use prepared statements, output escaping, CSRF tokens, secure cookie flags,
`password_hash`, authorization checks, and strict validation at application
boundaries.

### 9. What PHP 8 features are important for backend code?

**Answer:** Useful PHP 8 features include:

- constructor property promotion;
- union types;
- named arguments;
- attributes;
- match expressions;
- nullsafe operator;
- readonly properties;
- enums;
- improved type system features.

These features make domain models and service code more expressive, but they
should be used to improve clarity rather than to show syntax knowledge.

### 10. How do you improve performance in a PHP application?

**Answer:** Start with measurement. Use application logs, database query logs,
profilers, and APM tools.

Common improvements:

- enable and tune OPcache;
- reduce N+1 queries;
- add missing database indexes;
- cache expensive reads;
- avoid loading unnecessary relationships;
- process large data in chunks;
- move slow work to queues;
- optimize framework bootstrapping in production.

Most serious PHP performance problems come from database queries, excessive
I/O, or inefficient application-level loops.
