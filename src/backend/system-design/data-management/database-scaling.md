# Database Scaling

Database scaling is about handling growing read/write throughput and data volume. The two fundamental approaches are **replication** (scaling reads) and **sharding** (scaling writes and storage).

## Vertical Scaling

- Add more CPU, RAM, or faster disks to a single database instance
- Simple, no application changes required
- Has a hardware ceiling and is a single point of failure
- Works well for early-stage products

## Read Replicas

**Replication** copies data across multiple database nodes for read scaling and fault tolerance.

### Primary-Replica (Leader-Follower)

- Writes go to the **primary** (leader)
- Reads can be served by **replicas** (followers)
- Replication lag means replicas may be slightly stale (eventual consistency on reads)

```text
Writes -> Primary
Reads  -> Replica 1
         Replica 2
         Replica 3
```

### Multi-Primary

- Multiple write nodes, which adds conflict resolution complexity
- Useful for multi-region writes where latency to a single primary is unacceptable
- Requires conflict resolution strategies (last-write-wins, CRDTs, application-level merging)

### Replication Lag

- Replicas may lag behind the primary by milliseconds to seconds
- Critical reads (post-write-read consistency) must hit the primary
- Use `read-your-writes` consistency for user-facing reads after writes

## Connection Pooling

Every request that opens a fresh database connection pays for the TCP
handshake, auth, and setup. Under load, a Connect -> Query -> Disconnect
pattern can reach ~500 connection changes per second. Pools reuse a fixed set
of connections instead.

- **Application-side pools** (SQLAlchemy pool, psycopg2 pool) reuse connections
  within a single app process
- App workers multiply connections: each worker holds its own, so 100 workers
  x 20 connections each = 2000 logical connections to the database

### PgBouncer

PgBouncer is a lightweight connection pooler that sits between the application
and PostgreSQL. Many app connections share a small number of real database
connections.

- **Session pooling** -- a pooled connection is held for the whole client
  session until disconnect; simple, but idle sessions waste connections
- **Transaction pooling** -- a pooled connection is returned to the pool as
  soon as the transaction ends; better for short-lived API requests, but apps
  must avoid session state (prepared statements, LISTEN/NOTIFY, temp tables)
- With PgBouncer, 100 workers x 20 connections each (2000 logical) drops to
  ~100 real database connections

Real-world result: a pooled async setup lowered p95 latency, cut database
connection changes by ~60%, and raised throughput during spikes.

## Sharding / Partitioning

**Sharding** splits data across multiple nodes so no single machine holds everything. It scales writes and storage, which replication alone cannot.

### Sharding Strategies

| Strategy | How It Works | Pros | Cons |
|---|---|---|---|
| **Range-based** | Partition by key ranges (e.g., users A-M, N-Z) | Simple, supports range queries | Risk of hotspots |
| **Hash-based** | Hash the key to pick a shard | Even distribution | Range queries are hard |
| **Consistent hashing** | Hash ring minimizes data movement on shard changes | Low reshuffling cost | More complex to implement |

### Choosing a Shard Key

The shard key determines how data is distributed. A bad shard key creates hotspots (one shard gets most of the traffic).

Good shard keys:

- High cardinality (many distinct values)
- Evenly distributed (no skew)
- Aligned with access patterns (queries that hit one shard, not cross-shard)

Examples: `user_id`, `tenant_id`, `order_id`

### Cross-Shard Operations

- **Cross-shard joins** are expensive and should be avoided
- **Cross-shard transactions** require distributed transaction protocols (2PC, sagas)
- **Aggregate queries** (COUNT, SUM) must fan out to all shards and merge results
- Design queries to hit a single shard whenever possible

## Polyglot Persistence

Different data stores for different access patterns:

- **Relational DB** (PostgreSQL, MySQL) -- structured data, ACID, complex queries
- **Document DB** (MongoDB) -- flexible schema, nested documents
- **Key-Value** (Redis, DynamoDB) -- simple lookups, high throughput
- **Time-series** (InfluxDB, TimescaleDB) -- metrics, events, IoT data
- **Graph DB** (Neo4j) -- relationships, social networks, recommendations

Choose based on access pattern and consistency needs, not popularity.

## SQL vs NoSQL

| | SQL | NoSQL |
|---|---|---|
| Schema | Structured, fixed | Flexible, dynamic |
| Consistency | Strong (ACID) | Often eventual |
| Scaling | Vertical, read replicas | Horizontal (built-in sharding) |
| Queries | Complex joins, aggregations | Simple access patterns |
| Best for | Complex domains, transactions | High write volume, flexible schema |

## Mid/Senior Interview Questions and Answers

### 1. When do you choose horizontal over vertical scaling?

**Answer:** Vertical scaling is fine for early stages and simple, until you hit a
hardware ceiling or need fault tolerance. Horizontal scaling is the answer for
high traffic and availability, since you can add commodity nodes and survive
individual failures.

The prerequisite is statelessness on the app tier and a strategy for state
(caches, replicas, shards), which is the real work in scaling out.

### 2. Why does replication not solve write scaling?

**Answer:** Primary-replica replication scales reads by adding read-only copies,
but all writes still funnel through a single primary. Once write throughput or
data size exceeds one node, you need sharding to split writes and storage across
multiple nodes.

Replication and sharding are complementary: shard for write/storage scale,
replicate each shard for read scale and fault tolerance.

### 3. How do you choose a good shard key?

**Answer:** The shard key should have high cardinality, even distribution, and
alignment with your most common query patterns. A key that clusters data on one
shard creates hotspots and defeats the purpose of sharding.

Consider how your queries will route: can most queries hit a single shard? Do
you need cross-shard joins or transactions? The shard key choice is one of the
hardest decisions in sharding and is very expensive to change later.
