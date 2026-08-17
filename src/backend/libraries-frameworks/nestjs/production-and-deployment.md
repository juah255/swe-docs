# Production & Deployment

Finally: configuration, logging, health checks, graceful shutdown, Docker, reverse proxies, CI/CD, monitoring, security, and performance.

## Configuration management

Centralize configuration with `@nestjs/config` and typed config namespaces.

```ts
import { registerAs } from '@nestjs/config';

export default registerAs('database', () => ({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT, 10),
  url: process.env.DATABASE_URL,
}));
```

```ts
import { ConfigService } from '@nestjs/config';

@Injectable()
export class DatabaseService {
  constructor(config: ConfigService) {
    const db = config.get('database'); // typed section
  }
}
```

Validate required variables at startup with a validation schema so a missing key fails fast:

```ts
ConfigModule.forRoot({
  isGlobal: true,
  validationSchema: Joi.object({
    DB_HOST: Joi.string().required(),
    DB_PORT: Joi.number().default(5432),
    JWT_SECRET: Joi.string().required(),
  }),
});
```

## Environment variables

- Never commit secrets. Use `.env.example` for documented variables.
- Prefix app-specific variables (`APP_`) to avoid collisions.
- Inject via `ConfigService`, not `process.env` scattered through code.
- Rotate secrets and use a secrets manager (Vault, AWS Secrets Manager) in production instead of `.env` files.

## Logging

Use a structured logger instead of `console.log`.

```ts
import { Logger } from '@nestjs/common';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  create(dto: CreateUserDto) {
    this.logger.log(`Creating user ${dto.email}`);
    try {
      // ...
    } catch (err) {
      this.logger.error('Failed to create user', err.stack, dto.email);
    }
  }
}
```

Set the log level from the environment:

```ts
app.useLogger(
  process.env.NODE_ENV === 'production'
    ? ['error', 'warn', 'log']
    : ['error', 'warn', 'log', 'debug', 'verbose'],
);
```

Emit structured JSON (timestamp, level, service, request ID) for ingestion by logging systems. Never log passwords, tokens, or full request bodies with sensitive data.

## Health checks

Expose a `/health` endpoint for orchestrators and load balancers.

```bash
npm i @nestjs/terminus
```

```ts
import { HealthCheck, HealthCheckService, TypeOrmHealthIndicator } from '@nestjs/terminus';

@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private db: TypeOrmHealthIndicator,
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([() => this.db.pingCheck('database')]);
  }
}
```

Use the built-in health indicators (`database`, `redis`, `memory`) or write custom ones that probe your dependencies. Liveness vs readiness: readiness should fail when the app cannot serve (DB down), while liveness usually checks the process itself.

## Graceful shutdown

Let in-flight requests finish before the process exits.

```ts
import { enableShutdownHooks } from '@nestjs/core';

const app = await NestFactory.create(AppModule);
app.enableShutdownHooks(); // fires on SIGTERM/SIGINT

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableShutdownHooks();
  await app.listen(3000);
}
```

Implement `OnApplicationShutdown` in providers to close connections:

```ts
@Injectable()
export class PrismaService implements OnApplicationShutdown {
  async onApplicationShutdown(signal: string) {
    await this.$disconnect();
  }
}
```

## Docker

A production Dockerfile for NestJS:

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS production
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
RUN npm ci --omit=dev
USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

Multi-stage builds keep the runtime image small and free of build tooling.

## Docker Compose

A local stack with app + database + Redis:

```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://app:app@db:5432/app
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    restart: unless-stopped

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app
      POSTGRES_DB: app
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

volumes:
  pgdata:
```

## Reverse proxy

Put a reverse proxy (Nginx, Caddy, or a cloud load balancer) in front of the Node process to handle TLS, compression, and static assets.

```nginx
server {
  listen 443 ssl;
  server_name api.example.com;

  ssl_certificate     /etc/ssl/api.crt;
  ssl_certificate_key /etc/ssl/api.key;

  location / {
    proxy_pass http://app:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

Enable `trust proxy` in the app so Express sees the real client IP behind the proxy.

## CI/CD

A minimal GitHub Actions workflow:

```yaml
name: CI
on: [push, pull_request]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: app_test
          POSTGRES_USER: app
          POSTGRES_PASSWORD: app
        ports: ["5432:5432"]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm run lint
      - run: npm run test
      - run: npm run test:e2e
        env:
          DATABASE_URL: postgresql://app:app@localhost:5432/app_test
      - run: npm run build
