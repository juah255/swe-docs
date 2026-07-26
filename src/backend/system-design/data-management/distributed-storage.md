# Distributed Storage

**Distributed storage** spreads data across multiple machines to achieve scalability, durability, and availability that a single machine cannot provide.

## Why Distributed Storage

- Data too large for a single disk
- Write throughput exceeds a single machine
- Geographic proximity to users (latency)
- Durability: data must survive disk, machine, or datacenter failures

## Key Concepts

### Replication Factor

The number of copies of each data item across the cluster:

- **Replication factor 3** -- survives 2 node failures (common default)
- **Replication factor 5** -- survives 4 node failures (high durability)
- More replicas = more durability, but more storage cost and write overhead

### Consistency Levels

In distributed storage, you choose a consistency level per read/write:

| Level | Meaning |
|---|---|
| **ONE** | Acknowledge after one replica responds (fastest, weakest) |
| **QUORUM** | Acknowledge after majority of replicas respond (balanced) |
| **ALL** | Acknowledge after all replicas respond (strongest, slowest) |

The **consistency equation**: `W + R > N` guarantees strong consistency, where W = write quorum, R = read quorum, N = replication factor.

### Partitioning

Data is split across nodes by a partition key:

- **Hash-based partitioning** -- even distribution, no range queries
- **Range-based partitioning** -- supports range queries, risk of hotspots
- **Consistent hashing** -- minimal data movement when nodes change

### Consensus

For operations that require agreement across nodes:

- **Raft** -- understandable consensus algorithm, used by etcd, CockroachDB
- **Paxos** -- foundational but complex, used by Google Spanner
- **ZAB** -- Zookeeper Atomic Broadcast, used by ZooKeeper

## CAP Theorem

During a network partition, a distributed system can guarantee only two of:

- **Consistency** -- every read sees the latest write
- **Availability** -- every request gets a non-error response
- **Partition tolerance** -- the system keeps working despite dropped messages

Since partitions are unavoidable, real systems choose between **CP** (reject requests to stay consistent) and **AP** (stay available, allow stale reads).

## Consistency Models

- **Strong consistency** -- reads always reflect the most recent write
- **Eventual consistency** -- replicas converge over time; reads may be stale
- **Read-your-writes** -- a user always sees their own most recent write
- **Monotonic reads** -- a user never sees data move backwards in time

Pick the weakest model that satisfies the business rule.

## Distributed Storage Systems

| System | Model | Use Case |
|---|---|---|
| **Cassandra** | AP, wide-column | High write throughput, time-series |
| **DynamoDB** | AP, key-value | Managed, low latency, auto-scaling |
| **CockroachDB** | CP, relational | Distributed SQL, strong consistency |
| **Google Spanner** | CP, relational | Global-scale, strong consistency with clocks |
| **etcd** | CP, key-value | Coordination, configuration, leader election |
| **MinIO** | AP, object storage | S3-compatible, self-hosted |

## Mid/Senior Interview Questions and Answers

### 1. How does CAP guide a real design?

**Answer:** Partitions are inevitable, so the real choice is how to behave during
one: stay consistent and reject some requests (CP), or stay available and serve
possibly stale data (AP). Tie that choice to the business rule for each data set.

A payment ledger leans CP; a social feed or product view count leans AP. Many
systems mix both, applying strong consistency only to the few critical writes.

### 2. When would you choose Cassandra over PostgreSQL?

**Answer:** Cassandra excels at high write throughput, time-series data, and
multi-datacenter replication with tunable consistency. It scales writes
horizontally without the operational complexity of sharding PostgreSQL.

PostgreSQL is better for complex queries, joins, transactions, and data
integrity. Choose based on your dominant access pattern: Cassandra for write
volume and simple queries, PostgreSQL for read complexity and ACID guarantees.

### 3. What is quorum and why does it matter?

**Answer:** Quorum is the minimum number of replicas that must acknowledge a
read or write for it to be considered successful. With replication factor 3,
quorum is 2.

Quorum ensures that even if some replicas are down, the system still returns
consistent data. The consistency equation `W + R > N` guarantees that read and
write quorums overlap, preventing stale reads.
