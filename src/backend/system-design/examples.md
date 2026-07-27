# System Design Examples

This section contains worked examples of common system design problems. Each example follows the standard approach:

1. Functional Requirements
2. Non-Functional Requirements
3. Capacity Estimation
4. High-Level Design
5. Data Model
6. API Design
7. Deep Dives
8. Trade-offs

---

## URL Shortener

### Functional Requirements

- Given a long URL, generate a short unique URL
- Given a short URL, redirect to the original URL
- Links expire after an optional TTL
- Track click counts and analytics

### Non-Functional Requirements

| Requirement | Target |
|---|---|
| Availability | `99.99%` -- redirects must always work |
| Latency | p99 < 50ms for redirect (cache hit), < 200ms (cache miss) |
| Scalability | 100M new URLs/month, 10B redirects/month |
| Consistency | Eventual for analytics; strong for URL uniqueness |
| Durability | No data loss for URL mappings |
| Security | No arbitrary redirect to malicious sites; rate limit creation |

### Capacity Estimation

- 100M new URLs/month = ~40 QPS average, ~200 QPS peak
- 10B redirects/month = ~4K QPS average, ~20K QPS peak
- Each short URL record: ~500 bytes
- Storage per year: `100M * 12 * 500B = ~600 GB`
- Read-heavy system (redirects dominate writes, estimated 100:1 read/write ratio)

### High-Level Design

```text
Client -> Load Balancer -> API Server -> Cache (Redis) -> Database
                              |
                              v
                         Analytics Pipeline
```

Components:

- **API Servers** -- stateless, horizontally scaled behind a load balancer
- **Cache (Redis)** -- store hot URLs to reduce database reads
- **Database** -- store URL mappings (MySQL, PostgreSQL, or DynamoDB)
- **Analytics pipeline** -- async click event processing (Kafka -> processing -> data warehouse)

### URL Encoding

Base62 encoding of an auto-increment ID or a random hash:

| Method | Pros | Cons |
|---|---|---|
| Auto-increment ID + Base62 | No collisions, short URLs | Predictable, sequential |
| Random hash (MD5/SHA256) | Unpredictable | Collision risk, longer |
| Counter + Base62 with salt | Unpredictable, short | Requires coordination |

Standard length: 7 characters gives `62^7 ≈ 3.5 trillion` unique URLs.

### Data Model

```sql
CREATE TABLE urls (
    id          BIGINT PRIMARY KEY,
    short_code  VARCHAR(7) UNIQUE NOT NULL,
    original_url TEXT NOT NULL,
    user_id     BIGINT,
    created_at  TIMESTAMP,
    expires_at  TIMESTAMP
);

CREATE INDEX idx_short_code ON urls(short_code);
```

### API Design

**Create short URL:**

```http
POST /api/v1/urls
Content-Type: application/json

{
  "original_url": "https://example.com/very/long/path?with=params",
  "expires_at": "2025-12-31T23:59:59Z",
  "custom_alias": "my-link"
}
```

Response:

```json
{
  "short_url": "https://short.ly/abc1234",
  "short_code": "abc1234",
  "original_url": "https://example.com/very/long/path?with=params",
  "expires_at": "2025-12-31T23:59:59Z"
}
```

**Redirect:**

```http
GET /{short_code}
```

Response: `302 Found` with `Location: https://example.com/very/long/path?with=params`

**Get URL info:**

```http
GET /api/v1/urls/{short_code}
```

Response:

```json
{
  "short_code": "abc1234",
  "original_url": "https://example.com/very/long/path?with=params",
  "clicks": 1523,
  "created_at": "2024-01-15T10:30:00Z",
  "expires_at": "2025-12-31T23:59:59Z"
}
```

**Delete short URL:**

```http
DELETE /api/v1/urls/{short_code}
```

### Key Deep Dives

**Read path:**

1. Client requests `https://short.ly/abc1234`
2. Check Redis cache for `abc1234`
3. On cache hit, return the original URL (redirect 301/302)
4. On cache miss, query database, populate cache, return redirect

**Cache strategy:**

- LRU eviction in Redis
- Cache hot URLs (Pareto principle: 20% of URLs get 80% of traffic)
- TTL-based expiration matching URL expiration

**301 vs 302 redirect:**

- `301 Moved Permanently` -- browser caches the redirect, fewer requests to your server
- `302 Found` -- browser always hits your server, needed for accurate click analytics

**Security:**

- Validate URLs against a blocklist of malicious domains
- Rate limit URL creation per user (e.g., 100/hour for free tier)
- Scan target URLs for malware before creating short links
- Use HTTPS for all short URLs

### Trade-offs

- Auto-increment IDs are simple but predictable; random hashes are safer but longer
- Strong consistency is not required for reads; eventual consistency with cache is fine
- Click analytics can be processed async (fire-and-forget events)

### Scaling Summary

- **Cache hot URLs** in Redis (20% of URLs get 80% of traffic)
- **Read replicas** for the database to handle redirect read load
- **Shard data** by short code hash if billions of URLs
- **CDN** in front of the redirect endpoint to absorb geographic traffic
- **Async analytics pipeline** (Kafka) to decouple click tracking from redirect path

---

## Blog System

### Functional Requirements

- Create, edit, publish, and delete blog posts (draft/published states)
- Tag posts with multiple tags
- Comment on published posts
- List posts with pagination and tag filtering
- Full-text search across post titles and content
- User registration and authentication

### Non-Functional Requirements

| Requirement | Target |
|---|---|
| Availability | `99.99%` -- reads should always work |
| Latency | p99 < 200ms for post reads; < 500ms for search |
| Scalability | 100K posts, 1M daily readers, 5K writes/day |
| Consistency | Strong for post metadata; eventual for search index |
| Durability | No data loss for published content |
| Security | JWT auth for writes; public reads; rate limit comments |

### Data Model

```sql
CREATE TABLE users (
    id              BIGINT PRIMARY KEY,
    username        VARCHAR(100) UNIQUE NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    created_at      TIMESTAMP DEFAULT NOW()
);

CREATE TABLE posts (
    id              BIGINT PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id),
    title           VARCHAR(500) NOT NULL,
    slug            VARCHAR(500) UNIQUE NOT NULL,
    content         TEXT NOT NULL,
    status          ENUM('draft', 'published') DEFAULT 'draft',
    published_at    TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tags (
    id      BIGINT PRIMARY KEY,
    name    VARCHAR(100) UNIQUE NOT NULL,
    slug    VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE post_tags (
    post_id BIGINT REFERENCES posts(id) ON DELETE CASCADE,
    tag_id  BIGINT REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
);

CREATE TABLE comments (
    id          BIGINT PRIMARY KEY,
    post_id     BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id     BIGINT NOT NULL REFERENCES users(id),
    content     TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_slug ON posts(slug);
CREATE INDEX idx_posts_status ON posts(status, published_at DESC);
CREATE INDEX idx_comments_post ON comments(post_id, created_at);
CREATE INDEX idx_post_tags_tag ON post_tags(tag_id);
```

### API Design

**List published posts (pagination, filter by tag):**

```http
GET /api/v1/posts?limit=20&cursor=1705312200_42&tag=python
```

Response:

