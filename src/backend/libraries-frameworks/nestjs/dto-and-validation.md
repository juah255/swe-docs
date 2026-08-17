# DTO & Validation

This is very important for production APIs. DTOs define the shape of request data, and the `ValidationPipe` enforces constraints at the boundary before any business logic runs.

## DTOs

A DTO (Data Transfer Object) is an object used to transfer data between different layers or systems without exposing the internal business or database model, and it can also define validation rules to ensure incoming data is valid before processing.

```ts
export class CreateUserDto {
  email: string;
  name: string;
  password: string;
}
```

Use it to type the request body:

```ts
@Post()
create(@Body() dto: CreateUserDto) {
  return this.usersService.create(dto);
}
```

DTOs are transport shapes. They can differ from your entity/model because the API surface and the database schema rarely match exactly (no password in responses, different field names, etc.).

## class-validator

`class-validator` provides decorator-based validation rules on class properties.

```bash
npm i class-validator class-transformer
```

```ts
import { IsEmail, IsString, MinLength } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(2)
  name: string;

  @IsString()
  @MinLength(8)
  password: string;
}
```

Common decorators:

- `@IsString()`, `@IsNumber()`, `@IsBoolean()`, `@IsArray()`, `@IsDate()`
- `@IsEmail()`, `@IsUrl()`, `@IsUUID()`, `@IsEnum()`
- `@IsInt()`, `@IsPositive()`, `@Min()` / `@Max()`, `@MinLength()` / `@MaxLength()`
- `@IsOptional()`, `@IsNotEmpty()`
- `@Matches(/regex/)`

Nested validation works with `@ValidateNested()` and `@Type()` from `class-transformer`:

```ts
export class CreateOrderDto {
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items: OrderItemDto[];
}
```

## class-transformer

`class-transformer` converts plain JSON objects into class instances so the class metadata (from decorators) exists at runtime. The `ValidationPipe` uses it internally to instantiate the DTO class before validation.

It also powers transformation such as `@Type(() => Number)` for coercing types:

```ts
import { Type } from 'class-transformer';

export class GetUsersQueryDto {
  @Type(() => Number)
  @IsInt()
  page: number;

  @Type(() => Number)
  @IsInt()
  limit: number;
}
```

## ValidationPipe

The `ValidationPipe` validates the incoming payload against the DTO's `class-validator` rules and rejects invalid input with `400 Bad Request`.

```ts
import { ValidationPipe } from '@nestjs/common';

app.useGlobalPipes(new ValidationPipe());
```

When the DTO is used as the parameter type, the pipe takes over:

```ts
@Post()
create(@Body() dto: CreateUserDto) {
  // dto is validated before this runs
}
```

## Global validation

Register the pipe globally so every route is validated automatically:

```ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
    }),
  );

  await app.listen(3000);
}
bootstrap();
```

Prefer a global pipe plus per-route DTOs over scattering validation logic in handlers.

## Transforming input

`transform: true` converts the payload into a DTO class instance and coerces simple types (`string` → `number`) declared on the DTO.

```ts
new ValidationPipe({
  transform: true,
  transformOptions: { enableImplicitConversion: true },
});
```

With `enableImplicitConversion`, `page: number` in a query DTO is coerced from the string `"2"` to the number `2` automatically.

## Whitelisting

`whitelist: true` strips any property that has no validation decorator, protecting the API from mass-assignment attacks.

```ts
new ValidationPipe({
  whitelist: true,
  // forbidNonWhitelisted: true  // reject instead of silently strip
});
```

With `forbidNonWhitelisted: true`, unknown properties cause a `400` instead of being removed. This is useful to catch clients sending wrong field names.

## Custom validation

Create custom constraints by implementing `ValidatorConstraintInterface`:

```ts
import {
  ValidatorConstraint,
  ValidatorConstraintInterface,
  ValidationArguments,
} from 'class-validator';

@ValidatorConstraint({ name: 'isBeforeNow', async: false })
export class IsBeforeNowConstraint implements ValidatorConstraintInterface {
  validate(date: Date, args: ValidationArguments) {
    return date.getTime() < Date.now();
  }
  defaultMessage(args: ValidationArguments) {
    return 'Date must be in the past';
  }
}
```

Use it on a DTO property:

```ts
import { Validate } from 'class-validator';
import { IsBeforeNowConstraint } from './is-before-now.constraint';

export class EventDto {
  @Validate(IsBeforeNowConstraint)
  startedAt: Date;
}
```

Async validators (e.g. check uniqueness in the database) set `async: true`. Keep them off hot paths or add caching.

## The validation flow

```
POST /users
   Request
      ↓
   ValidationPipe (whitelist → transform → validate)
      ↓
   CreateUserDto (validated instance)
      ↓
   Controller
      ↓
   Service
```

## Mid/Senior Interview Questions and Answers

### 1. Why do you need a DTO if you can validate in the service?

**Answer:** A DTO is the contract of the API boundary. It documents the expected
shape, enables automatic validation via `ValidationPipe`, prevents mass
assignment by whitelisting, and keeps the controller/service decoupled from the
raw HTTP body.

Validating in services duplicates logic across every entry point (REST,
microservices, jobs) and is easy to forget.

### 2. What is the difference between `whitelist` and `forbidNonWhitelisted`?

**Answer:** `whitelist: true` strips properties without validation decorators
before processing. `forbidNonWhitelisted: true` goes further and rejects the
request with a `400` when unknown properties are present. Whitelisting alone
silently drops data; forbidding surfaces client mistakes.

### 3. What does `transform: true` do?

**Answer:** It converts the plain JSON payload into an instance of the DTO class
so `class-validator` decorators and class methods exist at runtime, and it
coerces primitive types declared on the DTO (for example a query string `"5"`
into a `number`). Without it, validation still works but the object stays plain
and untyped.

### 4. How do you prevent mass assignment with a DTO?

**Answer:** Keep the DTO minimal - declare only the fields the API should accept,
add `whitelist: true`, and never spread a full entity into a create/update DTO.
This stops clients from injecting `role`, `isAdmin`, or other fields that should
be set by the server only.

### 5. When would you write a custom validator?

**Answer:** When the built-in rules cannot express a constraint, such as
"end date after start date", "value must be unique", or domain invariants
checked against external state. Use async custom validators for database lookups
and always consider whether the check belongs at the application or database
layer.