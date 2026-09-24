# WebFlux and Concurrency

Spring WebFlux is Spring's reactive web framework. It supports non-blocking
request handling with Reactive Streams types and can run on servers such as
Reactor Netty. It is an alternative execution model, not a faster annotation for
every application.

## MVC or WebFlux?

Choose Spring MVC when the application uses blocking persistence and clients,
the workload is straightforward request-per-thread I/O, or the team benefits
from the simpler imperative model.

Choose WebFlux when a service has high I/O concurrency, streaming requirements,
and an end-to-end non-blocking stack. A reactive controller that calls blocking
JPA or a blocking SDK still blocks its event-loop thread.

When MVC and WebFlux starters are both present, Boot generally chooses MVC.
Avoid mixing them without a clear integration reason.

## Reactive Controllers

```java
@RestController
@RequestMapping("/events")
class EventController {

    private final EventService events;

    EventController(EventService events) {
        this.events = events;
    }

    @GetMapping(produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    Flux<EventResponse> stream() {
        return events.live().map(EventResponse::from);
    }

    @GetMapping("/{id}")
    Mono<ResponseEntity<EventResponse>> get(@PathVariable UUID id) {
        return events.find(id)
            .map(EventResponse::from)
            .map(ResponseEntity::ok)
            .defaultIfEmpty(ResponseEntity.notFound().build());
    }
}
```

Keep reactive pipelines lazy. Avoid calling `subscribe()` inside application
services; the web or messaging adapter normally owns subscription, cancellation,
and error propagation.

## Blocking Boundaries

If a blocking library is unavoidable, isolate it on a bounded scheduler and
measure the queue. This is a compatibility bridge, not an end-to-end reactive
design.

```java
Mono.fromCallable(() -> legacyClient.fetch(id))
    .subscribeOn(Schedulers.boundedElastic());
```

Never move unbounded blocking work onto the parallel or event-loop scheduler.
Each pool needs concurrency, queue, and timeout limits.

## Backpressure and Streaming

Reactive Streams lets a consumer signal demand. Backpressure cannot make an
unbounded upstream safe automatically: buffer, drop, sample, reject, or persist
according to the domain. Set maximum in-memory codec sizes and limit inbound
streams to protect memory.

Streaming responses may live much longer than normal requests. Handle client
disconnects, heartbeats, proxy timeouts, slow consumers, and shutdown explicitly.

## Reactive Data and Transactions

Use reactive drivers and Spring Data R2DBC for non-blocking relational access.
JPA is blocking and depends on thread-bound persistence behavior.

Reactive transaction context travels through the publisher context rather than
a conventional thread-local. Keep the whole transactional pipeline inside the
reactive transaction operator. Do not expect an imperative `@Transactional`
method or thread-local state to cross arbitrary reactive operators.

## `@Async` and Executors

`@Async` submits eligible proxy-invoked methods to an executor. It is useful for
bounded in-process concurrency but is not durable job processing: work is lost
on a crash and can be rejected during shutdown.

Configure named executors with bounded queues, explicit rejection behavior, and
observability. Self-invocation bypasses the async proxy. Propagate logging,
security, and observation context deliberately; thread-local context does not
move automatically in every configuration.

Use a message broker or job system when work must be retried, audited, scheduled,
or survive application restarts.