```json
{
  "posts": [
    {
      "id": 41,
      "title": "Advanced Python Decorators",
      "slug": "advanced-python-decorators",
      "author": "alice",
      "tags": ["python", "advanced"],
      "published_at": "2024-01-15T10:30:00Z"
    }
  ],
  "next_cursor": "1705308600_35"
}
```

**Get post with comments:**

```http
GET /api/v1/posts/{slug}
```

Response:

```json
{
  "id": 41,
  "title": "Advanced Python Decorators",
  "slug": "advanced-python-decorators",
  "content": "...",
  "author": "alice",
  "tags": ["python", "advanced"],
  "published_at": "2024-01-15T10:30:00Z",
  "comments": [
    {
      "id": 101,
      "user": "bob",
      "content": "Great post!",
      "created_at": "2024-01-15T12:00:00Z"
    }
  ]
}
```

**Create post (auth, admin):**

```http
POST /api/v1/posts
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Advanced Python Decorators",
  "content": "Post content here...",
  "tags": ["python", "advanced"],
  "status": "draft"
}
```

**Update post (auth, owner):**

```http
PUT /api/v1/posts/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Title",
  "content": "Updated content...",
  "status": "published"
}
```

**Soft delete post (auth, owner):**

```http
DELETE /api/v1/posts/{id}
Authorization: Bearer <token>
```

**Add comment (auth):**

```http
POST /api/v1/posts/{id}/comments
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "Great post!"
}
```

### Key Deep Dives

**Cursor-based pagination:**

- Use `(published_at, id)` as the cursor composite key for deterministic ordering
- Cursor is the base64-encoded values from the last item on the previous page
- `WHERE (published_at, id) < (?, ?) ORDER BY published_at DESC, id DESC LIMIT 20`
- Avoids offset drift when new posts are published during pagination

**Search:**

- PostgreSQL full-text search for small to medium scale (tsvector + GIN index)
- Elasticsearch for large scale or complex ranking requirements
- Reindex on post publish/update via an async event (avoid synchronous index writes)
- Search index stores title, content, tags, and author -- not comments

**Caching (Redis):**

- Cache individual post details by slug: `post:{slug}` with 5-minute TTL
- Cache recent posts list: `posts:recent` with 1-minute TTL
- Cache per-tag post lists: `posts:tag:{tag_slug}` with 2-minute TTL
- Invalidate on update: delete the relevant cache keys when a post is created,
  updated, or deleted
- Use cache-aside pattern: read from cache first, fall back to database, then
  populate cache

**Slug generation:**

- Slugify the title on create: lowercase, replace spaces with hyphens, strip
  special characters
- Check uniqueness; append a short suffix on collision (e.g., `my-post-a3x`)
- Slug is immutable after creation (URL stability)

**Deployment:**

```text
Client -> CloudFront (CDN) -> ALB -> ECS/EC2 (API)
                                       |
                                  PostgreSQL (RDS)
                                  Redis (ElastiCache)
                                  Elasticsearch (optional)
```

- Docker containers on ECS Fargate or EC2
- PostgreSQL on RDS with read replicas for scaling reads
- Redis on ElastiCache for caching layer
- CloudFront in front of the API for static asset caching (images, CSS)
- CI/CD pipeline: push to main → build → test → deploy

### Trade-offs

- Full-text search in PostgreSQL is simple but limited; Elasticsearch adds power
  at the cost of operational complexity
- Cursor pagination is more complex than offset but gives stable, performant
  results on changing datasets
- Caching post detail is high-value (hot data); caching comments adds complexity
  with frequent invalidation
- Soft delete vs hard delete: soft preserves data and allows recovery but requires
  filtering deleted posts everywhere

### Scaling Summary

- **Redis cache** absorbs read traffic for hot posts and recent lists
- **PostgreSQL read replicas** scale read-heavy workloads independently
- **Elasticsearch** offloads search from the primary database
- **CDN** for static assets and cached API responses
- **Async indexing pipeline** for search (publish event → Elasticsearch update)
- **Shard by user_id** only if user count grows to billions; post count stays manageable longer

---

## Notification Service

### Functional Requirements

- Send notifications via multiple channels: push (mobile), SMS, email, in-app
- Support notification preferences per user
- Provide delivery status tracking
- Support notification templates

### Non-Functional Requirements

| Requirement | Target |
|---|---|
| Availability | `99.99%` -- missed notifications erode user trust |
| Latency | p99 < 500ms from API acceptance to queue; delivery latency varies by channel |
| Scalability | 10M users, 50M notifications/day, peak 10K notifications/second |
| Consistency | At-least-once delivery with deduplication |
| Durability | No lost notifications; delivery log retained for 90 days |
| Security | API key authentication; no notification content in logs; PII handling for SMS/email |

### Capacity Estimation

- 10M users, each receiving ~5 notifications/day
- Average: ~600 notifications/second, peak: ~3000/second
- Each notification payload: ~1 KB
- Storage for delivery logs: ~5 GB/day, ~450 GB for 90 days

### High-Level Design

```text
Notification Service -> Message Queue (Kafka/SQS) -> Channel Workers
    |                                                       |
    |  User Preferences                                     v
    v                                               Push / SMS / Email / In-App
  Database
```

Components:

- **API Gateway** -- receives notification requests, validates, rate limits
- **Notification Service** -- core logic, preference lookup, deduplication
- **Message Queue** -- decouples request from delivery, handles backpressure
- **Channel Workers** -- separate workers per channel (push, SMS, email, in-app)
- **Preference Service** -- user notification settings
- **Delivery Log Store** -- tracks status per notification

### Data Model

```sql
CREATE TABLE notifications (
    id          UUID PRIMARY KEY,
    user_id     BIGINT NOT NULL,
    channel     ENUM('push', 'sms', 'email', 'in_app'),
    title       VARCHAR(255),
    body        TEXT,
    status      ENUM('pending', 'sent', 'delivered', 'failed'),
    created_at  TIMESTAMP,
    sent_at     TIMESTAMP
);

CREATE TABLE user_preferences (
    user_id     BIGINT PRIMARY KEY,
    push_enabled    BOOLEAN DEFAULT TRUE,
    sms_enabled     BOOLEAN DEFAULT FALSE,
    email_enabled   BOOLEAN DEFAULT TRUE,
    quiet_hours_start TIME,
    quiet_hours_end   TIME
);
```

### API Design

**Send notification:**

```http
POST /api/v1/notifications
Content-Type: application/json

{
  "user_id": 12345,
  "channel": "push",
  "template": "order_shipped",
  "variables": {
    "order_id": "ORD-789",
    "tracking_url": "https://tracking.example.com/xyz"
  },
  "idempotency_key": "req-abc-123"
}
```

Response:

```json
{
  "notification_id": "notif-uuid-1",
  "status": "queued",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Get notification status:**

```http
GET /api/v1/notifications/{notification_id}
```

Response:

```json
{
  "notification_id": "notif-uuid-1",
  "status": "delivered",
  "channel": "push",
  "sent_at": "2024-01-15T10:30:02Z",
  "delivered_at": "2024-01-15T10:30:03Z"
}
```

**Send bulk notifications:**

```http
POST /api/v1/notifications/bulk
Content-Type: application/json

