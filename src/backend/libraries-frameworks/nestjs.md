# NestJS

NestJS architecture notes, module conventions, and examples.

## Core Concepts

### What is NestJS?

NestJS is a progressive Node.js framework for building server-side applications.
It is built on top of Express (default) or Fastify and uses TypeScript by
default.

It borrows ideas from Angular such as modules, decorators, and dependency
injection, which makes application structure predictable across teams.

### Modules

A module groups related controllers and providers into a cohesive unit. Every
Nest application has at least one root module.

```ts
@Module({
  imports: [UsersModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

Modules can import other modules and export providers to make them available
elsewhere. Only exported providers can be injected outside the module that
declares them.

### Controllers and Providers

Controllers handle incoming requests and return responses to the client.
Providers are classes annotated with `@Injectable()` and are instantiated by the
Nest IoC container.

```ts
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }
}
```

Controllers should stay thin. Business logic belongs in services, which are the
most common kind of provider.

### Dependency Injection

Nest resolves dependencies by their type at construction time. Providers are
singletons by default within a module scope.

Scopes can be changed to `REQUEST` or `TRANSIENT` when a provider must be
instantiated per request or per injection, but singleton scope is preferred for
performance.

### Guards, Pipes, Interceptors, and Filters

These are the four request-lifecycle hooks that surround controller handlers.

- **Guards** decide whether a request proceeds, typically for authentication
  and authorization.
- **Pipes** transform and validate incoming data, often paired with
  `class-validator` and DTOs.
- **Interceptors** wrap handler execution for cross-cutting concerns such as
  logging, caching, response mapping, or timing.
- **Filters** catch exceptions thrown during request handling and convert them
  into HTTP responses.

### DTOs and Validation

Data Transfer Objects define the shape of request and response payloads. Combined
with `ValidationPipe` and `class-validator` decorators, they enforce input
constraints at the boundary.

```ts
export class CreateUserDto {
  @IsEmail()
  email: string;

  @MinLength(8)
  password: string;
}
```

This keeps controllers and services free of manual validation code.

## Mid/Senior Interview Questions and Answers

### 1. What problem does NestJS solve in Node.js backend projects?

**Answer:** NestJS provides a structured application architecture with modules,
controllers, providers, dependency injection, guards, pipes, interceptors, and
filters.

It is useful when a Node.js codebase needs clear boundaries and conventions
similar to enterprise backend frameworks.

### 2. What is the difference between a controller and a provider?

**Answer:** A controller handles incoming transport requests and returns
responses. A provider is an injectable class that implements reusable behavior,
such as services, repositories, clients, or configuration helpers.

Controllers should stay thin. Business logic belongs in services or domain
classes.

### 3. How do guards, pipes, interceptors, and filters differ?

**Answer:** Guards decide whether a request is allowed. Pipes transform or
validate input. Interceptors wrap execution for concerns such as logging,
mapping responses, or timing. Filters handle exceptions and convert them into
responses.

Order and responsibility matter because putting validation, authorization, and
error handling in the wrong layer makes behavior inconsistent.

### 4. How should modules be designed in NestJS?

**Answer:** Modules should group cohesive features and expose only the providers
that other modules need. Avoid a single global module that imports everything.

Feature modules, shared infrastructure modules, and explicit exports keep
dependency direction understandable.
