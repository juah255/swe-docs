# NestJS Request Lifecycle

Once you know the basics, study the architecture deeply. Understanding the order in which middleware, guards, interceptors, pipes, and filters run is one of the most important NestJS concepts.

## The full pipeline

```
Incoming request
     ↓
Middleware
     ↓
Guards
     ↓
Interceptors (pre-handler logic)
     ↓
Pipes
     ↓
Controller handler
     ↓
Service
     ↓
Repository / Database
     ↓
Interceptors (post-handler logic)
     ↓
Exception filters (only when an error is thrown)
     ↓
Response
```

## Middleware

Middleware runs before the route handler, at the transport layer, with access to the raw request and response. It has no knowledge of the handler.

```ts
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    console.log(`${req.method} ${req.url} ${Date.now()}`);
    next();
  }
}
```

Apply it in a module:

```ts
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(LoggerMiddleware).forRoutes('*');
  }
}
```

Middleware is the right place for concerns that must run before everything else: request logging, CORS headers, raw body inspection.

## Guards

Guards decide whether a request proceeds. They run after middleware and before interceptors/pipes. They are the right place for authentication and authorization.

```ts
@Injectable()
export class AuthGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    // verify token, attach request.user, return true/false
    return true;
  }
}
```

See [Authentication & Authorization](authentication-and-authorization.md) for full examples.

## Interceptors

Interceptors wrap handler execution. They can run logic before and after the handler, transform the result, or bypass the handler entirely.

```ts
import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map, tap } from 'rxjs/operators';

@Injectable()
export class TimingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const started = Date.now();
    return next.handle().pipe(
      tap(() => console.log(`took ${Date.now() - started}ms`)),
    );
  }
}
```

Transforming responses:

```ts
@Injectable()
export class TransformInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      map((data) => ({ status: 'ok', data })),
    );
  }
}
```

If an interceptor never calls `next.handle()`, the handler does not run.

## Pipes

Pipes validate and transform incoming data before it reaches the handler.

```ts
import { ArgumentMetadata, Injectable, PipeTransform } from '@nestjs/common';

@Injectable()
export class ParseIntPipe implements PipeTransform<string, number> {
  transform(value: string, metadata: ArgumentMetadata): number {
    const parsed = parseInt(value, 10);
    if (Number.isNaN(parsed)) {
      throw new BadRequestException('expected a number');
    }
    return parsed;
  }
}
```

Nest ships built-in pipes: `ValidationPipe`, `ParseIntPipe`, `ParseUUIDPipe`, `ParseEnumPipe`, `DefaultValuePipe`.

## Exception filters

Exception filters catch errors and convert them into HTTP responses. They are the last stop before the response is sent.

```ts
import { Catch, ArgumentsHost } from '@nestjs/common';
import { BaseExceptionFilter } from '@nestjs/core';

@Catch()
export class AllExceptionsFilter extends BaseExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    // log or enrich, then delegate to the base filter
    super.catch(exception, host);
  }
}
```

A custom structured error response:

```ts
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const status = exception.getStatus();

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: ctx.getRequest().url,
      message: exception.message,
    });
  }
}
```

## ExecutionContext

`ExecutionContext` is the abstraction that lets guards, interceptors, and filters work across HTTP, WebSocket, and microservices.

```ts
canActivate(context: ExecutionContext) {
  // HTTP
  const http = context.switchToHttp();
  const req = http.getRequest();

  // WebSocket
  const ws = context.switchToWs();
  const client = ws.getClient();

  // Microservices / RPC
  const rpc = context.switchToRpc();
  const data = rpc.getData();
}
```

It also exposes `getHandler()` (the route handler method) and `getClass()` (the controller class), which the `Reflector` uses to read metadata.

## Reflector

The `Reflector` reads metadata written by custom decorators, enabling route-level configuration in guards.

```ts
@Injectable()
export class PublicGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    return this.reflector.getAllAndOverride<boolean>('isPublic', [
      context.getHandler(),
      context.getClass(),
    ]) ?? false;
  }
}
```

This is the pattern behind `@Roles()`, `@Public()`, `@Throttle()`, and similar decorators.

## Custom decorators

Compose route metadata with `SetMetadata`:

```ts
import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
```

Or make parameter decorators with `createParamDecorator` (see [@CurrentUser()](authentication-and-authorization.md#currentuser-type-decorators)).

## Execution order in detail

1. **Inbound middleware** - outermost first.
2. **Guards** - every guard registered at global, controller, and route level.
3. **Interceptors** - `pre` phase, in registration order; each wraps the next.
4. **Pipes** - validate/transform params and body.
5. **Handler** - the controller method runs.
6. **Interceptors** - `post` phase, in reverse order, transforming the stream of responses.
7. **Exception filters** - only if something throws, outermost last.

The same guard/interceptor/pipe can be bound globally (`app.useGlobalGuards`), at the controller (`@UseGuards` on the class), or per-route.

## Mid/Senior Interview Questions and Answers

### 1. In what order do middleware, guards, interceptors, pipes, and filters run?

**Answer:** Middleware first, then guards, then interceptors (before the
handler), then pipes, then the handler. After the handler, interceptors run their
post-handler phase. Exception filters only run when an error is thrown.

Within interceptors, pre-handler logic runs in registration order and post-handler
logic runs in reverse order because each interceptor wraps the next.

### 2. When should you use middleware instead of a guard or interceptor?

**Answer:** Use middleware for concerns that must run at the transport layer
before routing decisions: logging, CORS, header normalization, request
correlation IDs. Use guards for access decisions that depend on the route
metadata (auth/RBAC) and interceptors for wrapping handler output.

Middleware runs before guards and cannot easily access route metadata, so do not
put authorization there.

### 3. How do interceptors transform the response?

**Answer:** Interceptors receive the handler's `Observable` via `next.handle()`
and can pipe it with `map` to transform values, `tap` for side effects, `catchError`
for error handling, or `delay`/`timeout` for timing. Returning a different
observable or never calling `next.handle()` changes what the client receives.

### 4. What is `ExecutionContext` and why is it useful?

**Answer:** `ExecutionContext` is the transport-agnostic view of the current
request. It exposes `switchToHttp()`, `switchToWs()`, and `switchToRpc()` so the
same guard/interceptor/filter can work for HTTP, WebSocket, and microservice
contexts. It also provides `getHandler()` and `getClass()` for reading route
metadata with the `Reflector`.

### 5. Why is the order of lifecycle hooks important?

**Answer:** Each hook has a different responsibility and different access.
Running authorization before validation, or validation before parsing, changes
behavior and can leak information or allow invalid input to reach guards.
Consistent ordering - middleware → guards → interceptors → pipes → handler →
filters - keeps behavior predictable across the application.