{
  "user_ids": [12345, 12346, 12347],
  "channel": "email",
  "template": "weekly_digest",
  "idempotency_key": "bulk-req-456"
}
```

**Update user preferences:**

```http
PUT /api/v1/users/{user_id}/notification-preferences
Content-Type: application/json

{
  "push_enabled": true,
  "sms_enabled": false,
  "email_enabled": true,
  "quiet_hours_start": "22:00",
  "quiet_hours_end": "08:00",
  "timezone": "America/New_York"
}
```

### Key Deep Dives

**Message queue pattern:**

- Each notification is published to a Kafka topic partitioned by user ID
- Partitioning ensures ordering per user (no out-of-order notifications)
- Channel workers consume from the queue independently
- Failed messages are retried with exponential backoff via a dead-letter queue (DLQ)

**Deduplication:**

- Use an idempotency key (client-provided or derived from content + user + timestamp)
- Store a hash in the database to prevent duplicate sends

**Rate limiting:**

- Per-user rate limits (e.g., max 10 SMS per hour)
- Per-channel throttling (SMS provider rate limits)
- Global throughput limits to protect downstream services

**Retry and failure handling:**

- Retry with exponential backoff (1s, 2s, 4s, 8s, up to a max)
- After max retries, mark as failed and move to DLQ
- Alert on sustained failure rates per channel

### Trade-offs

- At-least-once delivery with deduplication vs exactly-once (complex, usually unnecessary)
- Synchronous vs async delivery: async is required at scale but adds complexity
- Fallback channels (SMS if push fails) add reliability but increase cost and complexity

### Scaling Summary

- **Message queue** (Kafka/SQS) absorbs traffic spikes and decouples ingestion from delivery
- **Partition by user ID** for ordered delivery per user
- **Separate workers per channel** scale independently (email workers vs SMS workers)
- **Shard delivery logs** by time or user for storage scaling
- **Pre-warm templates** and connections to third-party providers (Twilio, SendGrid)

---

## Rate Limiter

### Functional Requirements

- Limit the number of requests a client can make within a time window
- Support different limits per API endpoint and per user tier
- Return clear rate limit headers in every response
- Support distributed rate limiting across multiple API servers

### Non-Functional Requirements

| Requirement | Target |
|---|---|
| Availability | `99.99%` -- rate limiter failure should not block all traffic |
| Latency | p99 < 1ms overhead per request (rate limit check itself) |
| Scalability | 100K QPS per region, millions of tracked keys |
| Consistency | Approximate (slightly over-limit is acceptable) |
| Security | Prevent brute-force, DDoS, and API abuse; protect the limiter store itself |
| Failure mode | Fail open (allow traffic) when the limiter store is unavailable |

### Capacity Estimation

- 100K QPS per region, peak 500K QPS
- Each rate limit key: ~64 bytes (counter + TTL metadata)
- 10M active keys = ~640 MB memory in Redis
- Sub-millisecond latency for rate limit checks (Redis `INCR` + `EXPIRE`)

### High-Level Design

```text
Client -> Load Balancer -> API Gateway -> Rate Limiter Middleware -> Service
                                        |
                                        v
                                   Redis Cluster
```

Placement options:

- **API Gateway** -- centralized, most common
- **Middleware in each service** -- distributed, harder to coordinate
- **Dedicated sidecar** -- sidecar proxy per service instance

### Data Model

```sql
CREATE TABLE rate_limit_rules (
    id              BIGINT PRIMARY KEY,
    api_path        VARCHAR(255),
    tier            VARCHAR(50),
    max_requests    INT,
    window_seconds  INT
);
```

Live state stored in Redis:

```text
Key:    rl:{client_id}:{api_path}:{window}
Value:  request_count
TTL:    window_seconds
```

### Algorithms

**Fixed Window:**

```text
Count requests in fixed time buckets (e.g., per minute)
If count > limit, reject
```

- Simple to implement
- Burst problem: 100 requests at 11:59:59 and 100 at 12:00:00 = 200 in 1 second

**Sliding Window Log:**

```text
Store timestamp of each request in a sorted set
Remove entries older than the window
If count within window > limit, reject
```

- Accurate but memory-intensive (stores every timestamp)

**Sliding Window Counter:**

```text
Weighted sum of previous window count and current window count
```

- Approximation of sliding window log
- Memory efficient and smooths burst across windows

**Token Bucket:**

```text
Bucket holds N tokens
Each request consumes 1 token
Tokens are refilled at a fixed rate
If bucket is empty, reject
```

- Allows controlled bursts (up to bucket size)
- Smooth rate limiting
- Most widely used in practice

**Leaky Bucket:**

```text
Requests enter a queue (bucket)
Processed at a fixed rate
If queue is full, reject
```

- Smooths traffic to a constant output rate
- Good for protecting downstream services

### API Design

The rate limiter is a middleware, not a user-facing API. It intercepts requests and adds headers.

**Rate limit headers (on every response):**

```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1640995200
```

**When limit exceeded:**

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 30
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1640995200

{
  "error": "rate_limit_exceeded",
  "message": "Too many requests. Retry after 30 seconds.",
  "retry_after": 30
}
```

**Admin API for managing rules:**

```http
POST /api/v1/admin/rate-limit-rules
Content-Type: application/json

{
  "api_path": "/api/v1/urls",
  "tier": "free",
  "max_requests": 100,
  "window_seconds": 60
}
```

```http
GET /api/v1/admin/rate-limit-rules
```

### Key Deep Dives

**Distributed rate limiting:**

- Use **Redis** as the central counter store
- Atomic operations: `INCR` + `EXPIRE` for fixed window, Lua scripts for token bucket
- For multi-region: use local rate limiting with async sync, or accept slightly relaxed limits

