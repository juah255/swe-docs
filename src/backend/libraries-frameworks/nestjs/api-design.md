# API Design

Focus on building good APIs: REST design, pagination, filtering, searching, sorting, versioning, error responses, Swagger documentation, and serialization.

## REST API design

- Use nouns for resources: `POST /users`, `GET /users/:id`, not verbs like `getUser`.
- Use the HTTP methods for their meaning: `GET` read, `POST` create, `PUT` full replace, `PATCH` partial update, `DELETE` remove.
- Use plural resource names consistently.
- Nest paths into sub-resources: `GET /users/:id/orders`.
- Keep responses flat and predictable; wrap lists with metadata when paginating.
- Idempotency: `GET`, `PUT`, `DELETE` should be safe/repeatable; `POST` creates.

## Pagination

Offset (page) pagination:

```ts
export class PaginationQueryDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page = 1;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit = 20;
}
```

```ts
@Get()
async findAll(@Query() query: PaginationQueryDto) {
  const { page, limit } = query;
  const [data, total] = await this.productsService.findAll(page, limit);

  return {
    data,
    meta: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
}
```

Cursor pagination is more stable for live data:

```ts
@Get()
findAll(@Query('cursor') cursor?: string, @Query('limit') limit = 20) {
  return this.productsService.findAll({ cursor, limit });
}
```

Return `nextCursor` when there are more results.

## Filtering

Pass validated filter params through to the query:

```ts
export class FilterProductsDto extends PaginationQueryDto {
  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  minPrice?: number;
}
```

```ts
this.prisma.product.findMany({
  where: {
    category: dto.category,
    price: dto.minPrice ? { gte: dto.minPrice } : undefined,
  },
});
```

Never build `where` objects from unvalidated input.

## Searching

```ts
@Get('search')
search(@Query('q') q: string) {
  return this.prisma.product.findMany({
    where: {
      OR: [
        { name: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
      ],
    },
  });
}
```

For real search features (typos, relevance, full text), move to a dedicated search engine (Postgres full-text, Meilisearch, OpenSearch) instead of `contains` queries.

## Sorting

```ts
export class SortProductsDto extends FilterProductsDto {
  @IsOptional()
  @IsIn(['name', 'price', 'createdAt'])
  sortBy?: string = 'createdAt';

  @IsOptional()
  @IsIn(['asc', 'desc'])
  order?: 'asc' | 'desc' = 'desc';
}
```

```ts
this.prisma.product.findMany({
  orderBy: { [dto.sortBy]: dto.order },
});
```

Whitelist sortable fields so clients cannot inject arbitrary column names.

## Versioning

Nest supports versioning at the URI, header, or media-type level.

```ts
// main.ts
app.enableVersioning({
  type: VersioningType.URI,   // /v1/users
  defaultVersion: '1',
});
```

```ts
@Controller({ path: 'users', version: '1' })
export class UsersV1Controller {}
```

Use versioning when breaking changes to the public contract are likely. Deprecate old versions explicitly.

## Error response structure

Keep error responses consistent across the API with a global exception filter.

```ts
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const request = ctx.getRequest();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.getResponse()
        : 'Internal server error';

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message,
    });
  }
}
```

A good error body includes: `statusCode`, `message`, and for API debugging, `path` and `timestamp`. Never leak stack traces or database details.

## API documentation with Swagger/OpenAPI

Use `@nestjs/swagger` to auto-generate the OpenAPI spec from decorators.

```bash
npm i @nestjs/swagger
```

```ts
// main.ts
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

const config = new DocumentBuilder()
  .setTitle('API')
  .setDescription('The API description')
  .setVersion('1.0')
  .addBearerAuth()
  .build();

const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('docs', app, document);
```

Document DTOs:

```ts
import { ApiProperty } from '@nestjs/swagger';

export class CreateUserDto {
  @ApiProperty({ example: 'a@b.com' })
  email: string;

  @ApiProperty({ example: 'strong-pass', writeOnly: true })
  password: string;
}
```

Decorate endpoints:

```ts
@ApiTags('users')
@ApiBearerAuth()
@Get(':id')
@ApiOkResponse({ type: UserDto })
findOne(@Param('id') id: string) {}
```

## Serialization

Control what the API returns so sensitive fields never leak. Use interceptors or a dedicated response DTO.

`ClassSerializerInterceptor` + `@Exclude`:

```ts
import { Exclude } from 'class-transformer';

export class UserEntity {
  id: number;
  email: string;

  @Exclude()
  password: string;
}
```

```ts
@UseInterceptors(ClassSerializerInterceptor)
@Get('me')
me(@CurrentUser() user: UserEntity) {
  return user; // password is stripped
}
```

Conditional exclusion with `@Expose`/`@Exclude` groups:

```ts
@Exclude()
export class UserDto {
  @Expose() id: number;
  @Expose() email: string;

  @Expose({ groups: ['admin'] })
  isAdmin: boolean;
}
```

`ClassSerializerInterceptor` respects `@Exclude`/`@Expose` metadata and leaves plain objects untouched. Prefer explicit response DTOs when the shape differs a lot from the entity.

## Response DTOs

Define the public contract separately from the entity:

```ts
export class UserResponseDto {
  id: number;
  email: string;
  name: string;
  createdAt: Date;
}

// service returns the DTO, never the raw password-bearing entity
async findOne(id: number): Promise<UserResponseDto> {
  const user = await this.prisma.user.findUnique({ where: { id } });
  return { id: user.id, email: user.email, name: user.name, createdAt: user.createdAt };
}
```

This makes the API contract explicit and stable even when the database schema changes.

## Mid/Senior Interview Questions and Answers

### 1. How do you design a RESTful resource for a nested relationship?

**Answer:** Use nested paths for clearly owned resources (`GET /users/:id/orders`),
but keep the URL shallow when a resource is queried independently. Provide
filters on the flat endpoint (`GET /orders?userId=5`) rather than duplicating
nested routes. Choose one primary identifier and never expose database internal
IDs if a public UUID is needed.

### 2. Offset vs cursor pagination - which should you use?

**Answer:** Offset pagination (`page`/`limit`) is simple, supports random access,
and is fine for small, stable datasets. Cursor pagination is stable when rows
change between requests and scales better on large tables, but cannot jump to
arbitrary pages.

Use cursor pagination for feeds and live data; use offset for admin lists and
small collections.

### 3. Why should you whitelist sortable/filterable fields?

**Answer:** Passing client input directly into `orderBy` or `where` allows
injection of arbitrary column names, which can leak data or break queries.
Whitelisting with `@IsIn([...])` or an explicit mapping keeps the API contract
safe and prevents enumeration attacks.

### 4. How do you handle API versioning?

**Answer:** Pick a strategy - URI (`/v1/users`), header, or media type - and
apply it consistently. URI versioning is the most common and visible. Enable
versioning once in `main.ts`, set a default version, and version only when
breaking changes occur. Keep backward compatibility during a deprecation period.

### 5. How do you keep sensitive fields out of responses?

**Answer:** Use response DTOs that contain only public fields, and/or
`ClassSerializerInterceptor` with `@Exclude` on sensitive properties. Combine
this with Prisma `select` so sensitive columns are never even fetched. Never
return entities directly from public endpoints.