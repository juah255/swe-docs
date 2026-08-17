# Controllers & HTTP

Understand how NestJS handles HTTP requests: routing, HTTP methods, parameters, bodies, headers, status codes, and response handling.

## Routes

A controller maps a class to a base path and methods to route handlers.

```ts
import { Controller } from '@nestjs/common';

@Controller('users')   // base path: /users
export class UsersController {
  @Get()
  findAll() {
    return [];
  }
}
```

Route paths are case-insensitive and can be parameterized:

```ts
@Controller('users/:id/posts')
export class PostsController {}
```

## HTTP methods

Use the decorator that matches the HTTP verb:

```ts
@Controller('users')
export class UsersController {
  @Get()        // GET /users
  findAll() {}

  @Get(':id')   // GET /users/:id
  findOne() {}

  @Post()       // POST /users
  create() {}

  @Put(':id')   // PUT /users/:id - full replace
  update() {}

  @Patch(':id') // PATCH /users/:id - partial update
  partialUpdate() {}

  @Delete(':id') // DELETE /users/:id
  remove() {}

  @Options()    // OPTIONS /users
  options() {}
}
```

`@All()` matches every HTTP method on a path.

## Route parameters

```ts
@Get(':id')
findOne(@Param('id') id: string) {
  return `user ${id}`;
}

// Access all params at once
@Get(':id/posts/:postId')
find(@Param() params: { id: string; postId: string }) {
  return params;
}
```

Route params are always strings. Use a pipe to transform them.

## Query parameters

```ts
@Get()
findAll(
  @Query('page') page: string,
  @Query('limit') limit: string,
) {
  return { page, limit };
}

// Access the full query object
@Get()
find(@Query() query: Record<string, string>) {
  return query;
}
```

## Request body

```ts
@Post()
create(@Body() body: CreateUserDto) {
  return this.usersService.create(body);
}

// Extract a single property
@Post()
create(@Body('name') name: string) {
  return this.usersService.create(name);
}
```

Always type the body with a DTO (see [DTO & Validation](dto-and-validation.md)) instead of using raw `any`.

## Headers

```ts
@Get()
readHeaders(@Headers() headers: Record<string, string>) {
  return headers;
}

// Read a single header
@Get()
readToken(@Headers('authorization') auth: string) {
  return auth;
}
```

## Status codes

Nest defaults to `200 OK` for `GET`/`PUT`/`PATCH`/`DELETE` and `201 Created` for `POST`. Override with `@HttpCode()` or `@Res()`.

```ts
import { HttpCode, HttpStatus } from '@nestjs/common';

@Post()
@HttpCode(HttpStatus.CREATED) // 201
create() {}

@Delete(':id')
@HttpCode(HttpStatus.NO_CONTENT) // 204, no body
remove() {}
```

## Response handling

By default Nest serializes whatever the handler returns (objects or arrays to JSON, strings to text). This keeps handlers framework-agnostic.

When you need full control of the raw Express/Fastify response, inject `@Res()`:

```ts
import { Res } from '@nestjs/common';
import { Response } from 'express';

@Get('download')
download(@Res() res: Response) {
  res.sendFile('file.pdf');
}
```

!!! warning
    Using `@Res()` puts the handler in "library-specific mode". Nest no longer
    applies its own response mapping or interceptors that rely on the returned
    value. Prefer returning values and only use `@Res()` for edge cases like
    streaming or file downloads. For streaming, pass `{ passthrough: true }`
    to keep both behaviors.

## Redirect

```ts
@Get()
@Redirect('https://example.com', 301)
redirect() {}
```

## Custom decorators

Create parameter decorators with `createParamDecorator`:

```ts
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const User = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return data ? request.user?.[data] : request.user;
  },
);
```

Usage:

```ts
@Get('me')
me(@User() user: UserEntity) {
  return user;
}

@Get('me/email')
email(@User('email') email: string) {
  return email;
}
```

Combine decorators with pipes to validate and transform the extracted value.

## Request/response objects

Access the raw request with `@Req()` and response with `@Res()`:

```ts
import { Req } from '@nestjs/common';
import { Request } from 'express';

@Get()
read(@Req() req: Request) {
  return req.method; // 'GET'
}
```

The request object exposes `body`, `params`, `query`, `headers`, `cookies`, `ip`, `url`, `method`, and more.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between `@Body`, `@Param`, and `@Query`?

**Answer:** `@Body` extracts the parsed request payload (JSON body),
`@Param` extracts values from the URL path (`/users/:id`), and `@Query`
extracts values from the query string (`?page=2`).

Using the correct one keeps handlers explicit and makes validation of each
source straightforward.

### 2. When should you use `@Res()` instead of returning a value?

**Answer:** Returning a value lets Nest handle status codes, serialization, and
interceptors, and keeps the handler transport-agnostic. Use `@Res()` only for
library-specific needs such as streaming files, sending raw responses, or
setting fine-grained cookies, and prefer `{ passthrough: true }` when you still
want Nest to manage the response afterward.

### 3. Why are route params always strings?

**Answer:** The URL is text, so every path segment arrives as a string. Numbers
and booleans must be parsed explicitly with pipes such as `ParseIntPipe` or a
custom transformation pipe. This prevents implicit conversions that silently
produce wrong values.

### 4. What is the purpose of `@HttpCode`?

**Answer:** `@HttpCode` overrides the default status code for a route. The
default is `201` for `POST` and `200` for the rest. You use it to return
semantically correct codes such as `204` for deletions or `202` for accepted
async work.