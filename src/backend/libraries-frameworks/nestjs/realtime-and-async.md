# Real-time & Async Processing

After REST APIs: WebSockets for real-time communication, and background jobs with BullMQ for async work.

## WebSockets overview

WebSockets keep a persistent bidirectional connection between client and server, pushing data without polling.

In NestJS, a gateway is the WebSocket equivalent of a controller: it handles messages, rooms, and emits events.

## Gateways

```bash
npm i @nestjs/websockets @nestjs/platform-socket.io socket.io
```

```ts
import {
  WebSocketGateway,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Socket } from 'socket.io';

@WebSocketGateway({ cors: { origin: '*' } })
export class ChatGateway {
  @SubscribeMessage('message')
  handleMessage(@MessageBody() body: string, @ConnectedSocket() client: Socket) {
    return { event: 'echo', data: body };  // responds to the sender
  }
}
```

Register the gateway in a module's `providers`.

## Socket.IO

Socket.IO is the default adapter. Client side:

```js
const socket = io('http://localhost:3000');
socket.emit('message', 'hello');
socket.on('echo', (data) => console.log(data));
```

Server emits:

```ts
this.server.emit('event', payload);          // to everyone
this.server.to(room).emit('event', payload); // to a room
client.emit('event', payload);               // to one client
```

## WebSocket authentication

Authenticate connections with a guard on the gateway or by validating the handshake token.

```ts
import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { WsException } from '@nestjs/websockets';

@Injectable()
export class WsAuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const client = context.switchToWs().getClient();
    const token = client.handshake.headers.authorization?.replace('Bearer ', '');

    try {
      client.user = await this.jwtService.verifyAsync(token);
      return true;
    } catch {
      throw new WsException('Unauthorized');
    }
  }
}
```

Apply it:

```ts
@UseGuards(WsAuthGuard)
@WebSocketGateway()
export class ChatGateway {}
```

Use `WsException` (not `HttpException`) for errors inside gateways. Validate message payloads with DTOs + `ValidationPipe` just like HTTP bodies.

## Rooms

Rooms group clients for targeted broadcasts:

```ts
@SubscribeMessage('join')
joinRoom(@MessageBody() room: string, @ConnectedSocket() client: Socket) {
  client.join(room);
  this.server.to(room).emit('joined', { room });
}

@SubscribeMessage('leave')
leaveRoom(@MessageBody() room: string, @ConnectedSocket() client: Socket) {
  client.leave(room);
}
```

Typical room naming: `user:${id}` for per-user notifications, `order:${orderId}` for order updates, `chat:${roomId}` for conversations.

## Events

Define typed event contracts to avoid string typos across the codebase:

```ts
export interface WsEvents {
  'message': { room: string; text: string };
  'notification': { type: string; data: unknown };
  'joined': { room: string };
}
```

## Background jobs with BullMQ

BullMQ is the standard queue system for NestJS, backed by Redis.

```bash
npm i @nestjs/bullmq bullmq ioredis
```

```ts
import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';

@Module({
  imports: [
    BullModule.forRoot({
      connection: { host: process.env.REDIS_HOST, port: 6379 },
    }),
    BullModule.registerQueue({ name: 'email' }),
  ],
})
export class QueueModule {}
```

## Queues

Define a processor that handles queued jobs:

```ts
import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';

@Processor('email')
export class EmailProcessor extends WorkerHost {
  async process(job: Job): Promise<void> {
    const { to, subject } = job.data;
    await this.sendEmail(to, subject);   // slow/async work
  }
}
```

Add jobs to the queue:

```ts
@Injectable()
export class EmailService {
  constructor(@InjectQueue('email') private emailQueue: Queue) {}

  async send(to: string, subject: string) {
    await this.emailQueue.add('send', { to, subject }, {
      attempts: 3,
      backoff: { type: 'exponential', delay: 2000 },
    });
  }
}
```

Use queues for slow, retryable, or decoupled work: emails, notifications, image processing, PDF generation, webhooks, and heavy aggregation.

## Redis

BullMQ needs Redis, and Redis is also the go-to cache.

```bash
npm i @nestjs/cache-manager cache-manager ioredis
```

```ts
import { CacheModule } from '@nestjs/cache-manager';

@Module({
  imports: [
    CacheModule.register({
      ttl: 60, // seconds
      max: 100,
      isGlobal: true,
    }),
  ],
})
```

For a Redis-backed cache, use `@keyv/redis` with the keyv store, or configure an ioredis adapter for the cache module.

## Workers

Workers are separate processes (or the same app with multiple queue workers) that consume jobs. Scale workers independently from the API.

- Keep processors idempotent: re-running a job must not corrupt state.
- Add `attempts` + `backoff` for transient failures.
- Push failures to a dead-letter queue after max attempts.

## Scheduled jobs / cron

Use `@nestjs/schedule` for time-based tasks.

```bash
npm i @nestjs/schedule
```

```ts
import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [ScheduleModule.forRoot()],
})
export class AppModule {}
```

```ts
import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class TasksService {
  @Cron(CronExpression.EVERY_DAY_AT_3AM)
  cleanupOldSessions() {
    // run daily
  }

  @Interval(60_000)
  heartbeat() {
    // run every minute
  }

  @Timeout(5000)
  onBootstrap() {
    // run once, 5s after start
  }
}
```

Prefer cron for fixed-schedule maintenance (cleanup, reports, syncs). Prefer queues for work triggered by events (send email when an order is created).

## Mid/Senior Interview Questions and Answers

### 1. WebSockets vs HTTP - when do you use each?

**Answer:** HTTP is request/response: stateless, cacheable, and fine for
client-initiated reads. WebSockets keep a persistent bidirectional channel,
ideal for live data: chat, notifications, collaborative editing, real-time
dashboards, and game state.

Use WebSockets when the server must push data without the client asking, and the
connection count is manageable. For simple periodic updates, polling may be
simpler.

### 2. How do you authenticate a WebSocket connection?

**Answer:** Validate the token during the handshake (via `handshake.headers` or
query params), then store the identity on the socket. Use a guard on the gateway
with `WsException` for errors. Tokens in the handshake are the common pattern;
cookies are also possible for browser clients.

Never trust a socket's identity after connection; re-validate on sensitive
messages or rely on the initial handshake validation.

### 3. What are queues used for in a NestJS app?

**Answer:** Queues decouple request handling from slow work: sending emails,
generating reports, processing uploads, calling webhooks. The request returns
immediately, and a worker processes the job asynchronously with retries and
backoff. This keeps API latency low and makes the work resilient to failures.

### 4. How do you make background jobs reliable?

**Answer:** Make processors idempotent, configure `attempts` and exponential
`backoff`, and move permanently failed jobs to a dead-letter queue. Use
job-level deduplication keys where duplicates are dangerous. Monitor queue depth,
failure rates, and processing time.

### 5. Cron vs queues - which do you use for which task?

**Answer:** Cron schedules fixed-time recurring work (daily cleanup, weekly
reports, syncing external systems). Queues handle event-driven async work
(anything triggered by user actions). For periodic jobs that must be distributed
or retried, push them onto a queue from a cron trigger so workers handle
execution and retries.