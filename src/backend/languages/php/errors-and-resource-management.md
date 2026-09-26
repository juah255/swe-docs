# Errors and Resource Management

## The Throwable Hierarchy

Both `Exception` and engine `Error` implement `Throwable`. Type errors, argument
errors, and many engine failures are throwable in modern PHP.

```php
try {
    $invoice = $service->create($command);
} catch (InvalidInvoice $exception) {
    return validationResponse($exception);
} catch (Throwable $exception) {
    $logger->error('invoice_creation_failed', [
        'exception' => $exception,
        'request_id' => $requestId,
    ]);

    return internalErrorResponse($requestId);
}
```

Catch a failure where code can recover, translate it to another boundary, or add
meaningful context. A top-level handler should convert uncaught failures into a
safe response or process exit and record diagnostics once.

## Exception Design

Use exceptions for operations that cannot fulfill their contract. A domain
exception can communicate an expected rejection; an infrastructure exception
can preserve a database or remote failure without leaking vendor details upward.

Do not create a unique exception class for every message. Create types when
callers need a distinct recovery or translation path. Preserve the original
exception as `previous` when wrapping.

Avoid catching `Throwable` deep in the application only to continue with
partial or invalid state.

## Errors, Warnings, and Reporting

Configure production reporting so all relevant errors are recorded while their
details are not displayed to clients:

```ini
error_reporting = E_ALL
display_errors = Off
log_errors = On
```

An error handler can translate selected warnings or notices into exceptions, but
not every engine condition can be handled that way. The `@` suppression operator
hides useful signals and should not be a normal control-flow mechanism.

Register top-level exception and shutdown handlers early. Shutdown handlers can
inspect a final fatal error, but the process may be in a compromised state; keep
their work small and reliable.

## Cleanup with `finally`

Use `finally` when cleanup must occur whether work succeeds or throws:

```php
$lock = $locks->acquire($key);

try {
    return $service->rebuild($id);
} finally {
    $lock->release();
}
```

Database transactions should roll back on failure:

```php
$pdo->beginTransaction();

try {
    $work();
    $pdo->commit();
} catch (Throwable $exception) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    throw $exception;
}
```

Object destructors are not a reliable substitute for explicit cleanup. Their
timing can depend on references and shutdown, and throwing from a destructor is
dangerous.

## Error Boundaries

Different entry points need different final behavior:

- an HTTP application returns a generic 500 response and correlation ID;
- a CLI command writes an error to standard error and exits non-zero;
- a queue consumer decides whether to retry, reject, or dead-letter;
- a scheduled job records failure and preserves its checkpoint.

Log context that helps diagnosis—operation, stable identifiers, attempt, and
exception—without credentials, authorization headers, cookies, or personal
payloads.

## Assertions

Assertions are useful for developer invariants and can be disabled depending on
configuration. Do not use `assert()` to validate user input, enforce
authorization, or protect persistent data. Those rules must execute in every
production configuration.