**Response headers:**

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1640995200
Retry-After: 30
```

**Failure mode:**

- If Redis is down, fail open (allow requests) or fail closed (reject)
- Fail open is usually preferred -- availability over strict rate limiting
- Alert on Redis failures and monitor rate limit bypasses

**Multi-tier limiting:**

- Global limit per user across all endpoints
- Per-endpoint limits (e.g., stricter on expensive operations)
- Per-tier limits (free vs paid users)

### Trade-offs

- Accuracy vs memory: sliding window log is exact but expensive; token bucket is efficient
- Fail-open vs fail-closed: availability vs strictness
- Centralized vs distributed: consistency vs latency
- Fixed window is simple but has burst issues; token bucket is flexible but more complex

### Scaling Summary

- **Redis Cluster** for distributed counters across multiple API servers
- **Local rate limiting** with periodic sync for multi-region deployments
- **Tiered keys** (per-user, per-IP, per-API-key) to prevent abuse at multiple levels
- **Prefer token bucket** for production -- allows bursts while enforcing average rate
- **Fail open** when Redis is down to avoid total service outage

---

## Chat Application

### Functional Requirements

- 1-on-1 and group messaging
- Message history and offline support
- Online/offline/presence status
- Read receipts and typing indicators
- Support for text, images, and files

### Non-Functional Requirements

| Requirement | Target |
|---|---|
| Availability | `99.99%` -- chat is a core communication channel |
| Latency | p99 < 200ms for message delivery (online user); p95 < 100ms |
| Scalability | 10M DAU, 500K concurrent connections, 20K messages/second peak |
| Consistency | Eventual for messages (at-least-once delivery, order per channel); strong for channels and members |
| Durability | Messages must not be lost; replicated across nodes |
| Security | End-to-end encryption optional; TLS required; message content not logged |

**Why Cassandra for messages?**

- Write-heavy workload (~20K writes/sec peak, ~4600 avg) -- Cassandra excels at append-heavy writes
- Read pattern is always by channel + time range -- maps directly to Cassandra's partition + clustering key
- `99.99%` availability -- Cassandra replicates across nodes with no single point of failure
- Horizontal scaling -- add nodes as message volume grows, no reshuffling
- Eventual consistency is acceptable for messages -- ordering is per-channel via TimeUUID, not global

**Why PostgreSQL for channels and members?**

- Small, relational data with integrity constraints (foreign keys, unique members)
- CRUD operations, not append-heavy
- Strong consistency needed for channel creation and membership changes

### Capacity Estimation

- 10M DAU, ~500K concurrent connections
- Average message size: ~100 bytes
- Each user sends ~40 messages/day
- Total messages: ~400M/day (~4600 messages/second average, ~20K peak)

**Storage:**

- Messages per day: ~400M * 100 bytes = ~40 GB/day
- Messages per year: ~40 GB * 365 = ~14.6 TB/year (before replication)
- With 3x replication: ~44 TB/year
- Cassandra scales horizontally -- add nodes as storage grows
- Consider archival: move messages older than 90 days to cold storage (S3/GCS)

**Read throughput:**

- 10M DAU, each loads ~50 messages on open = ~500M reads/day = ~5800 reads/sec avg
- Cassandra handles this easily with partition-level reads (all messages for a channel on one node)

### High-Level Design

```text
Client <--WebSocket--> Chat Server <---> Message Queue (Kafka)
                                            |
                                     Presence Service (Redis)
                                     Message Store (Cassandra)
                                     Metadata Store (PostgreSQL)
                                     Notification Service
```

Components:

- **Chat Servers** -- maintain WebSocket connections with clients
- **Message Queue** -- decouples message ingestion from delivery
- **Cassandra** -- message storage (append-heavy, partition by channel, time-ordered)
- **PostgreSQL** -- channels, members, and metadata (relational integrity)
- **Presence Service** -- tracks online/offline status (Redis)
- **Push Notification Service** -- notifies offline users
- **File Service** -- handles image and file uploads

### Connection Management

- Each client maintains a persistent **WebSocket** connection to a chat server
- Chat servers are stateful -- a user is always connected to the same server
- Connection mapping: `user_id -> chat_server_id -> WebSocket connection`
- Store mapping in Redis for cross-server routing

### Data Model

**Messages (Cassandra):**

```sql
CREATE TABLE messages (
    channel_id  UUID,
    message_id  TimeUUID,
    sender_id   BIGINT,
    content     TEXT,
    type        TEXT,  -- 'text', 'image', 'file'
    created_at  TIMESTAMP,
    PRIMARY KEY (channel_id, message_id)
) WITH CLUSTERING ORDER BY (message_id DESC);
```

- Partition by `channel_id` -- all messages for a channel live on one node
- Cluster by `message_id` (TimeUUID) -- time-ordered within a partition
- Read pattern: `WHERE channel_id = ? AND message_id < ? LIMIT 50` (paginate back in time)
- Write pattern: append-only, no updates

**Channels and Members (PostgreSQL):**

```sql
CREATE TABLE channels (
    id          UUID PRIMARY KEY,
    type        ENUM('direct', 'group'),
    name        VARCHAR(255),
    created_at  TIMESTAMP
);

CREATE TABLE channel_members (
    channel_id  UUID,
    user_id     BIGINT,
    joined_at   TIMESTAMP,
    PRIMARY KEY (channel_id, user_id)
);
```

**Why the split?**

| | Cassandra (messages) | PostgreSQL (metadata) |
|---|---|---|
| Access pattern | Append-only, read by channel + time range | CRUD with relational integrity |
| Scale | Horizontal, partition by channel | Vertical, moderate size |
| Schema | Wide, denormalized | Normalized, constrained |
| Use case | High write throughput, time-ordered reads | Channels, members, user data |

### API Design

**Send message:**

```http
POST /api/v1/messages
Content-Type: application/json

