# Indexing

Database indexes improve query performance by providing efficient access paths to stored data.

## Core Topics

- Primary and secondary indexes
- Clustered and non-clustered indexes
- Single-column and composite indexes
- B-tree and hash indexes
- Covering and partial indexes
- Index selectivity and cardinality
- Read performance vs. write and storage costs
- Query plans and `EXPLAIN`

## Mid/Senior Interview Questions and Answers

### 1. Why does an index improve query performance?

**Answer:** An index gives the database an efficient access path to matching
rows instead of scanning the whole table. Most relational indexes are B-tree
based and work well for equality, range, ordering, and prefix queries depending
on the index.

An index does not guarantee speed. The optimizer chooses whether to use it based
on statistics, selectivity, cost, and query shape.

### 2. What are the trade-offs of adding indexes?

**Answer:** Indexes speed up reads but cost storage and slow down writes because
the database must maintain index entries on insert, update, and delete.

Too many indexes also make migrations and bulk writes slower. Add indexes for
real query patterns, not every column.

### 3. How do composite indexes work?

**Answer:** A composite index covers multiple columns in a defined order. The
leftmost column order matters for many databases.

For an index on `(tenant_id, status, created_at)`, queries filtering by
`tenant_id` and `status` and ordering by `created_at` may benefit. A query only
filtering by `created_at` may not use the index effectively.

### 4. What is a covering index?

**Answer:** A covering index contains all columns needed by a query, allowing
the database to answer from the index without reading the table rows.

Covering indexes can be very fast for hot read paths, but they add storage and
write overhead.

### 5. How do you use `EXPLAIN` to improve a slow query?

**Answer:** Use `EXPLAIN` or `EXPLAIN ANALYZE` to inspect scan type, join
strategy, row estimates, actual rows, sort operations, and index usage.

Senior-level tuning compares estimated versus actual rows. Bad estimates often
point to stale statistics, missing indexes, poor predicates, or data skew.
