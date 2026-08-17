# NestJS Fundamentals

Learn the core architecture first: what NestJS is, how the CLI scaffolds projects, and the modules/controllers/providers/DI model that everything else builds on.

## What is NestJS and why use it?

NestJS is a progressive Node.js framework for building server-side applications. It is built on top of Express (default) or Fastify and uses TypeScript by default.

It borrows ideas from Angular such as modules, decorators, and dependency injection, which makes application structure predictable across teams.

Why teams choose it:

- **Structured architecture** - modules, controllers, providers give a consistent layout
- **TypeScript first** - compile-time safety across the whole application
- **Dependency injection** - testable, decoupled providers managed by an IoC container
- **Framework agnostic HTTP** - switch between Express and Fastify without changing business code
- **Rich request lifecycle** - guards, pipes, interceptors, and filters cover cross-cutting concerns
- **First-class ecosystem** - official support for TypeORM, Prisma, GraphQL, WebSockets, BullMQ, and microservices

## Nest CLI

The Nest CLI scaffolds projects, generates files, and runs the build.

```bash
# Install the CLI globally
npm i -g @nestjs/cli

# Create a new project
nest new my-app

# Create a new project without git initialization
nest new my-app --skip-git

# Use yarn instead of npm
nest new my-app --package-manager yarn
```

Generate building blocks:

```bash
nest g module users        # module
nest g controller users    # controller
nest g service users       # provider/service
nest g guard auth          # guard
nest g pipe validation     # pipe
nest g interceptor logging # interceptor
nest g filter http-exception # exception filter
nest g class dto/create-user --no-spec
```

Common CLI commands:

```bash
npm run start          # start in watch mode
npm run start:prod     # build + run production
npm run build          # compile to dist/
npm run lint           # eslint
npm run test           # unit tests
npm run test:e2e       # e2e tests
```

## Project structure

A freshly scaffolded project looks like this:

```
src/
├── main.ts             # bootstrap, creates the app and listens
├── app.module.ts       # root module
├── app.controller.ts   # root controller
├── app.service.ts      # root service
├── app.controller.spec.ts
test/
├── app.e2e-spec.ts
├── jest-e2e.json
```

`main.ts` bootstraps the application:

```ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
}
bootstrap();
```

As the app grows, feature directories group related files:

```
src/
├── auth/
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   └── dto/
├── users/
├── products/
├── orders/
├── common/            # shared guards, pipes, filters, decorators
├── config/
└── database/
```

## Modules

A module groups related controllers and providers into a cohesive unit. Every Nest application has at least one root module.

```ts
import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

@Module({
  imports: [SomeModule],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

- `imports` - modules whose exported providers are needed here
- `controllers` - controllers instantiated for this module
- `providers` - providers registered in the module's DI scope
- `exports` - providers made available to modules that import this one

Modules can import other modules and export providers to make them available elsewhere. Only exported providers can be injected outside the module that declares them.

## Controllers

Controllers handle incoming requests and return responses to the client. Controllers should stay thin; business logic belongs in services.

```ts
import { Controller, Get, Param } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }
}
```

## Providers

A provider is a component managed by the dependency injection container that can be injected into other parts of the application to provide functionality, data, or dependencies.

Providers are classes annotated with `@Injectable()` and are instantiated by the Nest IoC container.

```ts
import { Injectable } from '@nestjs/common';

@Injectable()
export class UsersService {
  findOne(id: string) {
    // business logic goes here
  }
}
```

Services are the most common kind of provider, but providers also include repositories, HTTP clients, factories, and helpers.

## Dependency Injection

Nest resolves dependencies by their type at construction time. The constructor declares what it needs, and the IoC container supplies it.

```ts
@Controller('users')
export class UsersController {
  // UsersService is injected automatically
  constructor(private readonly usersService: UsersService) {}
}
```

Providers are singletons by default within a module scope. Scopes can be changed to `REQUEST` or `TRANSIENT` when a provider must be instantiated per request or per injection, but singleton scope is preferred for performance.

## Decorators

Nest relies heavily on decorators to declare metadata:

- Class-level: `@Module()`, `@Controller()`, `@Injectable()`
- Route-level: `@Get()`, `@Post()`, `@Put()`, `@Patch()`, `@Delete()`
- Parameter-level: `@Param()`, `@Query()`, `@Body()`, `@Headers()`
- Lifecycle: `@OnModuleInit()`, `@OnModuleDestroy()`
- Cross-cutting: `@UseGuards()`, `@UsePipes()`, `@UseInterceptors()`, `@UseFilters()`

## Request lifecycle

Every request passes through the same stages. Understanding the order matters:

```
Incoming request
     ↓
Middleware
     ↓
Guards
     ↓
Interceptors (before handler)
     ↓
Pipes
     ↓
Controller handler
     ↓
Service
     ↓
Interceptors (after handler)
     ↓
Exception filters (on error)
     ↓
Response
```

## Configuration with .env

Use `@nestjs/config` to load environment variables.

```bash
npm i @nestjs/config
```

```ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,   // available everywhere without importing again
      envFilePath: '.env',
    }),
  ],
})
export class AppModule {}
```

Inject configuration into a service:

```ts
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class DatabaseService {
  constructor(private config: ConfigService) {
    const host = this.config.get<string>('DB_HOST');
    const port = this.config.get<number>('DB_PORT');
  }
}
```

`isGlobal: true` makes `ConfigModule` a global module so any provider can inject `ConfigService`.

## Goal: build a simple CRUD API

A minimal CRUD API needs a module, a controller, a service, and a DTO:

```ts
// user.service.ts
@Injectable()
export class UsersService {
  private users: { id: number; name: string }[] = [];

  findAll() {
    return this.users;
  }
  findOne(id: number) {
    return this.users.find((u) => u.id === id);
  }
  create(name: string) {
    const user = { id: this.users.length + 1, name };
    this.users.push(user);
    return user;
  }
}
```

```ts
// user.controller.ts
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.findOne(id);
  }

  @Post()
  create(@Body('name') name: string) {
    return this.usersService.create(name);
  }
}
```

## Mid/Senior Interview Questions and Answers

### 1. How does NestJS dependency injection work under the hood?

**Answer:** Nest keeps a registry of providers per module. When a provider is
registered, the container reads its constructor parameter types via the
`design:paramtypes` metadata emitted by TypeScript, resolves each dependency from
the registry, and instantiates the provider.

Circular dependencies and provider scopes are handled explicitly because
reflection alone cannot express them.

### 2. Why are providers singletons by default, and when would you change scope?

**Answer:** Singleton scope means one instance shared across the module, which
saves memory and startup cost and lets providers hold caches or connection pools.
Use `REQUEST` scope when a provider must be isolated per request (request
context, per-user state). Use `TRANSIENT` for short-lived objects. Request and
transient scope are slower because they allocate more objects.

### 3. What is the difference between a controller and a service?

**Answer:** A controller is a thin adapter between the HTTP layer and the
application. It maps routes and parameters to service calls and returns
responses. A service is an injectable class that owns business logic, data
access, and orchestration.

Keeping controllers thin makes business logic testable without HTTP.

### 4. How does NestJS compare to Express?

**Answer:** Express is a minimal, unopinionated HTTP layer. NestJS is a
framework built on top of Express (or Fastify) that adds modules, DI, guards,
pipes, interceptors, filters, and conventions. Express gives freedom; Nest gives
structure, consistency, and testability at the cost of learning the framework.