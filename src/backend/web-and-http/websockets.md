# WebSockets

## What is a WebSocket?

A **WebSocket** is a long-lived, full-duplex communication channel between a
client and server. Unlike normal HTTP requests, either side can send messages
after the connection is established.

WebSockets are commonly used for:

- Chat and collaboration tools
- Live notifications
- Multiplayer or real-time dashboards
- Presence and typing indicators
- Streaming application events to browsers

## How the Connection Starts

A WebSocket connection begins as an HTTP request with an upgrade handshake.
If the server accepts it, the connection switches from HTTP request/response
behavior to the WebSocket protocol.

Important details:

- The browser usually connects with `ws://` or `wss://`.
- `wss://` is WebSocket over TLS and should be used in production.
- The connection is stateful and stays open until one side closes it or the
  network drops.
- After the upgrade, communication happens as WebSocket frames, not normal HTTP
  requests.

## WebSocket vs. HTTP Polling vs. SSE

| Approach | Direction | Good For | Trade-Off |
| --- | --- | --- | --- |
| Polling | Client repeatedly asks server | Simple periodic updates | Wasteful and delayed |
| Long polling | Client waits for server response, then repeats | Broad compatibility | More request overhead |
| Server-Sent Events (`SSE`) | Server to client | One-way live updates | Client cannot send over same channel |
| WebSocket | Client and server both send | Low-latency two-way messaging | More stateful infrastructure |

Use WebSockets when the client and server both need to send data quickly and
frequently. Use SSE when updates only flow from server to browser. Use normal
HTTP when request/response is enough.

## Design Notes

- **Authentication**: authenticate during the handshake using cookies, session
  data, or a short-lived token. Re-check authorization for sensitive messages.
- **Authorization**: joining a room, subscribing to a channel, or sending an
  action must still enforce permissions server-side.
- **Message format**: define stable message types and schemas, such as
  `chat.message.created` or `notification.read`.
- **Heartbeats**: use ping/pong or application-level heartbeat messages to
  detect dead connections.
- **Backpressure**: avoid sending faster than a client can receive. Slow
  clients should be buffered carefully, throttled, or disconnected.
- **Reconnection**: clients should retry with backoff and resubscribe after a
  reconnect.
- **Ordering**: include sequence numbers or timestamps if message order matters.
- **Idempotency**: include message IDs for actions that might be retried after
  reconnects.
- **Observability**: track active connections, connection duration, message
  rate, disconnect reasons, and publish failures.

## Scaling WebSockets

WebSockets make scaling different from stateless HTTP because connections stay
attached to a running server process.

Common production concerns:

- Load balancers and reverse proxies must support connection upgrades.
- Idle timeouts must be longer than expected connection idle periods.
- Horizontal scaling usually needs shared pub/sub, such as Redis, NATS, or
  Kafka, so any app instance can publish to users connected elsewhere.
- Sticky sessions may help but should not be the only scaling strategy.
- Deployments should drain existing connections before stopping old instances.

## Security Notes

- Prefer `wss://` in production.
- Validate the `Origin` header for browser clients.
- Do not trust client-sent user IDs, room IDs, or roles.
- Rate limit connection attempts and message sends.
- Validate every message payload before processing it.
- Avoid logging sensitive message contents.

## Mid/Senior Interview Questions and Answers

### 1. When would you choose WebSockets instead of REST?

**Answer:** Choose WebSockets when the application needs low-latency,
bidirectional communication, such as chat, presence, collaboration, or live
dashboards.

REST is still better for normal request/response operations such as loading a
profile, creating a resource, or submitting a form. Many systems use both:
REST for durable resource operations and WebSockets for live updates.

### 2. Why are WebSockets harder to scale than stateless HTTP?

**Answer:** WebSocket connections are long-lived and attached to a specific
server instance. If a user connects to instance A, instance B cannot directly
write to that connection.

At scale, systems usually need a shared pub/sub layer, connection registry,
load balancer support, heartbeat handling, and graceful connection draining
during deploys.

### 3. How should authentication work with WebSockets?

**Answer:** Authenticate the connection during the handshake using a secure
cookie, session, or short-lived token. After connection, authorize each
sensitive action or subscription.

Authentication proves the client identity. It does not automatically mean the
client can join every room, subscribe to every account, or send every message.

### 4. What failures should a WebSocket client handle?

**Answer:** A client should handle disconnects, missed messages, duplicate
messages, auth expiry, server restarts, network changes, and slow reconnects.

Production clients usually reconnect with backoff, refresh credentials if
needed, resubscribe to channels, and use message IDs or sequence numbers to
recover cleanly.
