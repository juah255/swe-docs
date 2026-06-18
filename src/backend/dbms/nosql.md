# NoSQL

NoSQL databases are databases that do not rely only on the traditional
relational table model. They are commonly used when applications need flexible
schemas, high write throughput, horizontal scaling, or data models that do not
fit cleanly into rows and columns.

NoSQL does not mean "no SQL at all" in every database. A better meaning is
often **not only SQL**.

## Why Use NoSQL?

NoSQL databases are commonly used for:

- flexible or rapidly changing data structures;
- large-scale distributed systems;
- high-volume reads and writes;
- caching and session storage;
- event, log, and time-series data;
- document-style application data; and
- graph-like relationships.

## Main Types

### Document Databases

Document databases store data as documents, usually in a JSON-like format.

Examples:

- MongoDB
- CouchDB
- Firestore

Use cases:

- user profiles;
- product catalogs;
- content management systems;
- data where each record may have different fields.

Example document:

```json
{
  "id": "u-101",
  "name": "Ann Smith",
  "email": "ann@example.com",
  "skills": ["SQL", "Node.js", "Docker"]
}
```

### Key-Value Stores

Key-value stores save data as a key and its associated value.

Examples:

- Redis
- DynamoDB
- Memcached

Use cases:

- caching;
- sessions;
- rate limiting;
- feature flags;
- simple lookup data.

Example:

| Key               | Value                    |
|-------------------|--------------------------|
| `session:u-101`   | serialized session data  |
| `rate:user:u-101` | request count            |

### Wide-Column Databases

Wide-column databases store data in rows and column families. They are designed
for large-scale distributed workloads.

Examples:

- Cassandra
- HBase
- ScyllaDB

Use cases:

- time-series data;
- analytics events;
- high-write logging systems;
- large distributed datasets.

### Graph Databases

Graph databases store data as nodes and edges. They are useful when
relationships are the main part of the data model.

Examples:

- Neo4j
- Amazon Neptune

Use cases:

- social networks;
- recommendation systems;
- fraud detection;
- dependency graphs.

## SQL vs NoSQL

| Topic          | SQL Databases                         | NoSQL Databases                         |
|----------------|----------------------------------------|------------------------------------------|
| Data model     | Tables, rows, and columns              | Documents, keys, columns, or graphs      |
| Schema         | Usually strict                         | Often flexible                           |
| Relationships  | Strong joins and foreign keys          | Often embedded or application-managed    |
| Scaling        | Commonly vertical, also horizontal     | Commonly designed for horizontal scaling |
| Transactions   | Strong `ACID` support                  | Varies by database and configuration     |
| Best for       | Structured relational data             | Flexible or large-scale distributed data |

## Data Modeling

NoSQL data modeling is usually driven by query patterns. Instead of normalizing
data first, start by asking:

- What queries must be fast?
- Which fields are read together?
- Which data changes together?
- Is duplication acceptable for faster reads?
- What consistency guarantees are required?

In many NoSQL systems, some duplication is intentional. This can improve read
performance, but the application must handle consistency carefully.

## Consistency

Relational databases usually emphasize strong consistency. Distributed NoSQL
databases may choose different trade-offs between consistency, availability, and
partition tolerance.

Important concepts:

- **CAP theorem**: during a network partition, a distributed system must choose
  between consistency and availability.
- **BASE**: basically available, soft state, eventual consistency.
- **Eventual consistency**: updates may take time to become visible everywhere.

Not every NoSQL database is eventually consistent by default. Always check the
specific database and configuration.

## Advantages

- Flexible schema design.
- Good horizontal scaling options.
- High throughput for specific access patterns.
- Natural fit for documents, caches, events, and graphs.
- Easier storage of nested or semi-structured data.

## Disadvantages

- Fewer built-in relational constraints.
- Joins may be limited or unavailable.
- Data duplication can create consistency problems.
- Query patterns must be planned carefully.
- Transactions and consistency guarantees vary between databases.

## When to Choose NoSQL

Choose NoSQL when:

- the data is naturally document, key-value, wide-column, or graph-shaped;
- the schema changes frequently;
- the workload needs very high scale or throughput;
- reads are faster with embedded or duplicated data;
- flexible data structures are more important than strict relational modeling.

Use a relational database when the data has strong relationships, requires
complex joins, or depends heavily on constraints and transactions.

## Common Pitfalls

- Choosing NoSQL only because it sounds more scalable.
- Ignoring query patterns before designing collections or keys.
- Duplicating data without a consistency strategy.
- Using a document database for highly relational data.
- Assuming all NoSQL databases have the same behavior.
- Ignoring indexing, partition keys, and access patterns.

## Summary

NoSQL databases provide alternatives to relational storage models. They are
useful for flexible schemas, distributed scale, caching, documents, events, and
graphs. The main trade-off is that the application often takes on more
responsibility for relationships, constraints, and consistency.

## Mid/Senior Interview Questions and Answers

### 1. How do you choose between SQL and NoSQL?

**Answer:** Choose SQL when relationships, constraints, joins, transactions, and
ad hoc querying are central. Choose NoSQL when the data model and access
patterns fit documents, key-value lookups, wide-column writes, graphs, caching,
or distributed scale.

The decision should come from workload and consistency requirements, not from
the idea that NoSQL is automatically more scalable.

### 2. Why is NoSQL data modeling driven by query patterns?

**Answer:** Many NoSQL systems do not provide flexible joins or arbitrary
queries like relational databases. Data is often stored in the shape needed for
fast reads or writes.

That means you design from access patterns: keys, partitions, sort order,
embedded data, duplication, and consistency requirements.

### 3. What is eventual consistency?

**Answer:** Eventual consistency means replicas or duplicated data may not show
the latest write immediately, but they should converge if no new updates occur.

Applications using eventual consistency must handle stale reads, conflict
resolution, retries, and user experience around delayed visibility.

### 4. What are common NoSQL partition-key mistakes?

**Answer:** Common mistakes include choosing a low-cardinality key, creating hot
partitions, ignoring query patterns, and using keys that make important reads
require scans.

Good partition keys distribute load while supporting the most important access
patterns.

### 5. When should duplicated NoSQL data be avoided?

**Answer:** Avoid duplication when data must be strongly consistent everywhere,
when update fan-out is large, or when the team lacks a reliable mechanism to
repair inconsistencies.

Duplication is a performance tool, not free storage design.