{
  "channel_id": "ch-uuid-1",
  "content": "Hello, world!",
  "type": "text",
  "client_message_id": "msg-uuid-from-client"
}
```

Response:

```json
{
  "message_id": "msg-uuid-1",
  "channel_id": "ch-uuid-1",
  "sender_id": 12345,
  "sequence_id": 1042,
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Get message history:**

```http
GET /api/v1/channels/{channel_id}/messages?limit=50&before=msg-uuid-100
```

Response:

```json
{
  "messages": [
    {
      "message_id": "msg-uuid-99",
      "sender_id": 12345,
      "content": "Previous message",
      "type": "text",
      "sequence_id": 1041,
      "created_at": "2024-01-15T10:29:00Z",
      "read_at": "2024-01-15T10:29:30Z"
    }
  ],
  "has_more": true
}
```

**Create channel (1-on-1 or group):**

```http
POST /api/v1/channels
Content-Type: application/json

{
  "type": "group",
  "name": "Project Alpha",
  "member_ids": [12345, 12346, 12347]
}
```

**Mark messages as read:**

```http
POST /api/v1/channels/{channel_id}/read
Content-Type: application/json

{
  "last_message_id": "msg-uuid-1042"
}
```

**Get channel members:**

```http
GET /api/v1/channels/{channel_id}/members
```

### Key Deep Dives

**Message flow (1-on-1):**

1. User A sends message to User B via WebSocket
2. Chat server receives the message
3. Chat server publishes to Kafka (async, for persistence)
4. Chat server looks up User B's connection
5. If User B is connected to the same chat server, deliver directly
6. If User B is on a different server, route via Redis lookup or Kafka consumer
7. If User B is offline, queue for push notification

**Message flow (group):**

1. User sends message to group
2. Chat server publishes to Kafka with group ID
3. Fan-out worker reads from Kafka
4. For each group member, deliver to their connected server or queue offline notification

**Fan-out strategies:**

- **Push on write** -- write message to each member's inbox on send (fast reads, slow writes)
- **Pull on read** -- each member fetches group messages on demand (slow reads, fast writes)
- **Hybrid** -- push for small groups, pull for large groups

**Message ordering:**

- Use a monotonically increasing sequence ID per channel
- Sequence ID is assigned by the chat server, not the client
- Clients can detect gaps and request missed messages

**Read receipts:**

- When User B reads a message, send a read receipt event
- Store `read_at` timestamp on the message
- For group chats, track per-member read status

**Typing indicators:**

- Transient state, not persisted
- Sent via WebSocket as ephemeral events
- Debounce on the client (send "typing" once every 3 seconds)

**Offline support:**

- Messages persist in Cassandra
- On reconnect, client requests messages since the last received message ID
- Send unread message count on connection establishment

**Security:**

- All WebSocket connections over TLS
- End-to-end encryption optional (Signal Protocol for content)
- Message content is not logged for debugging
- Rate limit message sending per user (prevent spam)

### Trade-offs

- WebSocket is required for real-time but adds complexity (connection management, reconnection, heartbeats)
- Push-on-write is fast for reads but expensive for large groups; hybrid is common
- Message ordering via sequence IDs is simpler than global ordering but does not span channels
- Storing all message history is expensive; consider archival policies for old messages

### Scaling Summary

- **Multiple WebSocket servers** with consistent hashing for connection distribution
- **Redis Pub/Sub** or Kafka for cross-server message routing
- **Cassandra** for message storage (partition by channel, time-ordered, horizontally scalable)
- **PostgreSQL** for channel and member metadata (small tables, relational integrity)
- **Hybrid fan-out** (push for small groups, pull for large groups)
- **CDN** for media file downloads to reduce chat server load

---

## Notification System

### Functional Requirements

- Send notifications via multiple channels: push (iOS/Android), email, SMS, in-app
- Support user preference management (which channels enabled, quiet hours, frequency)
- Template-based message formatting for each channel
- Delivery tracking (sent, delivered, opened, failed)
- Rate limiting per user to prevent notification spam
- Retry failed deliveries with exponential backoff
- Support prioritization (critical, high, normal, low)
- Bulk/broadcast notifications for system-wide announcements

### Non-Functional Requirements

| Requirement | Target |
|---|---|
| Availability | `99.9%` -- brief delays acceptable; no notification is truly time-critical |
| Latency | p99 < 2s for ingestion; delivery latency depends on channel (push < 1s, email < 30s, SMS < 10s) |
| Scalability | 10M users, 500M notifications/day (~6K QPS avg, ~30K QPS peak) |
| Consistency | Eventual -- notifications may be delayed but must not be lost |
| Durability | No lost notifications once accepted; idempotent delivery |
| Security | No notification content logged in plaintext; user PII encrypted at rest; TLS for all channels |

### Capacity Estimation

- 10M users, ~50 notifications/day average = 500M notifications/day
- 500M / 86400 ≈ 5.8K QPS average, ~30K QPS peak (3-5x average)
- Channel distribution estimate:
  - Push: 40% → ~200M/day
  - Email: 25% → ~125M/day
  - SMS: 5% → ~25M/day
  - In-app: 30% → ~150M/day
- Notification payload: ~1 KB average (metadata + template reference)
- Storage per day: `500M * 1KB ≈ 500 GB`
- Delivery log retention (90 days): `500 GB * 90 ≈ 45 TB` (partitioned, cold-storage older data)
- Template storage: negligible (~10K templates * 10 KB = 100 MB)

### High-Level Design

```text
                    ┌──────────────┐
  Event Sources ───▶│  Notification │──▶ Message Queue (Kafka/SQS)
                    │   Gateway     │          │
                    └──────────────┘          ▼
                                    ┌─────────────────┐
                                    │  Template Engine │
                                    └────────┬────────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                              ┌────▶│  Rate Limiter    │
                              │     └────────┬────────┘
                              │              │
                              ▼              ▼
                    ┌──────────────┐  ┌───────────────┐
                    │  User Prefs  │  │  Notification  │
                    │  Service     │  │  Router        │
                    └──────────────┘  └───────┬───────┘
                                              │
                         ┌────────────────────┼────────────────────┐
                         ▼                    ▼                    ▼
                  ┌────────────┐       ┌────────────┐       ┌────────────┐
                  │  Push       │       │   Email    │       │    SMS     │
                  │  Service    │       │  Service   │       │  Service   │
                  └─────┬──────┘       └─────┬──────┘       └─────┬──────┘
                        │                    │                     │
                        ▼                    ▼                     ▼
                  ┌────────────┐       ┌────────────┐       ┌────────────┐
                  │  APNs/FCM  │       │  SendGrid/ │       │  Twilio/   │
                  │            │       │  SES       │       │  Vonage    │
                  └────────────┘       └────────────┘       └────────────┘

                          In-app notifications ──▶ Redis Pub/Sub + DB
```

Components:

- **Notification Gateway** -- entry point, validates requests, assigns notification IDs, publishes to Kafka
- **Template Engine** -- renders notification content from templates with variable substitution (supports per-channel templates)
- **User Preferences Service** -- fetches user channel preferences and quiet hours from DB/cache
- **Rate Limiter** -- enforces per-user notification limits using sliding window counters in Redis
- **Notification Router** -- decides which channels to use based on user preferences, notification priority, and quiet hours
- **Channel Services (Push/Email/SMS)** -- channel-specific delivery logic, formatting, and provider integration
- **In-App Service** -- stores in-app notifications in DB, pushes real-time updates via Redis Pub/Sub or WebSocket
- **Delivery Tracker** -- records delivery status (sent, delivered, opened, failed) for each notification

### Message Queue (Kafka/SQS)

```
Topic: notifications-ingest
  Partitions: 64
  Retention: 7 days
  Consumers: notification-processor group

Message schema:
{
  "notification_id": "uuid",
  "user_id": "bigint",
  "type": "transactional|marketing|system",
  "priority": "critical|high|normal|low",
  "template_id": "string",
  "variables": { "key": "value" },
  "channels": ["push", "email", "sms", "in_app"],
  "created_at": "timestamp",
  "idempotency_key": "string"
}
```

**Why Kafka:** durable, ordered per partition, consumer groups for parallel processing, replay capability for retries.

**Dead Letter Queue (DLQ):** messages that fail after max retries are routed to a DLQ topic for manual review and reprocessing.

### Data Model

```sql
-- Notification delivery log (append-only, partitioned by time)
CREATE TABLE notification_log (
    notification_id   UUID PRIMARY KEY,
    user_id           BIGINT NOT NULL,
    type              VARCHAR(20) NOT NULL,    -- transactional, marketing, system
    priority          VARCHAR(10) NOT NULL,    -- critical, high, normal, low
    channel           VARCHAR(10) NOT NULL,    -- push, email, sms, in_app
    template_id       VARCHAR(100),
    status            VARCHAR(20) NOT NULL,    -- queued, sent, delivered, opened, failed
    provider          VARCHAR(50),             -- apns, fcm, ses, twilio, etc.
    provider_msg_id   VARCHAR(255),            -- external provider message ID
    error_message     TEXT,
    retry_count       SMALLINT DEFAULT 0,
    created_at        TIMESTAMP NOT NULL,
    sent_at           TIMESTAMP,
    delivered_at      TIMESTAMP,
    opened_at         TIMESTAMP,
    failed_at         TIMESTAMP
) PARTITION BY RANGE (created_at);

-- User notification preferences
CREATE TABLE user_preferences (
    user_id           BIGINT PRIMARY KEY,
    push_enabled      BOOLEAN DEFAULT TRUE,
    email_enabled     BOOLEAN DEFAULT TRUE,
    sms_enabled       BOOLEAN DEFAULT FALSE,
    in_app_enabled    BOOLEAN DEFAULT TRUE,
    quiet_hours_start TIME,                    -- e.g., '22:00'
    quiet_hours_end   TIME,                    -- e.g., '08:00'
    timezone          VARCHAR(50) DEFAULT 'UTC',
    max_push_per_day  INT DEFAULT 50,
    max_email_per_day INT DEFAULT 10,
    max_sms_per_day   INT DEFAULT 5,
    updated_at        TIMESTAMP NOT NULL
);

-- Notification templates
CREATE TABLE templates (
    template_id       VARCHAR(100) PRIMARY KEY,
    channel           VARCHAR(10) NOT NULL,    -- push, email, sms, in_app
    subject           VARCHAR(255),            -- for email; NULL for push/sms
    title             VARCHAR(100),            -- for push; NULL for email/sms
    body_template     TEXT NOT NULL,           -- with {{variable}} placeholders
    is_active         BOOLEAN DEFAULT TRUE,
    created_at        TIMESTAMP NOT NULL,
    updated_at        TIMESTAMP NOT NULL
);
```

**Indexing strategy:**

- `notification_log`: partitioned by `created_at` (monthly), indexed on `(user_id, created_at DESC)` for user history queries
- `user_preferences`: primary key on `user_id`, hot cache in Redis (TTL 1 hour)
- `templates`: small table, fully cached in Redis

### API Design

**Send a single notification:**

```http
POST /api/v1/notifications
Content-Type: application/json
Authorization: Bearer <service_token>

{
  "user_id": 12345,
  "type": "transactional",
  "priority": "high",
  "template_id": "order_shipped",
  "variables": {
    "order_id": "ORD-9876",
    "tracking_url": "https://track.example.com/abc123"
  },
  "channels": ["push", "email", "in_app"]
}
```

Response:

```json
{
  "notification_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "queued",
  "accepted_channels": ["push", "email", "in_app"]
}
```

**Send bulk notifications (up to 10K per request):**

```http
POST /api/v1/notifications/bulk
Content-Type: application/json
Authorization: Bearer <service_token>

{
  "type": "marketing",
  "priority": "low",
  "template_id": "weekly_digest",
  "variables": { "digest_text": "Here is your weekly summary..." },
  "channels": ["email", "in_app"],
  "user_ids": [12345, 12346, 12347]
}
```

**Get notification status:**

```http
GET /api/v1/notifications/{notification_id}
Authorization: Bearer <service_token>
```

**Update user preferences:**

```http
PUT /api/v1/users/{user_id}/notification-preferences
Content-Type: application/json
Authorization: Bearer <user_token>

{
  "push_enabled": true,
  "email_enabled": false,
  "sms_enabled": false,
  "in_app_enabled": true,
  "quiet_hours_start": "22:00",
  "quiet_hours_end": "08:00",
  "timezone": "America/New_York"
}
```

**Get user notification history:**

```http
GET /api/v1/users/{user_id}/notifications?page=1&limit=50&channel=push
Authorization: Bearer <user_token>
```

**Dismiss in-app notification:**

```http
POST /api/v1/users/{user_id}/notifications/{notification_id}/dismiss
Authorization: Bearer <user_token>
```

### Key Deep Dives

**Notification flow (end-to-end):**

1. Event source (e.g., order service) calls Notification Gateway
2. Gateway validates request, assigns `notification_id`, publishes to Kafka `notifications-ingest` topic
3. Notification Processor consumes from Kafka
4. Processor fetches user preferences from cache (Redis) or DB
5. Processor applies rate limiting -- skip notification if user has exceeded daily cap
6. Processor checks quiet hours -- if active and notification is not critical, defer delivery
7. Template Engine renders content for each target channel using variables
8. Router creates one message per channel, publishes to channel-specific Kafka topics
9. Channel services consume and send via external providers (APNs, FCM, SES, Twilio)
10. Delivery Tracker updates status based on provider webhooks/callbacks
11. In-app notifications stored in DB and pushed via Redis Pub/Sub to connected clients

**Rate limiting:**

- Sliding window counter per user per channel per day
- Stored in Redis: key = `rate:{user_id}:{channel}:{date}`, value = count
- Critical priority notifications bypass rate limits
- Configurable per-user caps (user_preference table) and system-wide caps (config)
- On rate limit hit: drop low/normal priority, queue high priority for later delivery

**Quiet hours handling:**

- When user has quiet hours set, non-critical notifications are held in a delayed queue
- A scheduled job checks every minute for notifications past the quiet period and reprocesses them
- Critical notifications (e.g., security alerts, 2FA codes) always bypass quiet hours
- Quiet hours are timezone-aware -- stored with user's timezone preference

**Retry with exponential backoff:**

```
Attempt 1: immediate
Attempt 2: wait 1 minute
Attempt 3: wait 5 minutes
Attempt 4: wait 30 minutes
Attempt 5: wait 2 hours
Max retries: 5
After max retries: move to DLQ
```

- Retry only for transient failures (provider timeout, 5xx errors)
- Permanent failures (invalid phone number, unsubscribed email) are not retried
- DLQ messages are monitored and alerted on; bulk reprocess tool available

**Delivery tracking and webhooks:**

- Each provider supports delivery status callbacks (webhooks)
- Push: APNs and FCM report delivered/failed status
- Email: SES/SendGrid report delivered, opened (via pixel), bounced, complained
- SMS: Twilio reports delivered, failed, undelivered
- Status updates are written to `notification_log` table
- Aggregated delivery metrics exported to data warehouse for analytics

**Template engine:**

- Templates stored in DB, cached in Redis
- Syntax: `Hello {{first_name}}, your order {{order_id}} has shipped.`
- Supports per-channel templates (push title + short body, email subject + HTML body, SMS plain text)
- Versioned templates -- old notifications use the template version at send time (snapshot variables at ingestion)
- Template validation on creation (check for missing variables, channel-specific length limits)

### Trade-offs

- Kafka adds operational complexity but provides durability, ordering, and replay that SQS alone cannot
- Per-channel Kafka topics add partitioning overhead but allow independent scaling per channel
- Storing all delivery events is expensive; cold-storage old logs (S3/Glacier) after 30 days
- Rate limiting per user prevents abuse but may delay legitimate high-volume notifications
- Template snapshots at send time ensure consistent rendering but prevent post-hoc template updates from affecting queued notifications
- Push notifications are fast and cheap but low engagement; email has higher open rates but higher latency
- Quiet hours improve UX but add delivery complexity with a delayed queue

### Scaling Summary

- **Kafka** with 64 partitions for ingestion throughput; scale partitions with consumer instances
- **Redis** for user preference cache, rate limit counters, and in-app Pub/Sub (low-latency fan-out)
- **Sharded PostgreSQL** partitioned by time for notification log; read replicas for history queries
- **Independent channel services** -- push, email, SMS scale separately based on their traffic patterns
- **Provider abstraction layer** -- swap providers (e.g., Twilio to Vonage) without changing core logic
- **CDN-backed asset delivery** for email templates with images/embedded content
- **Horizontal scaling** of Notification Processors -- stateless workers, scale by adding consumers
- **DLQ monitoring and alerting** to catch systematic failures before they compound

---

## Authentication System

### Functional Requirements

- User registration and login with email/password
- Social login (Google, GitHub)
- Multi-factor authentication (TOTP)
- JWT-based session management with refresh token rotation
- Password reset flow

### Non-Functional Requirements

| Requirement | Target |
|---|---|
| Availability | `99.99%` -- auth failure blocks all user actions |
| Latency | p99 < 300ms for login, < 200ms for token validation |
| Scalability | 10M registered users, 1M daily logins, 500 login QPS peak |
| Consistency | Strong for credentials (no duplicate emails); eventual for MFA state |
| Durability | User credentials and MFA secrets must survive all failures |
| Security | Passwords hashed with Argon2; tokens signed with RS256; rate limited endpoints; audit logging; no plaintext secrets anywhere |

### Capacity Estimation

- 10M registered users, ~1M daily logins
- Login QPS: ~12 average, ~500 peak (login bursts during work hours)
- Token validation QPS: ~5K average, ~20K peak (every API call validates a token)
- Storage per user: ~1 KB (credentials, profile, MFA state)
- Total user data: ~10 GB
- Refresh token store: ~10 GB (10M tokens * 1 KB)

### High-Level Design

```text
Client -> API Gateway -> Auth Service -> User DB
                        |                |
                        |           Token Service
                        |                |
                        v                v
                   Rate Limiter     Redis (token store)
                        |
                        v
                   Notification Service (email/SMS)
```

Components:

- **Auth Service** -- handles registration, login, MFA, token management
- **User Store** -- stores user credentials, profiles
- **Token Service** -- issues and validates JWTs
- **Rate Limiter** -- protects auth endpoints from brute-force
- **Notification Service** -- sends verification emails, MFA codes, password reset links

### Token Design

**Access Token (JWT):**

```json
{
  "sub": "12345",
  "email": "user@example.com",
  "roles": ["user"],
  "iat": 1640995200,
  "exp": 1640995500
}
```

**Refresh Token:**

- Opaque, high-entropy random string
- Stored server-side in Redis with TTL (7 days)
- Supports rotation: each refresh issues a new refresh token and invalidates the old one

### Data Model

```sql
CREATE TABLE users (
    id              BIGINT PRIMARY KEY,
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    email_verified  BOOLEAN DEFAULT FALSE,
    mfa_enabled     BOOLEAN DEFAULT FALSE,
    mfa_secret      VARCHAR(255),
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP
);

CREATE TABLE refresh_tokens (
    token_hash  VARCHAR(255) PRIMARY KEY,
    user_id     BIGINT NOT NULL,
    family_id   UUID NOT NULL,
    expires_at  TIMESTAMP,
    created_at  TIMESTAMP,
    revoked     BOOLEAN DEFAULT FALSE
);

CREATE TABLE password_reset_tokens (
    token_hash  VARCHAR(255) PRIMARY KEY,
    user_id     BIGINT NOT NULL,
    expires_at  TIMESTAMP,
    used        BOOLEAN DEFAULT FALSE
);

CREATE TABLE auth_audit_log (
    id          BIGINT PRIMARY KEY,
    user_id     BIGINT,
    event       ENUM('login_success', 'login_failed', 'register', 'mfa_verify', 'password_reset'),
    ip_address  INET,
    user_agent  TEXT,
    created_at  TIMESTAMP
);
```

### API Design

**Register:**

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secureP@ss123"
}
```

Response:

```json
{
  "user_id": 12345,
  "email": "user@example.com",
  "email_verified": false,
  "verification_sent": true
}
```

**Login:**

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secureP@ss123"
}
```