```

Deploy after tests pass: build the Docker image, push it to a registry, and roll it out.

## Error monitoring

Integrate an error tracker (Sentry, Datadog) with a global exception filter:

```ts
@Catch()
export class SentryFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    if (exception instanceof HttpException) {
      // HTTP errors are expected - no need to alert on 4xx
      return ctx.getResponse().status(exception.getStatus()).json(exception.getResponse());
    }
    Sentry.captureException(exception);
    ctx.getResponse().status(500).json({ statusCode: 500, message: 'Internal server error' });
  }
}
```

Collect metrics: request latency, error rate, queue depth, database pool usage.

## Rate limiting

Protect public endpoints with `@nestjs/throttler`.

```bash
npm i @nestjs/throttler
```

```ts
import { ThrottlerModule } from '@nestjs/throttler';

@Module({
  imports: [
    ThrottlerModule.forRoot([
      { ttl: 60_000, limit: 100 }, // 100 requests per minute per IP
    ]),
  ],
})
```

Stricter per-route limits:

```ts
@Throttle({ default: { limit: 5, ttl: 60_000 } })
@Post('login')
login() {}
```

Use Redis-backed storage when running multiple instances so limits are shared.

## Caching

Cache expensive reads with `@nestjs/cache-manager`.

```ts
@UseInterceptors(CacheInterceptor)
@Get()
findAll() {
  return this.productsService.findAll();
}
```

Or cache manually with a TTL for finer control:

```ts
@Injectable()
export class ProductsService {
  constructor(private cache: Cache) {}

  async findOne(id: number) {
    const cached = await this.cache.get(`product:${id}`);
    if (cached) return cached;

    const product = await this.prisma.product.findUnique({ where: { id } });
    await this.cache.set(`product:${id}`, product, 60_000);
    return product;
  }
}
```

Invalidate caches on writes (`del` the key when the entity changes). Use Redis as the cache store in production (shared across instances).

## Redis

Redis is the production cache and queue backend (BullMQ). Configure both the cache store and BullMQ against the same Redis instance, and include a Redis health check. See [Real-time & Async](realtime-and-async.md) for queues.

## Security

- Use `helmet` for security headers: `app.use(helmet())`.
- Enable CORS with an explicit allowlist: `app.enableCors({ origin: ['https://app.example.com'] })`.
- Rate limit auth endpoints to slow brute force.
- Store only hashed passwords (`bcrypt`/`argon2`).
- Validate every input with DTOs + `ValidationPipe` (`whitelist: true`).
- Use HTTPS everywhere (TLS at the reverse proxy).
- Keep dependencies patched (Dependabot/Renovate, `npm audit`).
- Escape output to avoid XSS; use parameterized queries (Prisma does this).

## Performance optimization

- Use `fastify` adapter for higher throughput: `NestFactory.create<NestFastifyApplication>(AppModule, new FastifyAdapter())`.
- Compress responses (`compression` middleware) at the proxy or app level.
- Cache hot reads; paginate and index database queries (check `EXPLAIN`).
- Avoid N+1: use `include`/`select` instead of looping queries.
- Keep providers singleton by default; avoid request scope unless required.
- Use clustering (multiple Node processes) or horizontal scaling behind a load balancer.

## Mid/Senior Interview Questions and Answers

### 1. How do you handle secrets and configuration in production?

**Answer:** Separate code from configuration. Load config through `ConfigService`
with validated environment variables, keep a `.env.example`, and never commit
secrets. In production, inject secrets from the platform (secrets manager or
deployment environment) and rotate them. Fail fast at startup if required
variables are missing.

### 2. What is the difference between liveness and readiness probes?

**Answer:** A liveness probe checks that the process is running (health endpoint
returns 200 even if dependencies are down) so the orchestrator restarts a hung
process. A readiness probe checks that the app can serve traffic - dependencies
such as the database and Redis are reachable - so the load balancer stops sending
requests during a degradation. Mixing them up causes cascading restarts or
serving traffic that fails.

### 3. How do you implement graceful shutdown?

**Answer:** Enable `app.enableShutdownHooks()` to catch `SIGTERM`/`SIGINT`, then
use `OnApplicationShutdown` in providers to close database connections, Redis,
and queue connections. The platform sends `SIGTERM`, waits for in-flight work,
then exits. This prevents dropped requests and corrupted state during deploys.

### 4. How do you rate limit and why is Redis important for it?

**Answer:** Rate limiting caps requests per client per window using
`@nestjs/throttler`. With a single instance, in-memory counting works. With
multiple instances, in-memory counters are per-process, so clients could exceed
the limit by hitting different instances. A Redis-backed store shares the counter
across instances for a global limit.

### 5. What performance optimizations matter most for a NestJS API?

**Answer:** Start with the database: correct indexes, pagination, and avoiding
N+1 queries. Then add caching for hot reads and use async work (queues) for slow
operations. Use the Fastify adapter and compression for higher throughput, keep
providers singleton-scoped, and scale horizontally behind a load balancer with a
shared Redis cache and queue.