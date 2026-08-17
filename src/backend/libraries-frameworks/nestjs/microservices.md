# Microservices

Only study this after you are comfortable with normal NestJS applications. Microservices split an application into independently deployable services that communicate over a transport.

## NestJS microservice architecture

A NestJS microservice is a Nest application using a different transport instead of HTTP. Services communicate with message patterns (request/response) or event patterns (fire-and-forget).

```ts
// main.ts - microservice bootstrap
import { NestFactory } from '@nestjs/core';
import { Transport, MicroserviceOptions } from '@nestjs/microservices';

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(
    AppModule,
    {
      transport: Transport.TCP,
      options: { host: '0.0.0.0', port: 3001 },
    },
  );
  await app.listen();
}
bootstrap();
```

Clients connect with `ClientProxy`.

## TCP transport

The default transport: request/response over TCP.

```ts
@Module({
  providers: [
    {
      provide: 'ORDER_SERVICE',
      useFactory: (config: ConfigService) =>
        ClientProxyFactory.create({
          transport: Transport.TCP,
          options: { host: 'localhost', port: 3001 },
        }),
      inject: [ConfigService],
    },
  ],
  exports: ['ORDER_SERVICE'],
})
export class OrderClientModule {}
```

Inject and call:

```ts
@Injectable()
export class OrderService {
  constructor(@Inject('ORDER_SERVICE') private client: ClientProxy) {}

  findOrder(id: number) {
    return this.client.send({ cmd: 'order.find' }, { id }); // request/response
  }
}
```

## Message patterns

The microservice side declares message handlers:

```ts
import { Controller } from '@nestjs/common';
import { MessagePattern, Payload } from '@nestjs/microservices';

@Controller()
export class OrdersController {
  @MessagePattern({ cmd: 'order.find' })
  find(@Payload() data: { id: number }) {
    return this.ordersService.findOne(data.id);
  }
}
```

`client.send(pattern, data)` returns an observable that resolves with the reply. This is request/response - the caller waits.

## Event-driven architecture

Use `EventPattern` for fire-and-forget events. The publisher does not wait for a reply.

```ts
// publisher
this.client.emit('order.created', { orderId: 1 });
```

```ts
// consumer
@EventPattern('order.created')
async handleOrderCreated(@Payload() data: { orderId: number }) {
  await this.notificationsService.send(data.orderId); // no reply sent
}
```

Events decouple services: new consumers can subscribe without changing the publisher.

## Redis transport

Use Redis for both request/response and pub/sub, shared via the `REDIS` client.

```ts
ClientProxyFactory.create({
  transport: Transport.REDIS,
  options: { host: 'localhost', port: 6379 },
});
```

## RabbitMQ

RabbitMQ supports durable queues, exchanges, and routing keys.

```ts
ClientProxyFactory.create({
  transport: Transport.RMQ,
  options: {
    urls: ['amqp://localhost:5672'],
    queue: 'orders_queue',
    queueOptions: { durable: true },
  },
});
```

RabbitMQ is a good choice when you need complex routing, message acknowledgment, and durable persistent queues beyond simple pub/sub.

## Kafka

Kafka is designed for high-throughput, durable, replayable event streams.

```ts
ClientProxyFactory.create({
  transport: Transport.KAFKA,
  options: {
    client: { brokers: ['localhost:9092'] },
    consumer: { groupId: 'orders-consumer' },
  },
});
```

Consumers belong to consumer groups, and offsets track which events each group has processed, enabling replay.

## gRPC

gRPC uses protobufs for strongly typed, high-performance RPC over HTTP/2.

Define a `.proto`:

```proto
syntax = "proto3";
package orders;

service OrderService {
  rpc FindOrder (FindOrderRequest) returns (Order) {}
}

message FindOrderRequest { int64 id = 1; }
message Order { int64 id = 1; string status = 2; }
```

```ts
ClientProxyFactory.create({
  transport: Transport.GRPC,
  options: {
    package: 'orders',
    protoPath: join(__dirname, 'orders.proto'),
  },
});
```

Use gRPC when you need typed contracts, streaming, and performance between internal services.

## Message patterns vs events

| | Message patterns (`send`) | Events (`emit`) |
|---|---|---|
| Semantics | Request/response, caller waits | Fire-and-forget |
| Reply | Reply expected | No reply |
| Use for | Commands, queries, RPC | Notifications, projections, async side effects |
| Coupling | Caller knows the target | Publisher does not know consumers |

## Request-response vs events

- **Request/response** - use when the caller needs the result (validate, fetch, compute). Feels like an RPC call. Examples: `order.find`, `payment.authorize`.
- **Events** - use when an action should trigger side effects that may change. Examples: `order.created`, `user.deleted`. Multiple services can subscribe independently.

A common rule: emit events for things that happened; send messages for things you need answered.

## Microservice-to-microservice patterns

- **API Gateway** - a public HTTP API (NestJS) that fans out to internal microservices via clients.
- **Saga** - a sequence of local transactions coordinated by events/messages; each step emits an event that triggers the next, with compensating actions on failure.
- **Outbox pattern** - write the event to the same database transaction as the domain change, then a relay publishes it, guaranteeing at-least-once delivery.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between `send` and `emit` in Nest microservices?

**Answer:** `send` implements request/response: the caller gets an observable
that resolves with the reply from a matching `MessagePattern`. `emit` is
fire-and-forget: the publisher sends an event and does not wait, consumed by
`EventPattern` handlers.

Use `send` for commands/queries that need a result, `emit` for events that
trigger asynchronous side effects.

### 2. How do you choose between TCP, Redis, RabbitMQ, Kafka, and gRPC?

**Answer:** TCP is the simplest for small internal request/response. Redis gives
lightweight pub/sub with the same API. RabbitMQ adds durable queues, exchanges,
and acknowledgments for reliable messaging. Kafka is for high-throughput,
replayable event streams with consumer groups. gRPC provides typed protobuf
contracts and streaming for performance-critical RPC.

Pick based on throughput, durability, routing complexity, and whether you need
replay/streaming.

### 3. What is the outbox pattern and why do you need it?

**Answer:** The outbox pattern writes both the domain change and the event to the
same database transaction. A separate relay process publishes the event and
marks it sent. This avoids the dual-write problem - committing to the database
then failing to publish (or publishing then crashing), which loses or duplicates
events.

It gives at-least-once delivery, so consumers must be idempotent.

### 4. How do you make microservice consumers idempotent?

**Answer:** Deduplicate by event ID - store processed event IDs (or a unique
constraint keyed on them) and skip repeats. Apply the same check-then-act
pattern with database constraints for actions like "create", "charge", or
"notify". At-least-once delivery means retries are guaranteed, so idempotency
is mandatory, not optional.

### 5. When should you NOT use microservices?

**Answer:** When the application is small, the team is small, or the domain is
tightly coupled. Microservices add network failure modes, distributed
transactions, observability burden, and deployment complexity. Start as a
monolith with clear module boundaries (which NestJS enforces) and split services
only when scaling or team boundaries require it.