Response (no MFA):

```json
{
  "access_token": "eyJhbGciOi...",
  "refresh_token": "rt_abc123xyz",
  "expires_in": 300,
  "token_type": "Bearer"
}
```

Response (MFA required):

```json
{
  "mfa_required": true,
  "partial_token": "ptoken_abc123",
  "mfa_methods": ["totp"]
}
```

**Verify MFA:**

```http
POST /api/v1/auth/mfa/verify
Content-Type: application/json

{
  "partial_token": "ptoken_abc123",
  "code": "482901"
}
```

**Refresh token:**

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "rt_abc123xyz"
}
```

**Logout:**

```http
POST /api/v1/auth/logout
Authorization: Bearer <access_token>
```

**Password reset (request):**

```http
POST /api/v1/auth/password-reset/request
Content-Type: application/json

{
  "email": "user@example.com"
}
```

**Password reset (confirm):**

```http
POST /api/v1/auth/password-reset/confirm
Content-Type: application/json

{
  "token": "reset_token_xyz",
  "new_password": "newSecureP@ss456"
}
```

**Enable MFA:**

```http
POST /api/v1/auth/mfa/enable
Authorization: Bearer <access_token>
```

Response:

```json
{
  "secret": "JBSWY3DPEHPK3PXP",
  "otpauth_url": "otpauth://totp/MyApp:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=MyApp",
  "backup_codes": ["a1b2-c3d4", "e5f6-g7h8"]
}
```

### Key Deep Dives

**MFA implementation:**

- On setup, generate a TOTP secret, store encrypted in the database
- Return a QR code for the user to scan with an authenticator app
- On login, verify the 6-digit TOTP code against the secret
- Provide backup codes for account recovery

**Brute-force protection:**

- Rate limit: max 5 failed attempts per email per 15 minutes
- Account lockout after 10 consecutive failures (temporary, 30 minutes)
- CAPTCHA after 3 failed attempts
- Log and alert on repeated failures from the same IP

**Token rotation:**

- On refresh, issue new access + refresh token pair
- Invalidate old refresh token
- If old refresh token is reused, revoke the entire token family (possible theft)
- Track token family ID to detect reuse

**Social login (OAuth2/OIDC):**

- Redirect user to provider (Google, GitHub)
- Receive authorization code on callback
- Exchange code for tokens at provider's token endpoint
- Extract user identity from ID token
- Link to existing account or create new one

### Trade-offs

- JWT vs session tokens: JWT is stateless and scales well; sessions are easier to revoke
- Access token lifetime: shorter is more secure but requires more refresh calls
- Social login simplifies UX but adds dependency on third-party providers
- Account lockout protects against brute-force but can be used for denial-of-service

### Scaling Summary

- **Redis** for token store (refresh tokens, rate limit counters) -- fast and shared
- **JWT validation** is stateless -- any server can verify without hitting the database
- **Separate auth service** scales independently from business services
- **Rate limit at the API gateway** before requests reach the auth service
- **Read replica** for user lookups; write primary for credential changes only

---

## File Upload Service

### Functional Requirements

- Upload files up to 10 GB
- Support resumable uploads for large files
- Store files durably with replication
- Generate shareable download links with optional expiration
- Support file metadata (name, type, size, tags)
- Track storage usage per user

### Non-Functional Requirements

| Requirement | Target |
|---|---|
| Availability | `99.99%` for download; `99.9%` for upload (retries cover brief outages) |
| Latency | p99 < 1s for upload initiation; p99 < 300ms for download via CDN |
| Scalability | 1M users, 25 TB/day uploads, 100K concurrent downloads |
| Consistency | Strong for metadata; eventual for CDN cache |
| Durability | 99.999999999% (11 nines) via object storage replication |
| Security | Pre-signed URLs with expiration; no public directory listing; virus scan before serving; access control per file |

### Capacity Estimation

- 1M users, each uploading ~5 files/day
- Average file size: ~5 MB
- Daily upload volume: ~25 TB
- Peak upload throughput: ~200 MB/s
- Read-heavy (downloads dominate uploads, ~10:1 ratio)
- Download QPS: ~100K peak (CDN absorbs most traffic)

### High-Level Design

```text
Client -> API Gateway -> Upload Service -> Object Storage (S3)
                        |                      |
                        v                      v
                   Metadata DB           CDN (CloudFront)
                        |
                        v
                   Processing Pipeline (thumbnails, virus scan)
