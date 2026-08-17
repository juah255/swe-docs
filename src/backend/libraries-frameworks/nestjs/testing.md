# Testing

Learn both unit and integration testing with Jest: services, controllers, mocked providers, e2e tests, and test databases.

## Testing setup

Nest scaffolds Jest with the CLI. The default setup includes:

- `*.spec.ts` unit tests run by `npm run test`
- `test/` e2e tests run by `npm run test:e2e`

Jest config lives in `package.json` (`"jest"` key or `jest.config`). Common additions:

```json
{
  "collectCoverageFrom": ["src/**/*.ts"],
  "coverageDirectory": "coverage"
}
```

## Unit tests

Unit tests verify a single unit in isolation - a service or controller - with dependencies replaced by mocks.

### Service testing

```ts
import { Test } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from './prisma.service';

describe('UsersService', () => {
  let service: UsersService;
  let prisma: { user: { findMany: jest.Mock } };

  beforeEach(async () => {
    prisma = { user: { findMany: jest.fn() } };

    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get(UsersService);
  });

  it('returns users from the database', async () => {
    prisma.user.findMany.mockResolvedValue([{ id: 1, name: 'A' }]);

    await expect(service.findAll()).resolves.toEqual([{ id: 1, name: 'A' }]);
    expect(prisma.user.findMany).toHaveBeenCalledTimes(1);
  });
});
```

The `Test.createTestingModule` creates the same DI container Nest uses at runtime, so real wiring is validated.

### Controller testing

```ts
import { Test } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

describe('UsersController', () => {
  let controller: UsersController;
  let service: { findAll: jest.Mock };

  beforeEach(async () => {
    service = { findAll: jest.fn().mockResolvedValue([]) };

    const module = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [{ provide: UsersService, useValue: service }],
    }).compile();

    controller = module.get(UsersController);
  });

  it('delegates to the service', async () => {
    await controller.findAll();
    expect(service.findAll).toHaveBeenCalled();
  });
});
```

## Mocking providers

Replace real dependencies with `useValue` mocks:

```ts
{ provide: UsersService, useValue: { findAll: jest.fn() } }
```

Or override implementations:

```ts
{ provide: PaymentService, useClass: FakePaymentService }
```

Mock only what the unit under test needs. Keep mocks typed by implementing the real interface so the test fails if the contract changes.

## Integration tests

Integration tests exercise real modules together (services + database) without a live server.

```ts
const module = await Test.createTestingModule({
  imports: [UsersModule],
}).compile();

const service = module.get(UsersService);
```

Run them against a real or in-memory database so repository queries are actually executed.

## E2E tests

E2E tests boot the full application over HTTP using `supertest`.

```ts
// test/app.e2e-spec.ts
import { Test } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();
  });

  it('GET /users returns 200', () => {
    return request(app.getHttpServer())
      .get('/users')
      .expect(200)
      .expect([]);
  });

  afterAll(async () => {
    await app.close();
  });
});
```

Apply the same global pipes/interceptors as production, or the e2e tests will not match real behavior.

## Test database

Never run tests against the production database.

Options:

- A dedicated database per environment (`DATABASE_URL` points to a test database).
- An in-memory database (SQLite for Prisma/TypeORM in-memory, or Testcontainers for PostgreSQL).
- Truncate or reset data between tests to keep tests independent.

```ts
// before each test run
await prisma.user.deleteMany();
```

With PostgreSQL + Testcontainers:

```bash
npm i -D @testcontainers/postgresql
```

```ts
const container = await new PostgreSqlContainer('postgres:16').start();
process.env.DATABASE_URL = container.getConnectionUri();
```

Run migrations on the test database before the suite and truncate tables between tests. Make tests parallel-safe by using unique data per test or sequential execution.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between unit, integration, and e2e tests in Nest?

**Answer:** Unit tests verify a single class (service or controller) with mocked
dependencies. Integration tests verify real modules working together, including
the database. E2E tests boot the full application and hit it over HTTP,
exercising guards, pipes, interceptors, and filters end to end.

Start with unit tests for logic, add integration tests for data access, and use
a smaller set of e2e tests for the critical user flows.

### 2. Why do you mock dependencies in unit tests?

**Answer:** Mocking isolates the unit under test so failures come from the code
being tested, not its dependencies. It also makes tests fast (no database or
network) and deterministic. Over-mocking hides integration bugs, so cover real
wiring with integration/e2e tests instead.

### 3. How do you test a guard, pipe, or interceptor?

**Answer:** Instantiate the hook directly with a mocked `ExecutionContext`
(`switchToHttp().getRequest()` returning a fake request) or a fake `Reflector`.
For interceptor tests, call `intercept(context, { handle: () => of(value) })` and
assert on the emitted observable. For guards, assert the boolean return value and
that `request.user` is set.

### 4. How do you make tests independent of each other?

**Answer:** Run each test against fresh data - truncate tables or reset the
database in `beforeEach`, or create unique records per test. Never depend on
execution order. With a shared test database, clean up created rows after each
test so parallel suites do not interfere.

### 5. How do you test authenticated endpoints in e2e tests?

**Answer:** Generate a real token in the test (sign a JWT with the test secret)
and send it in the `Authorization` header, or run the login flow and reuse the
returned token. For e2e, prefer real tokens over `overrideGuard` unless the
auth flow itself is being stubbed, because you want the guard behavior to run.