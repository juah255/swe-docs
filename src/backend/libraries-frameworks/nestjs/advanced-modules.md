# Advanced Modules & Architecture

Go beyond the basics: dynamic modules, global/shared modules, custom providers, DI scopes, circular dependencies, and how to structure a large application.

## Dynamic modules

A dynamic module returns a `DynamicModule` from a static factory, allowing configuration at import time.

```ts
import { DynamicModule, Module } from '@nestjs/common';

@Module({})
export class ConfigModule {
  static register(options: ConfigOptions): DynamicModule {
    return {
      module: ConfigModule,
      providers: [
        { provide: 'CONFIG_OPTIONS', useValue: options },
        ConfigService,
      ],
      exports: [ConfigService],
    };
  }
}
```

Usage:

```ts
@Module({
  imports: [ConfigModule.register({ envPath: '.env' })],
})
export class AppModule {}
```

Examples in the ecosystem: `TypeOrmModule.forRoot(...)`, `JwtModule.register(...)`, `BullModule.forRootAsync(...)`.

Use `register` for value options, `registerAsync` / `forRootAsync` when options depend on async providers.

## Global modules

A module decorated with `@Global()` only needs to be imported once; its exports become available everywhere.

```ts
@Global()
@Module({
  providers: [LoggerService],
  exports: [LoggerService],
})
export class CommonModule {}
```

Use global modules sparingly - for truly shared infrastructure (logging, config, database). Feature-specific providers should stay module-scoped so dependency direction stays clear.

## Shared modules

Modules that export providers are automatically shared across every module that imports them. Providers are singletons by default, so a service exported from `UsersModule` and imported by two other modules is the same instance.

```ts
@Module({
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],   // now importable by other modules
})
export class UsersModule {}
```

## Module imports/exports

- A module can only inject providers exported by modules it imports.
- Import the module once per feature that needs it; don't duplicate heavy setup.
- Keep the import graph acyclic whenever possible (see `forwardRef` below).

## Custom providers

Providers are not limited to classes. The DI container accepts several provider kinds.

### Class providers

The default: `{ provide: UsersService, useClass: UsersService }`. Useful for swapping implementations:

```ts
{
  provide: PaymentService,
  useClass: process.env.PAYMENT_PROVIDER === 'stripe'
    ? StripePaymentService
    : PaypalPaymentService,
}
```

### Value providers

`useValue` provides a constant:

```ts
{
  provide: 'CONFIG_OPTIONS',
  useValue: { region: 'eu-central-1' },
}
```

Inject by the token:

```ts
constructor(@Inject('CONFIG_OPTIONS') private options: ConfigOptions) {}
```

### Factory providers

`useFactory` builds the provider lazily, with access to other providers:

```ts
{
  provide: DatabaseConnection,
  useFactory: (config: ConfigService) => {
    return createConnection(config.get('DATABASE_URL'));
  },
  inject: [ConfigService],
}
```

Factory providers are the recommended way to build async infrastructure (connections, clients, queues).

## Dependency injection scopes

- **DEFAULT (singleton)** - one instance per module, shared across requests.
- **REQUEST** - a new instance per request; usable with `@Inject(REQUEST)` to read the request object.
- **TRANSIENT** - a new instance for every injection point.

```ts
@Injectable({ scope: Scope.REQUEST })
export class RequestScopedService {
  constructor(@Inject(REQUEST) private request: Request) {}
}
```

Scope caveats:

- A singleton cannot depend on a request-scoped provider (the singleton is created once, before any request exists).
- Request scope has a per-request overhead. Use it only when state must be isolated per request.
- `REQUEST` scope is not available in a singleton provider chain; use `AsyncLocalStorage` or explicit passing instead.

## Circular dependencies and forwardRef

Two modules/services that reference each other create a circular dependency that breaks DI at runtime.

```ts
import { forwardRef, Inject } from '@nestjs/common';

@Injectable()
export class UsersService {
  constructor(
    @Inject(forwardRef(() => AuthService))
    private authService: AuthService,
  ) {}
}
```

Module level:

```ts
@Module({
  imports: [forwardRef(() => AuthModule)],
})
export class UsersModule {}
```

`forwardRef` defers resolution until the dependency exists. Prefer restructuring to remove cycles; `forwardRef` is a workaround, not a design goal.

## Structuring a large application

A feature-based layout scales better than a layer-based one (controllers/ and services/ folders):

```
src/
├── auth/
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── guards/
│   ├── strategies/
│   └── dto/
├── users/
│   ├── users.module.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   └── dto/
├── products/
│   ├── products.module.ts
│   ├── products.controller.ts
│   ├── products.service.ts
│   └── dto/
├── orders/
│   ├── orders.module.ts
│   ├── orders.controller.ts
│   ├── orders.service.ts
│   └── dto/
├── common/
│   ├── decorators/
│   ├── guards/
│   ├── interceptors/
│   ├── pipes/
│   └── filters/
├── config/
│   └── configuration.ts
└── database/
    └── prisma.service.ts
```

Principles:

- Each feature owns its module, controller, service, and DTOs.
- `common/` holds cross-cutting infrastructure used by many features.
- `config/` and `database/` are global infrastructure modules.
- Modules expose only what other modules need via `exports`.
- Business logic lives in services; controllers remain thin.

## Mid/Senior Interview Questions and Answers

### 1. What is a dynamic module and when do you need one?

**Answer:** A dynamic module is a module created at import time through a static
method such as `register()` or `forRoot()`. It lets you pass options - databases,
clients, secret keys - so the same module can be configured differently by
different modules or apps.

Use it whenever a module needs configuration, like `TypeOrmModule.forRoot(...)`
or `JwtModule.register(...)`.

### 2. What are the different provider types and when do you use each?

**Answer:** Class providers (`useClass`) give the default or an alternative
implementation. Value providers (`useValue`) inject constants, options, or mocks
(great for tests). Factory providers (`useFactory`) build instances with
dependencies and async logic, the right choice for connections, clients, and
queue instances.

Choose by how the dependency is constructed: direct, constant, or computed.

### 3. What is the difference between singleton, request, and transient scope?

**Answer:** Singleton scope creates one shared instance per module and is the
default for performance. Request scope creates an instance per incoming request,
which isolates per-request state but costs overhead. Transient scope creates a
new instance for every injection point.

A singleton cannot depend on a request-scoped provider because it is created
once, before any request exists.

### 4. How do you resolve circular dependencies?

**Answer:** Circular dependencies occur when two modules or providers import
each other. Restructure the design first - extract shared logic into a third
module, or invert the dependency. If a cycle is unavoidable, use
`forwardRef()` in both the module import and the `@Inject()` to defer resolution.

`forwardRef` works but hides design smell; prefer a clean dependency graph.

### 5. How do you decide between a global module and a regular module?

**Answer:** Use `@Global()` only for infrastructure every feature needs, such as
logging, configuration, and the database connection - it is imported once and
available everywhere. Keep feature modules regular and explicit, so dependencies
are visible in each module's `imports` array.

Global modules reduce boilerplate but obscure the dependency graph. Too many
global modules make the architecture hard to reason about.