```

Components:

- **Upload Service** -- handles upload requests, generates pre-signed URLs
- **Object Storage** -- durable, scalable file storage (S3, GCS, MinIO)
- **Metadata Database** -- stores file metadata, user quotas
- **CDN** -- caches and serves downloads from edge locations
- **Processing Pipeline** -- async post-upload tasks (thumbnails, virus scan, content extraction)

### Upload Flow (Small Files, < 100 MB)

1. Client requests an upload slot with file metadata
2. Upload service validates user quota and file type
3. Upload service generates a pre-signed URL for direct upload to object storage
4. Client uploads directly to object storage (bypasses your servers)
5. Object storage returns success
6. Upload service records metadata in the database
7. Publishing event to processing pipeline (thumbnail generation, virus scan)

### Upload Flow (Large Files, Resumable)

Use **tus protocol** or chunked upload:

1. Client requests a new upload session
2. Upload service creates an upload record with status `in_progress`
3. Client uploads file in chunks (e.g., 5 MB each)
4. Each chunk is uploaded to object storage with a part number
5. Upload service tracks which parts have been received
6. On final chunk, client signals completion
7. Upload service triggers a `CompleteMultipartUpload` on object storage
8. Processing pipeline runs

**Resumability:**

- Client queries upload status to learn which parts were received
- Client re-uploads only missing parts
- Upload session expires after 24 hours of inactivity

### Data Model

```sql
CREATE TABLE files (
    id          UUID PRIMARY KEY,
    user_id     BIGINT NOT NULL,
    object_key  VARCHAR(1024) NOT NULL,
    file_name   VARCHAR(255) NOT NULL,
    mime_type   VARCHAR(127),
    size_bytes  BIGINT,
    status      ENUM('uploading', 'processing', 'ready', 'failed'),
    created_at  TIMESTAMP,
    updated_at  TIMESTAMP
);

