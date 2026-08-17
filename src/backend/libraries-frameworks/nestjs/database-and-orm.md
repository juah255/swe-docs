# Database & ORM

Learn how NestJS connects to databases. This guide uses PostgreSQL with Prisma, which is the recommended choice for new projects, and notes TypeORM alternatives.

## Prisma vs TypeORM

- **Prisma** - modern schema-first ORM with type-safe queries, automatic migrations, and a predictable query API. Recommended when starting fresh.
- **TypeORM** - decorator-based ORM with entities and repositories, deeply integrated with Nest via `@nestjs/typeorm`. Still common in existing codebases.

Both connect to PostgreSQL and follow similar repository/service patterns.

## Setup with Prisma

```bash
npm i @prisma/client prisma
npx prisma init
```

This creates a `prisma/` directory with `schema.prisma` and a `.env` with the database URL.

```env
DATABASE_URL="postgresql://user:password@localhost:5432/mydb?schema=public"
```

`schema.prisma`:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}
```

## Database configuration

Load `PrismaService` as a provider so it can be injected and share a single connection pool.

```bash
npx prisma generate
```

```ts
import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  async onModuleInit() {
    await this.$connect();
  }
  async onModuleDestroy() {
    await this.$disconnect();
  }
}
```

Register it in a module and export it:

```ts
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class DatabaseModule {}
```

Make it global if most features need the database:

```ts
@Global()
@Module({ providers: [PrismaService], exports: [PrismaService] })
export class DatabaseModule {}
```

## Models (entities)

With Prisma, the model is declared in the schema and the type-safe client is generated.

```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  password  String
  posts     Post[]
  createdAt DateTime @default(now())
}

model Post {
  id        Int     @id @default(autoincrement())
  title     String
  content   String?
  author    User    @relation(fields: [authorId], references: [id])
  authorId  Int
}
```

`npx prisma generate` regenerates the client after every schema change.

## Migrations

```bash
npx prisma migrate dev --name init   # create + apply a migration in dev
npx prisma migrate deploy            # apply migrations in production
npx prisma migrate reset             # drop, reapply, reseed (dev only)
```

Migrations are SQL files in `prisma/migrations/`. They are version-controlled and applied in order.

## CRUD

Inject `PrismaService` into a service and use the generated client:

```ts
@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  findAll() {
    return this.prisma.user.findMany();
  }

  findOne(id: number) {
    return this.prisma.user.findUnique({ where: { id } });
  }

  create(data: CreateUserDto) {
    return this.prisma.user.create({ data });
  }

  update(id: number, data: UpdateUserDto) {
    return this.prisma.user.update({ where: { id }, data });
  }

  remove(id: number) {
    return this.prisma.user.delete({ where: { id } });
  }
}
```

Prisma queries are fully typed. Mistyped fields or relations fail at compile time.

## Relationships

Query relations with `include` (join in the same query) or `select` (pick fields):

```ts
// Eager load posts with every user
this.prisma.user.findMany({ include: { posts: true } });

// Only fetch specific fields
this.prisma.user.findMany({ select: { id: true, email: true } });
```

Create related records with nested writes:

```ts
this.prisma.user.create({
  data: {
    email: 'a@b.com',
    name: 'A',
    posts: { create: [{ title: 'Hello' }] },
  },
});
```

## Transactions

Prisma transactions come in two forms:

```ts
// Interactive transaction - run arbitrary operations atomically
await this.prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { email, name } });
  await tx.profile.create({ data: { userId: user.id } });
});

// Batch transaction - array of operations
await this.prisma.$transaction([
  this.prisma.order.update({ where: { id: 1 }, data: { status: 'paid' } }),
  this.prisma.account.update({ where: { id: 1 }, data: { balance: { decrement: 100 } } }),
]);
```

Use transactions whenever an operation must either fully succeed or fully fail (orders, transfers, multi-row writes). For the batch form, every operation in the array runs in the same transaction. For critical sections, prefer database-level constraints over application-side checks alone.

## Pagination

```ts
const page = 1;
const pageSize = 20;

const [total, items] = await this.prisma.$transaction([
  this.prisma.post.count(),
  this.prisma.post.findMany({
    skip: (page - 1) * pageSize,
    take: pageSize,
    orderBy: { createdAt: 'desc' },
  }),
]);

return { data: items, meta: { page, pageSize, total } };
```

Cursor-based pagination is more stable than `skip` when data changes frequently:

```ts
this.prisma.post.findMany({
  take: 20,
  skip: 1,               // skip the cursor row
  cursor: { id: lastId },
  orderBy: { id: 'asc' },
});
```

## Filtering and sorting

```ts
this.prisma.post.findMany({
  where: {
    published: true,
    title: { contains: search, mode: 'insensitive' },
    authorId: { in: authorIds },
    createdAt: { gte: since },
  },
  orderBy: { createdAt: 'desc' },
});
```

Pass validated query params from the controller into the service instead of building `where` objects from raw input.

## Database connection management

- Prisma manages a connection pool automatically based on `DATABASE_URL`.
- `onModuleInit` connects on startup and fails fast if the DB is unreachable.
- `onModuleDestroy` disconnects gracefully on shutdown.
- Never create a new client per request; reuse the injected singleton.

For TypeORM, the connection is configured in the module:

```ts
@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST,
      port: 5432,
      autoLoadEntities: true,
      synchronize: false, // never true in production
    }),
  ],
})
```

## Repository/service patterns

Keep the data-access layer behind services:

```
Controller ──> Service ──> Prisma client / TypeORM repository
```

- Controllers parse and validate input, never touch the ORM.
- Services contain business rules and orchestrate multiple queries/transactions.
- With TypeORM you can also use `@InjectRepository(Entity)` to inject a repository into a service.

```ts
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepo: Repository<User>,
  ) {}

  findAll() {
    return this.userRepo.find();
  }
}
```

## Mid/Senior Interview Questions and Answers

### 1. Why is Prisma recommended over TypeORM for a new project?

**Answer:** Prisma is schema-first: the schema is the single source of truth, the
generated client is fully type-safe, and queries fail at compile time instead of
runtime. Migrations are generated and predictable.

TypeORM is flexible and closer to classic ORMs, but its decorator-based entities
and dynamic queries give less compile-time safety. For greenfield projects,
Prisma's safety and simplicity usually win.

### 2. How do you prevent N+1 queries with Prisma?

**Answer:** N+1 happens when you load a list, then query related rows per item.
Use `include` to fetch relations in the same query, batch queries with `findMany
where id in (...)`, or use raw SQL for complex reports. Check query counts with
Prisma's `log: ['query']` and Prisma Studio/query logging.

### 3. When do you use a transaction?

**Answer:** Whenever several writes must be atomic - an order with items, a
transfer between accounts, or "create user + profile". Without a transaction a
partial failure leaves inconsistent data. Use `$transaction` with a callback for
interactive logic, or the array form for a fixed set of operations.

### 4. How do you handle connection management in production?

**Answer:** Reuse a single `PrismaService` (or TypeORM connection) created once
at bootstrap, connect during `onModuleInit`, and disconnect during
`onModuleDestroy`. Let Prisma/TypeORM manage the pool. Add connection timeouts,
retry logic for transient failures, and fail fast on startup if the database is
unavailable. Avoid `synchronize: true` in production; always use migrations.

### 5. What is the difference between `synchronize` and migrations?

**Answer:** `synchronize` (TypeORM) auto-creates tables from entities on startup,
which is convenient in development but dangerous in production because it can
drop or alter data unpredictably. Migrations are versioned SQL files applied in
order, giving you reviewable, reversible, and deterministic schema changes.