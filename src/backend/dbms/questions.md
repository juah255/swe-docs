# DBMS Questions

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between DBMS and RDBMS?

**Answer:** A DBMS manages data storage, retrieval, and integrity. An RDBMS is a
DBMS based on the relational model with tables, rows, columns, keys, relations,
and SQL.

Most production relational systems also provide transactions, indexes,
constraints, views, stored routines, and query optimization.

### 2. What is the difference between SQL and NoSQL databases?

**Answer:** SQL databases are usually relational, schema-driven, and strong at
joins, transactions, and constraints. NoSQL databases use models such as
documents, key-value, wide-column, or graphs and often optimize for flexible
schema or distributed access patterns.

Choose based on data shape, query patterns, consistency requirements, and
operational needs.

### 3. What is the difference between a primary key, foreign key, and composite key?

**Answer:** A primary key uniquely identifies a row. A foreign key references a
row in another table and protects relationship integrity. A composite key uses
multiple columns together to identify a row.

Composite keys are common in junction tables, but many systems also use
surrogate IDs plus unique constraints for convenience.

### 4. What is the difference between `DELETE`, `TRUNCATE`, and `DROP`?

**Answer:** `DELETE` removes selected rows and can usually be filtered and
rolled back in a transaction. `TRUNCATE` removes all rows more directly and may
reset storage or identity counters depending on the database. `DROP` removes
the table or object itself.

The exact transactional behavior varies by database, so production scripts
should be reviewed carefully.

### 5. What is the difference between `INNER`, `LEFT`, `RIGHT`, and `FULL` joins?

**Answer:** `INNER JOIN` returns matching rows from both tables. `LEFT JOIN`
returns all rows from the left table and matching rows from the right. `RIGHT
JOIN` is the reverse. `FULL JOIN` returns rows from both sides, matching where
possible and filling missing values with `NULL`.

Most APIs use `INNER` and `LEFT` joins most often.

### 6. What is a view?

**Answer:** A view is a saved query exposed like a virtual table. It can
simplify complex joins, enforce a stable read interface, or limit exposed
columns.

Views are not always performance optimizations. Materialized views store results
and can improve reads, but they need refresh strategy.

### 7. What is a stored procedure?

**Answer:** A stored procedure is database-side code that performs an operation,
often with parameters and multiple statements.

It can be useful for data-heavy operations, shared database rules, or controlled
access, but it must be versioned, tested, and deployed with the same discipline
as application code.

### 8. When would you choose denormalization?

**Answer:** Choose denormalization when measured read or reporting needs justify
duplicating or precomputing data.

Use it deliberately with a consistency strategy. Do not denormalize simply to
avoid learning joins.

### 9. Why can too many indexes hurt performance?

**Answer:** Every index consumes storage and must be updated when indexed data
changes. Too many indexes slow writes, increase maintenance cost, and can make
the optimizer's job harder.

Indexes should reflect real query patterns and be validated with query plans.

### 10. When might a database not use an index?

**Answer:** The optimizer may skip an index if the predicate is not selective,
statistics suggest a table scan is cheaper, the query uses functions on indexed
columns, the column order does not match a composite index, or the result set is
too large.

Use `EXPLAIN` to check actual behavior instead of assuming.

### 11. How would you optimize a slow query?

**Answer:** Reproduce the query, inspect `EXPLAIN`, check row counts and
indexes, verify predicates and joins, reduce selected columns, avoid unnecessary
sorting, and confirm whether the ORM generated inefficient SQL.

Measure before and after. Query tuning without a plan can make other workloads
worse.

### 12. How would you paginate a large result set efficiently?

**Answer:** Prefer cursor or keyset pagination for large changing datasets.
Offset pagination is simple but gets slower at high offsets and can skip or
duplicate rows when data changes.

Use a stable sort key, deterministic ordering, and a maximum page size.