CREATE TABLE upload_parts (
    upload_id   UUID,
    part_number INT,
    object_key  VARCHAR(1024),
    size_bytes  BIGINT,
    received_at TIMESTAMP,
    PRIMARY KEY (upload_id, part_number)
);

CREATE TABLE download_links (
    token       VARCHAR(255) PRIMARY KEY,
    file_id     UUID NOT NULL,
    expires_at  TIMESTAMP,
    max_downloads INT,
    download_count INT DEFAULT 0
);

CREATE TABLE user_storage (
    user_id     BIGINT PRIMARY KEY,
    used_bytes  BIGINT DEFAULT 0,
    quota_bytes BIGINT
);

CREATE INDEX idx_files_user ON files(user_id, created_at);
```

### API Design

**Initiate upload:**

```http
POST /api/v1/uploads
Content-Type: application/json

{
  "file_name": "report.pdf",
  "mime_type": "application/pdf",
  "size_bytes": 52428800
}
```

Response:

```json
{
  "upload_id": "upload-uuid-1",
  "upload_url": "https://storage.example.com/bucket/uploads/upload-uuid-1?X-Amz-Signature=...",
  "expires_at": "2024-01-15T11:00:00Z",
  "chunk_size": 5242880,
  "max_chunks": 10
}
```

**Complete upload:**

```http
POST /api/v1/uploads/{upload_id}/complete
Content-Type: application/json

{
  "parts": [
    {"part_number": 1, "etag": "abc123"},
    {"part_number": 2, "etag": "def456"}
  ]
}
```

Response:

```json
{
  "file_id": "file-uuid-1",
  "status": "processing",
  "created_at": "2024-01-15T10:35:00Z"
}
```

**Get upload status (for resumable uploads):**

```http
GET /api/v1/uploads/{upload_id}
```

Response:

```json
{
  "upload_id": "upload-uuid-1",
  "status": "in_progress",
  "parts_received": [1, 2, 4],
  "parts_expected": 10,
  "missing_parts": [3, 5, 6, 7, 8, 9, 10]
}
```

**List user files:**

```http
GET /api/v1/files?limit=20&cursor=abc123
```

Response:

```json
{
  "files": [
    {
      "file_id": "file-uuid-1",
      "file_name": "report.pdf",
      "mime_type": "application/pdf",
      "size_bytes": 52428800,
      "status": "ready",
      "created_at": "2024-01-15T10:35:00Z",
      "download_url": "https://cdn.example.com/files/file-uuid-1?X-Amz-Signature=..."
    }
  ],
  "next_cursor": "def456"
}
```

**Create shareable link:**

```http
POST /api/v1/files/{file_id}/share
Content-Type: application/json

{
  "expires_in_hours": 24,
  "max_downloads": 10
}
```

Response:

```json
{
  "share_token": "share_abc123xyz",
  "share_url": "https://share.example.com/s/share_abc123xyz",
  "expires_at": "2024-01-16T10:35:00Z"
}
```

**Delete file:**

```http
DELETE /api/v1/files/{file_id}
```

### Key Deep Dives

**Pre-signed URLs:**

- Object storage (S3) supports pre-signed URLs that grant temporary upload/download access
- No file data passes through your servers -- direct client-to-storage transfer
- Reduces server load and bandwidth costs
- URL expires after a configurable time (e.g., 15 minutes for upload, 1 hour for download)

**Download links:**

- Generate a random, opaque token mapped to the file ID
- Support expiration time and max download count
- Links are shareable but revocable (delete the token)
- For private files, sign the URL with an expiration

**File processing pipeline:**

- Triggered by an S3 event notification on upload completion
- Thumbnail generation for images and videos
- Virus scan before marking file as `ready`
- Content extraction for indexing (text from documents, metadata from media)
- Processing failures should not block the upload -- mark as `failed` and retry

**Storage quota enforcement:**

- Check quota before starting upload
- Use a database counter per user, updated atomically on upload completion
- For high-scale: use Redis with periodic reconciliation to the database
- Reject uploads that would exceed the quota with a clear error message

**CDN for downloads:**

- Serve popular files from edge locations (reduces origin load)
- Cache-Control headers control CDN caching behavior
- Private files: use signed CDN URLs with expiration
- Origin shield: reduce origin hits by routing through a single CDN edge

**Security:**

- Pre-signed URLs have short TTL (15 minutes for upload, 1 hour for download)
- No public directory listing; every file requires authentication or a valid signed URL
- Virus scan runs before marking files as `ready` (prevents serving infected files)
- Access control: file owner controls who can download
- Rate limit uploads per user to prevent abuse

### Trade-offs

- Pre-signed URLs reduce server load but lose control over the upload (no server-side validation during transfer)
- Chunked upload adds complexity but is essential for large files and unreliable networks
- Synchronous processing blocks the user; async processing is preferred but adds eventual consistency
- CDN caching improves performance but requires cache invalidation strategy for updated files

### Scaling Summary

- **Pre-signed URLs** offload upload/download bandwidth from your servers to object storage
- **CDN** absorbs download traffic -- origin servers rarely serve hot files
- **Chunked uploads** with resumability handle large files without server memory pressure
- **Async processing pipeline** (S3 events -> Lambda/SQS) for thumbnails and virus scanning
- **Shard metadata database** by user_id if file volume grows beyond single-node capacity
